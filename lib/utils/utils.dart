import 'package:flutter/material.dart';

import '../modules/meeting_module/widgets/navigationbar.dart';

class Utils {
  static openFloatingNavigationBar(context) async {
    showModalBottomSheet(
        barrierColor: Colors.white.withOpacity(0),
        backgroundColor: Colors.white.withOpacity(0),
        // isDismissible: false,
        constraints: const BoxConstraints(maxWidth: 600),
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const CustomNavigationBar()),
            ));
    // await Future.delayed(const Duration(seconds: 2), () {
    //   // if (Navigator.canPop(context)) {
    //   //   Navigator.pop(context);
    //   // }
    //   print("object");
    // });
  }

  static void showCustomSnackBar(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xff191919),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white.withOpacity(0.1))),
        // margin: EdgeInsets.only(
        //     bottom: MediaQuery.of(context).size.height * 0.9),
        behavior: SnackBarBehavior.floating,
        content: const SizedBox(
          // height: 36,
          child: Text(
            "Mic was disabled by the host",
            style: TextStyle(color: Colors.white),
          ),
        ),
        dismissDirection: DismissDirection.up,
      ),
    );
  }
}
