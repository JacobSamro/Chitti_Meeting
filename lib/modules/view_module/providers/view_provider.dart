import 'package:chitti_meet/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../meeting_module/states/meeting_states.dart';
import '../models/view_state.dart';

class ViewNotifier extends StateNotifier<ViewState> {
  ViewNotifier(super.state);
  void changeViewType(ViewType type) {
    if (defaultTargetPlatform != TargetPlatform.windows &&
        state.viewType == ViewType.fullScreen &&
        type != ViewType.fullScreen) {
      Utils.timer!.cancel();
    }
    state = ViewState(
        viewType: type, chat: state.chat, participants: state.participants);
  }

  void openChatInDesktop(bool value) {
    state =
        ViewState(viewType: state.viewType, chat: value, participants: false);
  }

  void openParticipantsInDesktop(bool value) {
    state =
        ViewState(viewType: state.viewType, chat: false, participants: value);
  }
}

final StateNotifierProvider<ViewNotifier, ViewState> viewProvider =
    StateNotifierProvider<ViewNotifier, ViewState>((ref) => ViewNotifier(
        ViewState(
            viewType: ViewType.standard, chat: false, participants: false)));
