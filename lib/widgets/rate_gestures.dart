import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';

/// Wraps a widget with a long-press-to-copy gesture. Copies `value` to
/// the clipboard, fires a medium haptic, and shows a short confirmation
/// SnackBar. Used on rate numbers throughout the app.
class CopyableRate extends StatelessWidget {
  final Widget child;
  final String value;
  final String? snackbarMessage;

  const CopyableRate({
    super.key,
    required this.child,
    required this.value,
    this.snackbarMessage,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.mediumImpact();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(snackbarMessage ?? l10n.copied_snackbar(value)),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _copy(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
