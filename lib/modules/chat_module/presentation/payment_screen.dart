import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';
import 'package:webview_windows/webview_windows.dart';

class PaymentScreeen extends StatefulWidget {
  const PaymentScreeen({super.key, required this.url});
  final String url;
  @override
  State<PaymentScreeen> createState() => _PaymentScreeenState();
}

class _PaymentScreeenState extends State<PaymentScreeen> {
  final WebviewController windowsController = WebviewController();
  late final WebViewXController controller;
  bool isLoading = true;
  final bool isWindows =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  @override
  void initState() {
    super.initState();
    initWebView();
  }

  Future<void> initWebView() async {
    if (isWindows) {
      await windowsController.initialize();
      await windowsController.setBackgroundColor(Colors.transparent);
      await windowsController
          .setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await windowsController.loadUrl(widget.url);
    }
  }

  @override
  void dispose() {
    if (isWindows) {
      windowsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registration'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  'assets/icons/cancel.png',
                  width: 12,
                  height: 12,
                ),
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              height: 1.0,
            ),
          ),
        ),
        body: isWindows
            ? StreamBuilder(
                stream: windowsController.loadingState,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != LoadingState.loading) {
                    return Center(
                        child: Webview(
                      windowsController,
                    ));
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })
            : Stack(
                children: [
                  WebViewX(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    initialContent: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (String state) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox()
                ],
              ));
  }
}
