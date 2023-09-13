import 'package:flutter/material.dart';

class ControlButtton extends StatefulWidget {
  const ControlButtton(
      {super.key,
      required this.hoverColor,
      required this.iconPath,
      required this.onTap,
      this.tooltip});
  final Color hoverColor;
  final String iconPath;
  final VoidCallback onTap;
  final String? tooltip;
  @override
  State<ControlButtton> createState() => _ControlButttonState();
}

class _ControlButttonState extends State<ControlButtton> {
  Color buttonColor = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: const Duration(seconds: 2),
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              buttonColor = widget.hoverColor;
            });
          },
          onExit: (_) {
            setState(() {
              buttonColor = Colors.transparent;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 32,
            color: buttonColor,
            child: Image.asset(
              widget.iconPath,
              width: 14,
              height: 14,
            ),
          ),
        ),
      ),
    );
  }
}
