import 'package:flutter/services.dart';

class MapService {
  static Future<bool> hasGoogleServices() async {
    try {
      // Verifica si hay servicios de Google disponibles
      const platform = MethodChannel('google_services_channel');
      final bool hasServices = await platform.invokeMethod('checkGoogleServices');
      return hasServices;
    } catch (e) {
      return false;
    }
  }
}