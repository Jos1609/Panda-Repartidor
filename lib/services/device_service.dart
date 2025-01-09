import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Verifica si el dispositivo es un Huawei o no tiene servicios de Google
  Future<bool> isHuaweiDevice() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.manufacturer.toLowerCase() == 'huawei' || 
             androidInfo.manufacturer.toLowerCase() == 'honor';
    } catch (e) {
      return false;
    }
  }
}