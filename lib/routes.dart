import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'main.dart';

final GoRouter router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => HomeScreen(
      hashId: ''.toString(),
    ),
  ),
  GoRoute(
    path: "/meeting/:hashId",
    name: "meeting",
    builder: (context, state) => HomeScreen(
      hashId: state.pathParameters["hashId"].toString(),
    ),
  )
]);

void handleIncomingLinks() {
  linkStream.listen((String? link) {
    if (link == null) {
      router.go("/");
      return;
    }
    final path = Uri.parse(link).path;
    router.go(path);
  }, onError: (Object err) {
    debugPrint("Error handling incoming link: $err");
  });
}
