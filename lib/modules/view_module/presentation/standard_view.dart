import 'package:chitti_meeting/modules/view_module/widgets/custom_video_player.dart';
import 'package:chitti_meeting/modules/view_module/widgets/local_user.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/page_number.dart';

class StandardView extends ConsumerStatefulWidget {
  const StandardView({super.key});

  @override
  ConsumerState<StandardView> createState() => _StandardViewState();
}

class _StandardViewState extends ConsumerState<StandardView> {
  late final PageController _pageController;
  final DyteMobileClient client = locator<DyteMobileClient>();
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // ref.watch(cameraProvider);
    // final isVideoOn = ref.read(cameraProvider.notifier).isVideoOn;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.meta.meetingTitle,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(
                  width: 6,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    client.meta.meetingStartedTimeStamp,
                    style: textTheme.displaySmall?.copyWith(fontSize: 10),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: client.activeStream,
                builder: (context, snap) {
                  final List<List<dynamic>> participants = [];
                  if (snap.hasError) {
                    return Center(
                      child: Text(snap.error.toString()),
                    );
                  }
                  if (snap.hasData) {
                    // final localUser = client.localUser;
                    if (snap.data!.length > 1) {
                      participants.add([
                        {
                          'isHost': true,
                          "name": "host",
                          'src':
                              "https://chitti-cloud-hls-server.canary.lmesacademy.net/9d895280-eab9-404b-a77d-39338dcba2ba/master.m3u8"
                        },
                        {
                          'isHost': false,
                          "name": snap.data![0].name,
                        },
                      ]);
                      snap.data!.removeAt(0);
                      for (int i = 0; i < snap.data!.length; i += 2) {
                        participants.add(snap.data!.sublist(
                            i,
                            snap.data!.length - i >= 2
                                ? i + 2
                                : snap.data!.length));
                      }
                    } else {
                      participants.add([
                        {
                          'isHost': true,
                          "name": "host",
                          'src':
                              "https://chitti-cloud-hls-server.canary.lmesacademy.net/9d895280-eab9-404b-a77d-39338dcba2ba/master.m3u8"
                        },
                        {
                          'isHost': false,
                          "name": snap.data![0].name,
                        },
                      ]);
                    }
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: participants.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: participants[index]
                            .map((e) => !e.runtimeType
                                    .toString()
                                    .contains('Map')
                                ? Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 200,
                                          child: e.videoEnabled
                                              ? VideoView(
                                                  meetingParticipant: e,
                                                )
                                              : const ParticipantWithoutVideo(),
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${e.name}',
                                                    style: textTheme.labelSmall
                                                        ?.copyWith(
                                                            fontSize: 12),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Image.asset(
                                                    'assets/icons/mic_off.png',
                                                    width: 16,
                                                    height: 16,
                                                  )
                                                ],
                                              )))
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      e['isHost']
                                          ? CustomVideoPlayer(src: e['src'])
                                          : client.localUser.videoEnabled
                                              ? const LocalUser()
                                              : const ParticipantWithoutVideo(),
                                      Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${e['name']}',
                                                    style: textTheme.labelSmall
                                                        ?.copyWith(
                                                            fontSize: 12),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Image.asset(
                                                    e['isHost']
                                                        ? 'assets/icons/mic.png'
                                                        : 'assets/icons/mic_off.png',
                                                    width: 16,
                                                    height: 16,
                                                    color: e['isHost']
                                                        ? Colors.green
                                                        : null,
                                                  )
                                                ],
                                              )))
                                    ],
                                  ))
                            .toList(),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 1),
                          curve: Curves.ease);
                    },
                    child: Image.asset(
                      'assets/icons/arrow_left.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  PageNumber(pageController: _pageController),
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 1),
                          curve: Curves.ease);
                    },
                    child: Image.asset(
                      'assets/icons/arrow_right.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}

class ParticipantWithoutVideo extends StatelessWidget {
  const ParticipantWithoutVideo({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: 200,
        color: Colors.white.withOpacity(0.06),
        child: Center(
            child: Image.asset(
          'assets/icons/user_rounded.png',
          width: 44,
          height: 44,
        )));
  }
}
