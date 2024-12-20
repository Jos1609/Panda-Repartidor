import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;
  Stream<Position>? _locationStream;

  /// Obtiene la última posición conocida
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Verifica y solicita los permisos de ubicación
  Future<bool> checkAndRequestPermission() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Verificar permisos de ubicación
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Inicia el seguimiento de ubicación en tiempo real
  Future<Stream<Position>?> startLocationUpdates() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      // Obtener la posición actual
      _lastKnownPosition = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      // Iniciar stream de ubicación
      _locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return _locationStream;
    } catch (e) {
      return null;
    }
  }

  /// Detiene el seguimiento de ubicación
  void stopLocationUpdates() {
    _locationStream = null;
  }
}