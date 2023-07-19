import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/view_state.dart';

class ViewNotifier extends StateNotifier<ViewState> {
  ViewNotifier(super.state);
   bool chat=false;
 void changeViewType(ViewType type) {
    state = ViewState(viewType: type, chat: state.chat,participants: state.participants);
  }

  void openChatInDesktop(bool value) {
    state = ViewState(viewType: state.viewType, chat: value,participants:false);
  }
    void openParticipantsInDesktop(bool value) {
    state = ViewState(viewType: state.viewType, chat: false,participants:value);
  }
}

final StateNotifierProvider<ViewNotifier, ViewState> viewProvider =
    StateNotifierProvider<ViewNotifier, ViewState>(
        (ref) => ViewNotifier(ViewState(viewType: ViewType.standard, chat: false,participants: false)));
