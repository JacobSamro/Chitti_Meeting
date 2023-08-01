import 'dart:async';
import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import '../modules/meeting_module/widgets/navigationbar.dart';

class Utils {
  static Timer? timer;
  static PersistentBottomSheetController? controller;
  static openFloatingNavigationBar(context) async {
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

  static void showCustomSnackBar(
      {required BuildContext buildContext,
      required String content,
      required String iconPath}) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(buildContext).size.height * 0.1,
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
            width: MediaQuery.of(buildContext).size.width > 800
                ? 400
                : MediaQuery.of(buildContext).size.width,
            height: 36,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(iconPath, height: 20, width: 20),
                const SizedBox(
                  width: 6,
                ),
                Text(content,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(buildContext).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
