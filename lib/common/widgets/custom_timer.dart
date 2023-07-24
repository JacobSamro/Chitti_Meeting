import 'dart:async';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomTimer extends ConsumerStatefulWidget {
  const CustomTimer({
    super.key,
  });
  @override
  ConsumerState<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends ConsumerState<CustomTimer> {
  late Timer timer;
  Duration duration = const Duration();
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() async {
    final currentTime = await locator<MeetingRepositories>().getDateTime();
    final meetingTime = ref.read(workshopDetailsProvider).scheduledAt;
    final difference =
        DateTime.parse(currentTime).difference(DateTime.parse(meetingTime!));
    duration = Duration(seconds: difference.inSeconds);
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          duration += const Duration(milliseconds: 30);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
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
            color: Colors.white,
            fontSize: responsiveDevice != ResponsiveDevice.mobile ? 12 : 10),
      ),
    );
  }
}
