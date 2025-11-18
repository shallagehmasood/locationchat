import 'package:location/location.dart';

class LocationHandler {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  /// بررسی و درخواست مجوزهای موقعیت مکانی
  Future<bool> _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception('سرویس‌های موقعیت‌یابی غیرفعال هستند');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception('دسترسی به موقعیت مکانی رد شد');
      }
    }

    return _permissionGranted == PermissionStatus.granted;
  }

  /// دریافت موقعیت مکانی فعلی با دقت بالا
  Future<LocationData> getCurrentLocation() async {
    await _checkLocationPermission();

    return await location.getLocation();
  }

  /// دریافت موقعیت‌های زنده
  Stream<LocationData> getLocationStream() {
    return location.onLocationChanged;
  }
}
