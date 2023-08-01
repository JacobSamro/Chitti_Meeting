import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/meeting_module/states/meeting_states.dart';
import '../../modules/view_module/providers/view_provider.dart';

class SwitchViewItem extends ConsumerWidget {
  const SwitchViewItem({
    super.key,
    required this.label,
    required this.onTap,
  });
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final ViewType viewType = ref.watch(viewProvider).viewType;
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: Row(
            children: [
              viewType.name == label.split(' ')[0].toLowerCase()
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
      ),
    );
  }
}
