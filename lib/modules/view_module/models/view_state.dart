import '../../meeting_module/states/meeting_states.dart';

class ViewState {
  final ViewType viewType;
  final bool chat;
  final bool participants;

  ViewState({required this.viewType,required this.participants, required this.chat});
}
