import 'package:flutter/material.dart';
import 'package:dinar_echange/utils/formatters.dart';
import 'package:dinar_echange/utils/minute_clock.dart';

/// Compact "when did this refresh" indicator, localised via the current
/// context's locale:
///   - same calendar day: `HH:mm` (e.g. 09:12)
///   - within the last 6 days: short weekday + time (e.g. Mon 09:12)
///   - older: short date (e.g. 24 Sep)
///
/// Rebuilds when the shared [MinuteClock] ticks so a stale timestamp
/// visibly drifts into a less prominent format without the widget
/// having to hold its own Timer.
class RelativeTime extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const RelativeTime({super.key, required this.dateTime, this.style});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final fmt = LocaleFormatters.of(locale);
    return ValueListenableBuilder<DateTime>(
      valueListenable: MinuteClock.instance.tick,
      builder: (context, now, _) {
        final ts = dateTime;
        final sameDay =
            ts.year == now.year && ts.month == now.month && ts.day == now.day;
        final ageDays = now.difference(ts).inDays;
        final String text;
        if (sameDay) {
          text = fmt.Hm.format(ts);
        } else if (ageDays < 6) {
          text = '${fmt.E.format(ts)} ${fmt.Hm.format(ts)}';
        } else {
          text = fmt.MMMd.format(ts);
        }
        return Text(text, style: style);
      },
    );
  }
}
