import 'package:flutter/material.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../routes.dart';
import '../../../services/responsive.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    final bool isDesktop = responsiveDevice == ResponsiveDevice.desktop;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "404",
              style:
                  textTheme.titleLarge?.copyWith(fontSize: isDesktop ? 88 : 64),
            ),
            SizedBox(
              height: isDesktop ? 24 : 14,
            ),
            Text(
              "The page you are looking for is not found",
              style:
                  isDesktop ? textTheme.displayMedium : textTheme.displaySmall,
            ),
            SizedBox(
              height: isDesktop ? 64 : 40,
            ),
            GestureDetector(
              onTap: () {
                router.go('/');
              },
              child: CustomButton(
                child: Center(
                  child: Text(
                    "Go to home page",
                    style: textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontSize: isDesktop ? 18 : 14,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
