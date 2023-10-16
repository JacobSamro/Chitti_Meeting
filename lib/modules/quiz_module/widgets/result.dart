import 'package:flutter/material.dart';

import '../../../services/responsive.dart';

class QuizResult extends StatelessWidget {
  const QuizResult({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDesktop =
        Responsive().getDeviceType(context) == ResponsiveDevice.desktop;
    return SizedBox(
      width: 700,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/puzzle.png',
                width: 14,
                height: 14,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                'QUESTION 1',
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.purple[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Who is Modi’s crush?',
            style: isDesktop ? textTheme.bodyMedium : textTheme.bodySmall,
          ),
          const SizedBox(
            height: 20,
          ),
          ...List.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: isDesktop
                            ? Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                        child: Image.asset(
                                      'assets/icons/cross_shaped.png',
                                      width: 38,
                                      height: 38,
                                    )),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Giorgia Meloni',
                                              style: isDesktop
                                                  ? textTheme.displayMedium
                                                  : textTheme.displaySmall,
                                            ),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/avatars.png',
                                                  width: 112,
                                                  height: 32,
                                                ),
                                                Text.rich(TextSpan(
                                                    text: '400\n',
                                                    style: textTheme
                                                        .displaySmall
                                                        ?.copyWith(
                                                            fontSize: 12),
                                                    children: const [
                                                      TextSpan(text: 'students')
                                                    ]))
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        LinearProgressIndicator(
                                          value: 0.2,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.08),
                                          minHeight: 12,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.red[500]!),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                            child: Image.asset(
                                          'assets/icons/cross_shaped.png',
                                          width: 14,
                                          height: 14,
                                        )),
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/avatars.png',
                                            width: 88,
                                            height: 24,
                                          ),
                                          Text.rich(TextSpan(
                                              text: '400',
                                              style: textTheme.displaySmall
                                                  ?.copyWith(fontSize: 12),
                                              children: const [
                                                TextSpan(text: 'students')
                                              ]))
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  LinearProgressIndicator(
                                    value: 0.2,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.08),
                                    minHeight: 5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red[500]!),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    'Giorgia Meloni',
                                    style: textTheme.labelSmall,
                                  ),
                                ],
                              )),
                  ))
        ],
      ),
    );
  }
}
