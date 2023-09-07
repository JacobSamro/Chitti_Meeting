import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import '../modules/meeting_module/widgets/navigationbar.dart';
import '../services/locator.dart';
import '../services/responsive.dart';

extension Utils on BuildContext {
  static Timer? timer;
  static PersistentBottomSheetController? controller;
  void openFloatingNavigationBar() async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 3), () async {
      controller?.close();
      debugPrint("ksjlj");
      controller = null;
      timer?.cancel();
    });
    controller == null
        ? controller =
            locator<GlobalKey<ScaffoldState>>().currentState!.showBottomSheet(
                backgroundColor: Colors.white.withOpacity(0),
                (context) => Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const CustomNavigationBar()),
                        ],
                      ),
                    ))
        : null;
  }

   void showCustomSnackBar(
      {
      required String content,
      required String iconPath}) {
    final width = MediaQuery.of(this).size.width;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(this);
    final isDesktop = responsiveDevice == ResponsiveDevice.desktop;
    final textTheme = Theme.of(this).textTheme;
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(this).size.height * 0.1,
        left: width > 800 ? 40 : 0,
        child: Material(
          color: const Color(0xff191919),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xff2E2E2E),
              width: 1,
            ),
          ),
          child: Container(
            width: width > 800 ? 400 : width,
            height: isDesktop ? 44 : 36,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(iconPath,
                    height: isDesktop ? 24 : 20, width: isDesktop ? 24 : 20),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  content,
                  style: isDesktop
                      ? textTheme.bodySmall
                      : textTheme.bodySmall?.copyWith(fontSize: 12),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(this).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static void setWindowSize() {
    doWhenWindowReady(() {
      const initialSize = Size(1024, 800);
      appWindow.minSize = initialSize;
      appWindow.title = "Chitti Meet";
      appWindow.size = initialSize;
      appWindow.startDragging();
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}
