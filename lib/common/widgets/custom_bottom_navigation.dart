import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation(
      {super.key,
      required this.items,
      required this.onChanged,
      this.leading,
      this.actions});
  final List<CustomBottomNavigationItem?> items;
  final Widget? leading;
  final List<CustomBottomNavigationItem>? actions;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 70,
      child: leading != null && actions != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading != null
                    ? Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: leading,
                        ),
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((e) {
                    return e == null
                        ? const SizedBox()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    onChanged(e.label);
                                  },
                                  child: e),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16.0, right: 15, left: 5),
                                child: e.suffixIcon,
                              )
                            ],
                          );
                  }).toList(),
                ),
                actions != null
                    ? Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: actions!
                                .map((e) => GestureDetector(
                                    onTap: () {
                                      onChanged(e.label);
                                    },
                                    child: e))
                                .toList(),
                          ),
                        ),
                      )
                    : const SizedBox()
              ],
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: items.map((e) {
                return e == null
                    ? const SizedBox()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: () {
                                onChanged(e.label);
                              },
                              child: e),
                          e.suffixIcon != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, left: 5, right: 15),
                                  child: e.suffixIcon,
                                )
                              : const SizedBox()
                        ],
                      );
              }).toList(),
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
      this.visible = true,
      this.badgeValue = 0,
      this.suffixIcon});
  final String iconPath;
  final String label;
  final bool badge;
  final bool visible;
  final int badgeValue;
  final Widget? suffixIcon;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return visible
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Center(
              child: Container(
                  padding: EdgeInsets.only(
                      right: suffixIcon != null ? 0 : 15, left: 15),
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
                              style:
                                  textTheme.labelSmall?.copyWith(fontSize: 10),
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
                                  style: textTheme.labelSmall
                                      ?.copyWith(fontSize: 10),
                                )
                              ],
                            )
                          ],
                        )),
            ),
          )
        : const SizedBox();
  }
}
