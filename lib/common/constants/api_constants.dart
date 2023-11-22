class ApiConstants {
  static final String baseUrl =
      AppEnvironment.singleton.baseUrlProvider.baseUrl;
  static final String addParticipantUrl = "$baseUrl/workshops/participants";
  static const String hmsTokenUrl = "https://100ms.lmes.app/api/token";
  static final String dateTimeUrl = "$baseUrl/workshops/datetime";
  static final String workshopUrl = "$baseUrl/workshops/workshops";
  static final String livekitUrl =
      AppEnvironment.singleton.baseUrlProvider.livekitUrl;
  static final String messageScoketUrl =
      AppEnvironment.singleton.baseUrlProvider.messageScoketUrl;
}

enum Environment { production, staging }

class BaseUrlProvider {
  final String baseUrl;
  final String livekitUrl;
  final String messageScoketUrl;

  const BaseUrlProvider({
    required this.baseUrl,
    required this.livekitUrl,
    required this.messageScoketUrl,
  });
}

class AppEnvironment {
  AppEnvironment._internal();
  static final AppEnvironment singleton = AppEnvironment._internal();

  late final BaseUrlProvider baseUrlProvider;

  initEnvironment(Environment environment) {
    baseUrlProvider = _getUrl(environment);
  }

  BaseUrlProvider _getUrl(Environment environment) {
    if (environment == Environment.staging) {
      return const BaseUrlProvider(
          baseUrl: "https://cloud.chitti.xyz/api",
          livekitUrl: "wss://livekit-dev.lmes.app",
          messageScoketUrl:
              "https://staging-chitti-cloud-socket-server.fly.dev");
    }
    if (environment == Environment.production) {
      return const BaseUrlProvider(
          baseUrl: "https://cloud.chitti.app/api",
          livekitUrl: "wss://livekit.lmesacademy.app",
          messageScoketUrl: "https://chitti-cloud-socket-server.fly.dev");
    }
    return const BaseUrlProvider(
        baseUrl: "", livekitUrl: "", messageScoketUrl: "");
  }
}
