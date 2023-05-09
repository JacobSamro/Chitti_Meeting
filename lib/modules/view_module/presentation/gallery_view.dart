import 'package:chitti_meeting/modules/view_module/widgets/local_user.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';

import '../../../services/locator.dart';
import '../widgets/custom_video_player.dart';
import '../widgets/page_number.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
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
            child: LayoutBuilder(builder: (context, constrain) {
              final data = (constrain.maxHeight / 200);

              return StreamBuilder(
                  stream: locator<DyteMobileClient>().activeStream,
                  builder: (context, snap) {
                    final List<List<dynamic>> participants = [];
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
                        // for (int i = 0; i < 2; i++) {
                        //   participants[0].add(snap.data![i]);
                        //   snap.data!.removeAt(i);
                        // }
                        for (int i = 0; i < snap.data!.length; i += 4) {
                          participants.add(snap.data!.sublist(
                              i,
                              snap.data!.length - i >= 4
                                  ? i + 4
                                  : snap.data!.length));
                        }
                      } else {
                        participants.add([
                          DyteMeetingParticipant(
                              id: localUser.id,
                              userId: localUser.userId,
                              name: localUser.name,
                              isHost: localUser.isHost,
                              flags: localUser.flags,
                              audioEnabled: localUser.audioEnabled,
                              videoEnabled: localUser.videoEnabled)
                        ]);
                      }
                      return PageView.builder(
                          controller: _pageController,
                          itemCount: participants.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final data = participants[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GridView.builder(
                                  itemCount: data.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12),
                                  itemBuilder: (context, index) {
                                    return !data[index]
                                            .runtimeType
                                            .toString()
                                            .contains('Map')
                                        ? Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  height: 200,
                                                  child: data[index]
                                                          .videoEnabled
                                                      ? VideoView(
                                                          meetingParticipant:
                                                              data[index],
                                                        )
                                                      : Center(
                                                          child: Container(
                                                          // padding: const EdgeInsets.all(15),
                                                          width: 80,
                                                          height: 80,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                          child: Center(
                                                            child: Text(
                                                              data[index]
                                                                  .name
                                                                  .substring(
                                                                      0, 1)
                                                                  .toUpperCase(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        )),
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: 10,
                                                  right: 10,
                                                  child:
                                                      Text(data[index].name)),
                                            ],
                                          )
                                        : data[index]['isHost']
                                            ? CustomVideoPlayer(
                                                src: data[index]['src'])
                                            : const Center(child: LocalUser());
                                  }),
                            );
                          });
                    }
                    return const Center(child: CircularProgressIndicator());
                  });
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
