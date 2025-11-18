import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });
}

class LocationHandler {
  Location location = Location();
  bool _isInitialized = false;
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  /// مقداردهی اولیه هندلر
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // بررسی سرویس موقعیت‌یابی
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          throw Exception('سرویس موقعیت‌یابی دستگاه غیرفعال است');
        }
      }

      // بررسی و درخواست مجوز
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          throw Exception('مجوز دسترسی به موقعیت مکانی رد شد');
        }
      }

      if (_permissionGranted == PermissionStatus.deniedForever) {
        throw Exception(
          'دسترسی به موقعیت مکانی برای همیشه مسدود شده است. '
          'لطفاً از طریق تنظیمات دستگاه مجوز را فعال کنید'
        );
      }

      _isInitialized = true;
      print('📍 Location handler initialized successfully');
      
    } catch (e) {
      print('Location initialization error: $e');
      rethrow;
    }
  }

  /// دریافت موقعیت مکانی فعلی
  Future<LocationData> getCurrentLocation() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // دریافت موقعیت با تنظیمات بهینه
      final locationData = await location.getLocation();
      
      // بررسی اعتبار داده‌های دریافتی
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('داده‌های موقعیت معتبر نیستند');
      }

      return LocationData(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        accuracy: locationData.accuracy,
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      print('Get location error: $e');
      
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('دسترسی به موقعیت مکانی رد شد');
      } else if (e.toString().contains('SERVICE_DISABLED')) {
        throw Exception('سرویس موقعیت‌یابی غیرفعال است');
      } else if (e.toString().contains('TIMEOUT')) {
        throw Exception('زمان دریافت موقعیت به پایان رسید');
      } else {
        throw Exception('خطا در دریافت موقعیت: $e');
      }
    }
  }

  /// شروع دریافت موقعیت‌های زنده
  Stream<LocationData> getLocationStream() {
    return location.onLocationChanged.map((data) {
      return LocationData(
        latitude: data.latitude ?? 0,
        longitude: data.longitude ?? 0,
        accuracy: data.accuracy,
        timestamp: DateTime.now(),
      );
    });
  }

  /// بررسی وضعیت سرویس موقعیت‌یابی
  Future<bool> checkServiceStatus() async {
    _serviceEnabled = await location.serviceEnabled();
    return _serviceEnabled;
  }

  /// بررسی وضعیت مجوزها
  Future<PermissionStatus> checkPermissionStatus() async {
    _permissionGranted = await location.hasPermission();
    return _permissionGranted;
  }

  /// باز کردن تنظیمات برنامه برای تغییر مجوزها
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// دریافت وضعیت فعلی هندلر
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'serviceEnabled': _serviceEnabled,
      'permissionGranted': _permissionGranted == PermissionStatus.granted,
      'permissionStatus': _permissionGranted.toString(),
    };
  }
}
