import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterGifController controller;
  final time = {"Days": "00", "Hours": "00", "Minutes": "00", "Seconds": "00"};
  late final AssetImage image;
  @override
  void initState() {
    super.initState();
    image = const AssetImage('assets/images/waiting_animation.gif');
    controller = FlutterGifController(vsync: this);
    controller.repeat(min: 0, max: 106, period: const Duration(seconds: 6));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              // fit: BoxFit.cover,
            ).image,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 250,
                width: 250,
                child: GifImage(image: image, controller: controller)),
            Text(
              "Workshop will be live in",
              style: textTheme.titleLarge,
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: time.entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          height: 74,
                          width: 70,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(e.value),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                e.key,
                                style: textTheme.displaySmall
                                    ?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList()),
          ],
        ),
      ),
    );
  }
}
