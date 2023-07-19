import 'dart:async';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';

class CustomTimer extends StatefulWidget {
  const CustomTimer({
    super.key,
    required this.stopwatch,
  });
  final Stopwatch stopwatch;
  @override
  State<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends State<CustomTimer> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    widget.stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    final duration =
        Duration(milliseconds: widget.stopwatch.elapsedMilliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        '$twoDigitMinutes:$twoDigitSeconds',
        style: textTheme.displaySmall?.copyWith(
            fontSize: responsiveDevice != ResponsiveDevice.mobile ? 12 : 10),
      ),
    );
  }
}
