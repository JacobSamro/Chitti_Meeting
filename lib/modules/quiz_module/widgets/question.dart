import 'package:chitti_meet/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_provider.dart';

class QuizQuestion extends ConsumerWidget {
  const QuizQuestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop =
        Responsive().getDeviceType(context) == ResponsiveDevice.desktop;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int selectAnswer = ref.watch(answerProvider);
    return SizedBox(
      width: 700,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: 0.2,
            backgroundColor: Colors.white.withOpacity(0.08),
            minHeight: isDesktop ? 12 : 8,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[500]!),
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'QUESTION 1/10',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.purple[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xffF97316),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text('0:30', style: textTheme.bodySmall),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Who is Modi’s crush?',
            style: isDesktop ? textTheme.bodyLarge : textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          ...List.generate(
              3,
              (index) => GestureDetector(
                    onTap: () {
                      ref.read(answerProvider.notifier).selectAnswer(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectAnswer == index
                              ? const Color(0xff0EA5E9).withOpacity(0.05)
                              : Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selectAnswer == index
                                ? const Color(0xff0EA5E9)
                                : Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              // padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selectAnswer == index
                                    ? const Color(0xff0EA5E9)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text('${index + 1}',
                                    style: textTheme.labelSmall?.copyWith(
                                        color: Colors.white, fontSize: 12)),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              'Giorgia Meloni',
                              style: isDesktop
                                  ? textTheme.labelMedium?.copyWith(
                                      color: selectAnswer == index
                                          ? const Color(0xff0EA5E9)
                                          : Colors.white.withOpacity(0.75))
                                  : textTheme.labelSmall?.copyWith(
                                      color: selectAnswer == index
                                          ? const Color(0xff0EA5E9)
                                          : Colors.white.withOpacity(0.75)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
        ],
      ),
    );
  }
}
