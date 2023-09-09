import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class CustomDropDownItem extends ConsumerWidget {
  CustomDropDownItem({
    this.selected,
    required this.value, 
    super.key,
    required this.label,
  });
  final String label;
  bool? selected;
  final String value;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Row(
          children: [
            selected!
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/icons/check.png',
                      width: 16,
                      height: 16,
                    ),
                  )
                : const SizedBox(),
            Text(
              label,
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
