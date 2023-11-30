import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:media_kit/media_kit.dart';
import '../modules/meeting_module/providers/meeting_provider.dart';
import 'package:livekit_client/livekit_client.dart';
import '../modules/meeting_module/repositories/meeting_respositories.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerLazySingleton<Room>(() => Room());
  locator.registerLazySingleton<HMSSDK>(() => HMSSDK());
  locator.registerLazySingleton<Dio>(() => Dio());
  locator.registerLazySingleton<MeetingStateNotifier>(
      () => MeetingStateNotifier());
  locator.registerLazySingleton<MeetingRepositories>(
      () => MeetingRepositories(dio: locator<Dio>()));
  locator.registerLazySingleton<EventsListener>(
      () => locator<Room>().createListener());
  locator.registerLazySingleton<GlobalKey<ScaffoldState>>(
      () => GlobalKey<ScaffoldState>());
  locator.registerLazySingleton<Player>(() => Player());
  locator.registerLazySingleton<ProviderContainer>(() => ProviderContainer());
}
