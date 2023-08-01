import 'dart:async';
import 'package:chitti_meeting/modules/meeting_module/models/workshop_model.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});
  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterGifController controller;
  Duration elapsedTime = const Duration();
  Timer _timer = Timer(const Duration(), () {});
  late final AssetImage image;
  @override
  void initState() {
    super.initState();
    image = const AssetImage('assets/images/waiting_animation.gif');
    startTimer();
    controller = FlutterGifController(vsync: this);
    controller.repeat(min: 0, max: 106, period: const Duration(seconds: 6));
  }

  Future<void> startTimer() async {
    final Workshop workshop = ref.read(workshopDetailsProvider);
    final loalTime = await locator<MeetingRepositories>().getDateTime();
    DateTime currentTime = DateTime.parse(loalTime);
    final DateTime meetingTime = DateTime.parse(workshop.scheduledAt!).subtract(const Duration(minutes: 10));
    elapsedTime = currentTime.toUtc().difference(meetingTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      currentTime = currentTime.add(const Duration(seconds: 1));
      setState(() {
        elapsedTime = currentTime.toUtc().difference(meetingTime);
      });
      if (elapsedTime == Duration.zero) {
        await ref
        .read(workshopDetailsProvider.notifier)
        .getWorkshopDetials(ref.read(workshopDetailsProvider.notifier).hashId);
        await locator<MeetingRepositories>().addParticipant(
            ref.read(participantProvider.notifier).participantName,
            locator<Room>(),
            workshop.meetingId!,
            false,
            ref);
            _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Map<String, dynamic> formattedTime = timeFormat(elapsedTime);
    final ResponsiveDevice responsiveDevice=Responsive().getDeviceType(context);
    final bool isDesktop=responsiveDevice==ResponsiveDevice.desktop;
    return Scaffold(
      body: _timer.isActive
          ? Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    // fit: BoxFit.cover,
                  ).image,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 250,
                      width: 250,
                      child: GifImage(image: image, controller: controller)),
                  Text(
                    "Workshop will be live in",
                    style:isDesktop?textTheme.titleLarge?.copyWith(fontSize: 24):textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: formattedTime.entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                height: 74,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(e.value.toString(),
                                   style:isDesktop?textTheme.titleLarge?.copyWith(fontSize: 34,fontWeight: FontWeight.w900):textTheme.titleLarge?.copyWith(fontSize: 18,fontWeight: FontWeight.w900)
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      e.key,
                                      style:isDesktop?textTheme.displayLarge?.copyWith(fontSize: 18): textTheme.displaySmall
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList()),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Map<String, dynamic> timeFormat(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    String days = twoDigits(duration.inDays.abs());
    String hours = twoDigits(duration.inHours.remainder(24).abs());
    return {
      'Days': days,
      'Hours': hours,
      'Minutes': twoDigitMinutes,
      'seconds': twoDigitSeconds
    };
  }
}
