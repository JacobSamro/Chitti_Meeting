import 'package:chitti_meet/modules/quiz_module/providers/quiz_provider.dart';
import 'package:chitti_meet/modules/quiz_module/widgets/leaderboard.dart';
import 'package:chitti_meet/modules/quiz_module/widgets/question.dart';
import 'package:chitti_meet/modules/quiz_module/widgets/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuizState quizState = ref.watch(quizStateProvider);
    return Dialog(
      backgroundColor: const Color(0xff191919),
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.05)),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/close.png',
                            height: 10,
                            width: 10,
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(child: setScreen(quizState)),
            ],
          )),
    );
  }

  Widget setScreen(state) {
    switch (state) {
      case QuizState.quiz:
        return const QuizQuestion();
      case QuizState.result:
        return const QuizResult();
      case QuizState.leaderBoard:
        return const QuizLeaderboard();
      default:
        return const CircularProgressIndicator();
    }
  }
}
