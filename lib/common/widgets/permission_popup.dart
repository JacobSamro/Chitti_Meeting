import 'package:chitti_meet/services/responsive.dart';
import 'package:flutter/material.dart';

class PermissionPopup extends StatelessWidget {
  const PermissionPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final isDesktop =
        Responsive().getDeviceType(context) == ResponsiveDevice.desktop;
    return AlertDialog(
      backgroundColor: const Color(0xff191919),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      content: Container(
          padding: const EdgeInsets.all(20),
          width: isDesktop ? null : 570,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.asset('assets/images/popup_bg.png').image,
                alignment: Alignment.topLeft,
                fit: BoxFit.contain),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.05)),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/close.png',
                            height: 10,
                            width: 10,
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              isDesktop
                  ? Row(children: [
                      Image.asset(
                        'assets/images/popup.png',
                        width: 380,
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chitti Meet is blocked from using your camera',
                            style: textTheme.bodyLarge?.copyWith(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(children: [
                            Text('1.Click the ', style: textTheme.labelMedium),
                            Image.asset('assets/icons/lock.png', width: 20),
                            Text('icon in your browser’s address bar',
                                style: textTheme.labelMedium),
                          ]),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('2.Click the camera',
                              style: textTheme.labelMedium),
                        ],
                      ),
                    ])
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Center(
                            child: Image.asset('assets/images/popup_mobile.png',
                                height: 216),
                          ),
                          const SizedBox(height: 36),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chitti Meet is blocked from using your camera',
                                maxLines: 2,
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Wrap(children: [
                                Text(
                                  '1.Click the ',
                                  style: textTheme.labelSmall,
                                ),
                                Image.asset('assets/icons/settings.png',
                                    width: 20),
                                Text('icon in your browser’s address bar',
                                    style: textTheme.labelSmall),
                              ]),
                              const SizedBox(
                                height: 12,
                              ),
                              Text('2.Turn on permissions',
                                  style: textTheme.labelSmall),
                              const SizedBox(
                                height: 12,
                              ),
                              Text('3.Turn on camera & microphone',
                                  style: textTheme.labelSmall),
                            ],
                          ),
                        ])
            ],
          )),
    );
  }
}
