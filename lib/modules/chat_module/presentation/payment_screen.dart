import 'package:flutter/material.dart';
import 'package:webview_universal/webview_universal.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;

class PaymentScreeen extends StatefulWidget {
  const PaymentScreeen({super.key, required this.url});
  final String url;
  @override
  State<PaymentScreeen> createState() => _PaymentScreeenState();
}

class _PaymentScreeenState extends State<PaymentScreeen> {
  final WebViewController controller = WebViewController();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    initWebView();
  }

  Future<void> initWebView() async {
    await controller.init(
        context: context, setState: setState, uri: Uri.parse(widget.url));
    controller.is_mobile
        ? controller.webview_mobile_controller.setNavigationDelegate(
            webview_flutter.NavigationDelegate(onPageFinished: (String data) {
            // throw Exception(data);
            setState(() {
              isLoading = false;
            });
          }))
        : null;
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : WebView(
              controller: controller,
            ),
    );
  }
}
