import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHandler {
  /// بررسی و درخواست مجوزهای موقعیت مکانی
  Future<bool> _checkLocationPermission() async {
    // بررسی وضعیت مجوز
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // درخواست مجوز
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        throw Exception('دسترسی به موقعیت مکانی رد شد');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('دسترسی به موقعیت مکانی برای همیشه مسدود شده است. لطفاً از طریق تنظیمات دستگاه مجوز را فعال کنید');
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// دریافت موقعیت مکانی فعلی با دقت بالا
  Future<Position> getCurrentLocation() async {
    // بررسی سرویس‌های موقعیت‌یابی
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('سرویس‌های موقعیت‌یابی غیرفعال هستند');
    }

    // بررسی مجوزها
    await _checkLocationPermission();

    // دریافت موقعیت با دقت بالا
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// دریافت موقعیت‌های زنده (برای ویژگی‌های آینده)
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // هر 10 متر آپدیت شود
      ),
    );
  }
}
