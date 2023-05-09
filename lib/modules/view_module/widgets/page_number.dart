import 'package:flutter/material.dart';

class PageNumber extends StatefulWidget {
  const PageNumber({
    super.key,
    required PageController pageController,
  }) : _pageController = pageController;

  final PageController _pageController;

  @override
  State<PageNumber> createState() => _PageNumberState();
}

class _PageNumberState extends State<PageNumber> {
  @override
  void initState() {
    super.initState();
    widget._pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      "Page 0 of 200",
      style: textTheme.displaySmall?.copyWith(fontSize: 12),
    );
  }
}
