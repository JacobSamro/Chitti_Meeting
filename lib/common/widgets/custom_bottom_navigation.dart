import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation(
      {super.key, required this.items, required this.onChanged});
  final List<CustomBottomNavigationItem> items;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 70,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: items
            .map((e) => GestureDetector(
                onTap: () {
                  onChanged(e.label);
                },
                child: e))
            .toList(),
      ),
    );
  }
}

class CustomBottomNavigationItem extends StatelessWidget {
  const CustomBottomNavigationItem(
      {super.key,
      required this.iconPath,
      required this.label,
      this.badge = false,
      this.badgeValue = 0});
  final String iconPath;
  final String label;
  final bool badge;
  final int badgeValue;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Center(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 49,
            child: !badge
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        iconPath,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: textTheme.labelSmall?.copyWith(fontSize: 10),
                      )
                    ],
                  )
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      badgeValue != 0
                          ? Positioned(
                              top: -10,
                              right: -6,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    badgeValue.toString(),
                                    style: textTheme.bodySmall
                                        ?.copyWith(fontSize: 10),
                                  )),
                            )
                          : const SizedBox(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            iconPath,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: textTheme.labelSmall?.copyWith(fontSize: 10),
                          )
                        ],
                      )
                    ],
                  )),
      ),
    );
  }
}
