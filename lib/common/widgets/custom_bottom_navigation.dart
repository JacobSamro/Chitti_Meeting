import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation(
      {super.key, required this.items, required this.onChanged});
  final List<CustomBottomNavigationItem> items;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: items
              .map((e) => GestureDetector(
                  onTap: () {
                    onChanged(e.label);
                  },
                  child: e))
              .toList(),
        ),
      ),
    );
  }
}

class CustomBottomNavigationItem extends StatelessWidget {
  const CustomBottomNavigationItem(
      {super.key, required this.iconPath, required this.label});
  final String iconPath;
  final String label;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 76,
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
    );
  }
}
