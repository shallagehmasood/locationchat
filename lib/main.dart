import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FullScreenWebView(),
    );
  }
}

class FullScreenWebView extends StatefulWidget {
  const FullScreenWebView({super.key});

  @override
  State<FullScreenWebView> createState() => _FullScreenWebViewState();
}

class _FullScreenWebViewState extends State<FullScreenWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // فعال‌سازی حالت فول‌اسکرین
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // تنظیمات WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("Loading: $url");
          },
        ),
      )
      ..loadRequest(Uri.parse("http://178.63.171.244:8000"));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false; // مانع خروج از اپ می‌شود
    }
    return true; // اجازه خروج از اپ
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
