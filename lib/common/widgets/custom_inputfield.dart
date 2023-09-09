import 'package:flutter/material.dart';
import '../../services/responsive.dart';

class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool obscureText = false;
  @override
  void initState() {
    super.initState();
    obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final responsiveDevice = Responsive().getDeviceType(context);
    return SizedBox(
      width: responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
      height: responsiveDevice != ResponsiveDevice.mobile ? 48 : 52,
      child: TextField(
        controller: widget.controller,
        obscureText: obscureText,
        textAlign: TextAlign.center,
        style: textTheme.labelSmall
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          hintText: widget.label,
          suffixIcon: widget.obscureText
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: Image.asset(
                        obscureText
                            ? 'assets/icons/hide_password.png'
                            : 'assets/icons/show_password.png',
                        width: 24,
                        height: 24,
                      )),
                )
              : null,
          hintStyle: textTheme.labelSmall
              ?.copyWith(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
