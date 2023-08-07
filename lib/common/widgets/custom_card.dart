import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
      {super.key,
      required this.iconPath,
      required this.content,
      this.actions = const <Widget>[]});
  final String iconPath;
  final Widget content;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        // height: 350,
        width: 450,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(
            iconPath,
            width: 80,
            height: 80,
          ),
          const SizedBox(
            height: 18,
          ),
          content,
          SizedBox(
            height: actions.isNotEmpty ? 40 : 0,
          ),
          actions.isNotEmpty
              ? width < 450
                  ? Column(
                      children: actions
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(width: 400, child: e),
                              ))
                          .toList(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: actions
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(width: 150, child: e),
                              ))
                          .toList(),
                    )
              : const SizedBox.shrink(),
        ]),
      ),
    );
  }
}
