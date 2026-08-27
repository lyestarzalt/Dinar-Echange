import 'package:dinar_echange/utils/logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Tests for [AppLogger].
///
/// Uses a real Sentry init with a `beforeSend` callback that drops events
/// after recording them locally, so we exercise the production code path
/// without shipping to sentry.io. This is the pattern recommended by the
/// Sentry SDK for testing integrations.
void main() {
  late List<SentryEvent> captured;

  setUp(() async {
    captured = <SentryEvent>[];
    await Sentry.init((options) {
      options.dsn = 'https://public@example.com/1';
      options.beforeSend = (event, hint) async {
        captured.add(event);
        return null; // drop → nothing is actually transmitted
      };
    });
  });

  tearDown(() async {
    await Sentry.close();
  });

  Future<void> pumpSentry() async {
    // captureException/captureMessage don't complete synchronously — give
    // the microtask queue and any Sentry-internal timers a chance to
    // drain before asserting.
    for (var i = 0; i < 200 && captured.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  group('logError → Sentry', () {
    test('with an error object, ships as an exception at error level',
        () async {
      AppLogger.logError('boom', error: StateError('bad state'));
      await pumpSentry();

      expect(captured, hasLength(1));
      final event = captured.single;
      expect(event.level, SentryLevel.error);
      expect(event.exceptions, isNotEmpty,
          reason: 'error object should be attached as an exception');
    });

    test('without an error object, ships as a message at error level',
        () async {
      AppLogger.logError('history not available');
      await pumpSentry();

      expect(captured, hasLength(1));
      final event = captured.single;
      expect(event.level, SentryLevel.error);
      expect(event.exceptions ?? const [], isEmpty,
          reason: 'no error object → captureMessage path, not captureException');
      expect(event.message?.formatted, 'history not available');
    });

    test('isFatal:true bumps the level to SentryLevel.fatal', () async {
      AppLogger.logError(
        'irrecoverable',
        error: StateError('dead'),
        isFatal: true,
      );
      await pumpSentry();

      expect(captured, hasLength(1));
      expect(captured.single.level, SentryLevel.fatal);
    });

    test('the reason message rides along as a log context', () async {
      AppLogger.logError('conversion failed', error: FormatException('nope'));
      await pumpSentry();

      final ctx = captured.single.contexts['log'];
      expect(ctx, isNotNull);
      expect(ctx, containsPair('message', 'conversion failed'));
    });
  });

  group('logError → reportToSentry:false gate', () {
    test('with an error object, nothing is captured', () async {
      AppLogger.logError(
        'ad failed to load',
        error: StateError('ad bailed'),
        reportToSentry: false,
      );
      // Wait a few microtasks to be sure — nothing should ever land.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(captured, isEmpty);
    });

    test('without an error object, nothing is captured', () async {
      AppLogger.logError(
        'expected miss',
        reportToSentry: false,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(captured, isEmpty);
    });
  });
}
