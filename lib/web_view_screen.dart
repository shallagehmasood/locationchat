import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'location_handler.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final LocationHandler _locationHandler = LocationHandler();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _injectLocationBridge();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('http://178.63.171.244:5000'));
  }

  void _injectLocationBridge() {
    _controller.runJavaScript('''
      // ایجاد پل ارتباطی بین فلاتر و جاوااسکریپت
      window.flutterLocation = {
        requestLocation: function() {
          return new Promise((resolve, reject) => {
            window._resolveLocation = resolve;
            window._rejectLocation = reject;
            
            // ارسال درخواست به فلاتر
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('requestLocation');
            } else {
              reject('WebView channel not available');
            }
          });
        }
      };

      // تابع دریافت موقعیت از فلاتر
      window.receiveLocationFromFlutter = function(lat, lng) {
        if (window._resolveLocation) {
          window._resolveLocation({ latitude: lat, longitude: lng });
          window._resolveLocation = null;
        }
      };

      // تابع دریافت خطا از فلاتر
      window.receiveLocationErrorFromFlutter = function(error) {
        if (window._rejectLocation) {
          window._rejectLocation(error);
          window._rejectLocation = null;
        }
      };

      // جایگزینی تابع موقعیت‌یابی اصلی
      const originalGetCurrentPosition = navigator.geolocation.getCurrentPosition;
      
      navigator.geolocation.getCurrentPosition = function(success, error, options) {
        // اول از فلاتر درخواست موقعیت می‌کنیم
        window.flutterLocation.requestLocation()
          .then((position) => {
            success({
              coords: {
                latitude: position.latitude,
                longitude: position.longitude,
                accuracy: 10, // دقت بالا با GPS
                altitude: null,
                altitudeAccuracy: null,
                heading: null,
                speed: null
              },
              timestamp: Date.now()
            });
          })
          .catch((err) => {
            // اگر فلاتر خطا داد، از روش معمول استفاده می‌کنیم
            console.log('Flutter location failed, using browser method:', err);
            originalGetCurrentPosition.call(navigator.geolocation, success, error, options);
          });
      };

      console.log('Flutter location bridge injected successfully');
    ''');
  }

  Future<void> _handleLocationRequest() async {
    try {
      final position = await _locationHandler.getCurrentLocation();
      
      // ارسال موقعیت به وب‌ویو
      _controller.runJavaScript('''
        if (window.receiveLocationFromFlutter) {
          window.receiveLocationFromFlutter(${position.latitude}, ${position.longitude});
        }
      ''');
    } catch (e) {
      _controller.runJavaScript('''
        if (window.receiveLocationErrorFromFlutter) {
          window.receiveLocationErrorFromFlutter('${e.toString()}');
        }
      ''');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('چت مکانی'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleLocationRequest,
        tooltip: 'دریافت موقعیت',
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
