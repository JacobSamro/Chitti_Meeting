import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:dio/dio.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:get_it/get_it.dart';
import '../modules/meeting_module/providers/meeting_provider.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerLazySingleton<DyteMobileClient>(() => DyteMobileClient());
  locator.registerLazySingleton<Dio>(() => Dio());
  locator.registerLazySingleton<MeetingStateNotifier>(
      () => MeetingStateNotifier());
  locator.registerLazySingleton<MeetingRepositories>(() => MeetingRepositories(
      dio: locator<Dio>(), client: locator<DyteMobileClient>()));
}
