import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact "when did this refresh" indicator, localised via the current
/// context's locale:
///   - same calendar day: `HH:mm` (e.g. 09:12)
///   - within the last 6 days: short weekday + time (e.g. Mon 09:12)
///   - older: short date (e.g. 24 Sep)
///
/// Rebuilds every 60 s so a stale timestamp visibly drifts into a less
/// prominent format without a page refresh.
class RelativeTime extends StatefulWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const RelativeTime({super.key, required this.dateTime, this.style});

  @override
  State<RelativeTime> createState() => _RelativeTimeState();
}

class _RelativeTimeState extends State<RelativeTime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final ts = widget.dateTime;
    final sameDay =
        ts.year == now.year && ts.month == now.month && ts.day == now.day;
    final ageDays = now.difference(ts).inDays;

    String text;
    if (sameDay) {
      text = DateFormat.Hm(locale).format(ts);
    } else if (ageDays < 6) {
      text = '${DateFormat.E(locale).format(ts)} '
          '${DateFormat.Hm(locale).format(ts)}';
    } else {
      text = DateFormat.MMMd(locale).format(ts);
    }
    return Text(text, style: widget.style);
  }
}
