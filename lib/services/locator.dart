import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_repositories.dart';
import 'package:dio/dio.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:get_it/get_it.dart';
import '../common/constants/constants.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerLazySingleton<DyteMobileClient>(()=>DyteMobileClient());
  locator.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)));
  locator.registerLazySingleton<MeetingRepositories>(
      () => MeetingRepositories(dio: locator<Dio>(),client: locator<DyteMobileClient>()));
}
