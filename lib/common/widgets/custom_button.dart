import 'package:flutter/material.dart';

import '../../services/responsive.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.child,
      this.width,
      this.height,
      this.color = Colors.white});
  final Widget child;
  final double? width;
  final double? height;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final responsiveDevice = Responsive().getDeviceType(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width:
            width ?? (responsiveDevice != ResponsiveDevice.mobile ? 480 : 300),
        height:
            height ?? (responsiveDevice != ResponsiveDevice.mobile ? 52 : 48),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}
