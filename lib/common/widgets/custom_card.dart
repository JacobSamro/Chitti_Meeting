import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
      {super.key,
      required this.iconPath,
      required this.content,
      required this.actions});
  final String iconPath;
  final String content;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 296,
      width: 300,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(children: [
        Image.asset(
          iconPath,
          width: 80,
          height: 80,
        ),
        const SizedBox(
          height: 18,
        ),
        Text(
          content,
          style: textTheme.titleLarge,
        ),
        const SizedBox(
          height: 40,
        ),
        actions.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions,
              )
            : const SizedBox.shrink(),
      ]),
    );
  }
}
