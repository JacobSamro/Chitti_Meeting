import 'package:chitti_meeting/modules/view_module/widgets/local_user.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';

import '../../../services/locator.dart';
import '../widgets/custom_video_player.dart';
import '../widgets/page_number.dart';

class SpeakerView extends StatefulWidget {
  const SpeakerView({super.key});

  @override
  State<SpeakerView> createState() => _SpeakerViewState();
}

class _SpeakerViewState extends State<SpeakerView> {
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
                  if (snap.hasData) {
                    final List<dynamic> participants = [];
                    participants.add(
                      {
                        'isHost': true,
                        'src':
                            "https://chitti-cloud-hls-server.canary.lmesacademy.net/c3778ac9-fae5-4f02-beec-1ddd63b6c2cb/master.m3u8"
                      },
                    );
                    participants.add({
                      'isHost': false,
                    });
                    snap.data!.removeAt(0);
                    for (var e in snap.data!) {
                      participants.add(e);
                    }
                    return PageView.builder(
                        controller: _pageController,
                        itemCount: participants.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return !participants[index]
                                  .runtimeType
                                  .toString()
                                  .contains('Map')
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 200,
                                        child: participants[index].videoEnabled
                                            ? VideoView(
                                                meetingParticipant:
                                                    participants[index],
                                              )
                                            : Center(
                                                child: Container(
                                                // padding: const EdgeInsets.all(15),
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: Center(
                                                  child: Text(
                                                    participants[index]
                                                        .name
                                                        .substring(0, 1)
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              )),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Text(participants[index].name)),
                                  ],
                                )
                              : participants[index]['isHost']
                                  ? Center(
                                      child: CustomVideoPlayer(
                                          src: participants[index]['src']),
                                    )
                                  : const Center(child: LocalUser());
                        });
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
