import 'package:chitti_meet/common/widgets/dropdown_item.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown(
      {super.key,
      required this.items,
      required this.value,
      required this.onChanged});
  final String value;
  final List<CustomDropDownItem> items;
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
              border: Border.all(
                width: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map(
                (e) {
                  e.selected = value == e.value;
                  return GestureDetector(
                    onTap: () {
                      onChanged(e.value);
                    },
                    child: e,
                  );
                },
              ).toList(),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: width > 800 ? 70 : 0,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
