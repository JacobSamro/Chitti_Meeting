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
      height: 76,
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
      this.badgeType = BadgeType.dot});
  final String iconPath;
  final String label;
  final bool badge;
  final BadgeType badgeType;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 49,
        child: Column(
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
        ),
      ),
    );
  }
}

enum BadgeType { dot, number }
