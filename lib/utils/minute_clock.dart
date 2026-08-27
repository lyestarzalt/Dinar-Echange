import 'dart:async';
import 'package:flutter/foundation.dart';

/// Single app-wide ValueNotifier that ticks once per minute. Widgets
/// that render "N min ago" style timestamps subscribe to this via
/// ValueListenableBuilder instead of each starting its own Timer —
/// previously every RelativeTime instance held a distinct
/// Timer.periodic(60s) which added up when a screen renders several.
class MinuteClock {
  static final MinuteClock instance = MinuteClock._();

  final ValueNotifier<DateTime> tick = ValueNotifier<DateTime>(DateTime.now());
  // Held to keep the periodic timer alive for the lifetime of the app.
  // ignore: unused_field
  late final Timer _timer;

  MinuteClock._() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      tick.value = DateTime.now();
    });
  }
}
