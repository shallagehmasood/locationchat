import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'location_handler.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  final LocationHandler _locationHandler = LocationHandler();
  
  double progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeLocationHandler();
  }

  void _initializeLocationHandler() async {
    await _locationHandler.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'چت مکانی',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // دکمه رفرش
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              webViewController?.reload();
            },
            tooltip: 'بارگذاری مجدد',
          ),
          // دکمه خانه
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              webViewController?.loadUrl(
                urlRequest: URLRequest(
                  url: WebUri('http://178.63.171.244:5000'),
                ),
              );
            },
            tooltip: 'برگشت به خانه',
          ),
        ],
      ),
      body: Column(
        children: [
          // نوار پیشرفت
          if (_isLoading && progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              minHeight: 2,
            ),
          
          // پیام خطا
          if (_hasError)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // وب‌ویو
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: WebUri('http://178.63.171.244:5000'),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  cacheEnabled: true,
                  transparentBackground: true,
                  useShouldOverrideUrlLoading: true,
                ),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                  geolocationEnabled: true,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                ),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                _setupJavaScriptHandlers(controller);
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  progress = 0;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });
                await _injectLocationBridge();
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = 'خطا در بارگذاری: $message';
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('WebView Console: ${consoleMessage.message}');
              },
            ),
          ),
        ],
      ),
      
      // دکمه شناور برای موقعیت‌یابی
      floatingActionButton: FloatingActionButton(
        onPressed: _requestLocation,
        tooltip: 'دریافت موقعیت دقیق',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.location_searching_rounded),
      ),
      
      // نوار پایین
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            // دکمه بازگشت
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                webViewController?.goBack();
              },
            ),
            // دکمه جلو
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {
                webViewController?.goForward();
              },
            ),
            const Spacer(),
            // وضعیت اتصال
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isLoading ? Colors.orange.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoading ? Icons.sync_rounded : Icons.wifi_rounded,
                    size: 14,
                    color: _isLoading ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isLoading ? 'در حال بارگذاری...' : 'متصل',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isLoading ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupJavaScriptHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'requestLocation',
      callback: (args) async {
        await _requestLocation();
      },
    );
  }

  Future<void> _injectLocationBridge() async {
    final jsCode = '''
      // ایجاد پل ارتباطی برای موقعیت‌یابی
      window.flutterLocation = {
        requestLocation: function() {
          return new Promise((resolve, reject) => {
            // ذخیره توابع resolve و reject
            window._flutterLocationResolve = resolve;
            window._flutterLocationReject = reject;
            
            // ارسال درخواست به فلاتر
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('requestLocation');
            } else {
              reject('WebView channel not available');
            }
          });
        }
      };

      // توابع دریافت پاسخ از فلاتر
      window.receiveLocationFromFlutter = function(latitude, longitude, accuracy) {
        if (window._flutterLocationResolve) {
          const position = {
            coords: {
              latitude: latitude,
              longitude: longitude,
              accuracy: accuracy || 10,
              altitude: null,
              altitudeAccuracy: null,
              heading: null,
              speed: null
            },
            timestamp: Date.now()
          };
          window._flutterLocationResolve(position);
          window._flutterLocationResolve = null;
        }
      };

      window.receiveLocationErrorFromFlutter = function(error) {
        if (window._flutterLocationReject) {
          window._flutterLocationReject(new Error(error));
          window._flutterLocationReject = null;
        }
      };

      // جایگزینی تابع موقعیت‌یابی مرورگر
      if (navigator.geolocation) {
        const originalGetCurrentPosition = navigator.geolocation.getCurrentPosition.bind(navigator.geolocation);
        
        navigator.geolocation.getCurrentPosition = function(successCallback, errorCallback, options) {
          console.log('Using Flutter location service...');
          
          // اول از فلاتر درخواست موقعیت می‌کنیم
          window.flutterLocation.requestLocation()
            .then((position) => {
              console.log('Location from Flutter:', position);
              successCallback(position);
            })
            .catch((error) => {
              console.log('Flutter location failed, using browser method:', error);
              // اگر فلاتر خطا داد، از روش معمول مرورگر استفاده می‌کنیم
              originalGetCurrentPosition(successCallback, errorCallback, options);
            });
        };
      }

      console.log('🎯 Flutter location bridge injected successfully');
      
      // اطلاع‌رسانی به کاربر
      if (typeof showStatus === 'function') {
        showStatus('✅ سیستم موقعیت‌یابی پیشرفته فعال شد', 'connected');
      }
    ''';
    
    await webViewController?.evaluateJavascript(source: jsCode);
  }

  Future<void> _requestLocation() async {
    try {
      // نمایش وضعیت در حال دریافت موقعیت
      await webViewController?.evaluateJavascript(source: '''
        if (typeof showStatus === 'function') {
          showStatus('📡 در حال دریافت موقعیت از GPS اندروید...', 'connected');
        }
      ''');
      
      // دریافت موقعیت از هندلر
      final location = await _locationHandler.getCurrentLocation();
      
      // ارسال موقعیت به وب‌ویو
      await webViewController?.evaluateJavascript(source: '''
        if (window.receiveLocationFromFlutter) {
          window.receiveLocationFromFlutter(
            ${location.latitude}, 
            ${location.longitude}, 
            ${location.accuracy ?? 10}
          );
        }
        
        if (typeof showStatus === 'function') {
          showStatus('✅ موقعیت دقیق دریافت شد (GPS اندروید)', 'connected');
        }
      ''');
      
    } catch (e) {
      print('Location error: $e');
      
      // ارسال خطا به وب‌ویو
      await webViewController?.evaluateJavascript(source: '''
        if (window.receiveLocationErrorFromFlutter) {
          window.receiveLocationErrorFromFlutter('$e');
        }
        
        if (typeof showStatus === 'function') {
          showStatus('❌ خطا در دریافت موقعیت: $e', 'error');
        }
      ''');
    }
  }
}
