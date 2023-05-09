import 'package:chitti_meeting/modules/view_module/widgets/custom_video_player.dart';
import 'package:chitti_meeting/modules/view_module/widgets/local_user.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';

import '../widgets/page_number.dart';

class StandardView extends StatefulWidget {
  const StandardView({super.key});

  @override
  State<StandardView> createState() => _StandardViewState();
}

class _StandardViewState extends State<StandardView> {
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
                stream: locator<DyteMobileClient>().activeStream,
                builder: (context, snap) {
                  final List<List<dynamic>>participants = [];
                  if (snap.hasData) {
                    final localUser = client.localUser;
                    if (snap.data!.length > 1) {
                      participants.add([
                        {
                          'isHost': true,
                          'src':
                              "https://chitti-cloud-hls-server.canary.lmesacademy.net/c3778ac9-fae5-4f02-beec-1ddd63b6c2cb/master.m3u8"
                        },
                        {
                          'isHost': false,
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
                          'isHost': false,
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
                            .map(
                              (e) => !e.runtimeType.toString().contains('Map')
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
                                                  : Center(
                                                      child: Container(
                                                      // padding: const EdgeInsets.all(15),
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50)),
                                                      child: Center(
                                                        child: Text(
                                                          '${e.name}'
                                                              .substring(0, 1)
                                                              .toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                    ))),
                                        ),
                                        Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Text(
                                                '${e.name}(${e.isHost ? 'H' : 'P'})')),
                                      ],
                                    )
                                  :e['isHost']?CustomVideoPlayer(src: e['src']):const LocalUser(),
                            )
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
