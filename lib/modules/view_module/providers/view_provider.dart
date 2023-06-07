import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewNotifier extends StateNotifier<ViewType> {
  ViewNotifier(super.state);

  changeViewType(ViewType type) {
    state = type;
  }
}

final StateNotifierProvider<ViewNotifier, ViewType> viewProvider =
    StateNotifierProvider<ViewNotifier, ViewType>(
        (ref) => ViewNotifier(ViewType.standard));
