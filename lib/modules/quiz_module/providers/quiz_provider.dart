import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionNotifier extends StateNotifier{
  QuestionNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
}

final questionProvider = StateNotifierProvider((ref) => QuestionNotifier());

class AnswerNotifer extends StateNotifier<int>{
  AnswerNotifer() : super(0);
  void selectAnswer(int index) => state = index;
}

final answerProvider = StateNotifierProvider<AnswerNotifer,int>((ref) => AnswerNotifer());

class QuizStateNotifier extends StateNotifier<QuizState>{
  QuizStateNotifier() : super(QuizState.loading);

  void changeState(QuizState newState){
    state=newState;
  }
}

final quizStateProvider =StateNotifierProvider<QuizStateNotifier,QuizState>((ref) => QuizStateNotifier());

enum QuizState{
  loading,
  quiz,
  result,
  leaderBoard
}