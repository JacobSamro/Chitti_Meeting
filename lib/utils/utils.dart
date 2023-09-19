import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../modules/meeting_module/widgets/navigationbar.dart';
import '../services/locator.dart';
import '../services/responsive.dart';
import 'package:universal_html/html.dart' as html;

extension Utils on BuildContext {
  static Timer? timer;
  static PersistentBottomSheetController? controller;
  void openFloatingNavigationBar() async {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 5), () async {
      controller?.close();
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

  void showCustomSnackBar({required String content, required String iconPath}) {
    final width = MediaQuery.of(this).size.width;
    final ResponsiveDevice responsiveDevice = Responsive().getDeviceType(this);
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

  Future<bool> requestCameraPermission() async {
    try {
      await html.window.navigator.mediaDevices!.getUserMedia({'video': true});
    } catch (e) {
      if (e is html.DomException && e.name == 'NotAllowedError') {
        showCustomSnackBar(
            content: 'Enable Camera Permission in Settings',
            iconPath: 'assets/icons/info.png');
      }
      return false;
    }
    return true;
  }

  Future<bool> handleMediaError(Object error) async {
    debugPrint(error.runtimeType.toString());
    if (error is String) {
      showCustomSnackBar(
          content: 'Enable Camera Permission in Settings',
          iconPath: 'assets/icons/info.png');
      return false;
    }
    if (error is CameraException && error.code == 'cameraMissingMetadata') {
      debugPrint("Camera Missing");
      showCustomSnackBar(
          content: 'Enable Camera Permission in Settings',
          iconPath: 'assets/icons/info.png');
      return false;
    }
    if (error is CameraException && error.code == 'CameraAccessDenied') {
      if (!kIsWeb) {
        await Permission.camera.request();
        return true;
      }
      await requestCameraPermission();
      return true;
    }
    // throw Exception(error);
    return false;
  }
}
