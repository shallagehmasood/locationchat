import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'web_view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'چت مکانی',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazir', // فونت فارسی
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('چت مکانی'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 30),
            const Text(
              'انتخاب روش استفاده',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20),
            const Text(
              'برای تجربه بهتر، استفاده از نسخه اپلیکیشن توصیه می‌شود',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.apps),
              label: const Text('استفاده در اپلیکیشن'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                _launchInBrowser('http://178.63.171.244:5000');
              },
              icon: const Icon(Icons.language),
              label: const Text('استفاده در مرورگر'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
