import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/map_service.dart';
import 'location_button.dart';

class AdaptiveMap extends StatefulWidget {
  final double height;
  final void Function(dynamic)? onMapCreated;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;

  const AdaptiveMap({
    super.key,
    required this.height,
    this.onMapCreated,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
  });

  @override
  State<AdaptiveMap> createState() => _AdaptiveMapState();
}

class _AdaptiveMapState extends State<AdaptiveMap> {
  bool? _useGoogleMaps;
  bool _isLoading = true;
  bool _isTracking = false;
  Position? _currentPosition;
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionStreamSubscription;
  final _mapController = MapController();
  google_maps.GoogleMapController? _googleMapController;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final hasGoogleServices = await MapService.hasGoogleServices();
    setState(() {
      _useGoogleMaps = hasGoogleServices;
      _isLoading = false;
    });
  }

  Future<void> _toggleLocationTracking() async {
    if (_isTracking) {
      // Detener seguimiento
      _positionStreamSubscription?.cancel();
      setState(() {
        _isTracking = false;
      });
    } else {
      // Iniciar seguimiento
      final locationStream = await _locationService.startLocationUpdates();
      if (locationStream != null) {
        _positionStreamSubscription = locationStream.listen((position) {
          setState(() {
            _currentPosition = position;
          });

          // Actualizar la posición del mapa
          if (_useGoogleMaps == true && _googleMapController != null) {
            _googleMapController!.animateCamera(
              google_maps.CameraUpdate.newLatLng(
                google_maps.LatLng(
                  position.latitude,
                  position.longitude,
                ),
              ),
            );
          } else {
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              _mapController.camera.zoom,
            );
          }
        });
        setState(() {
          _isTracking = true;
        });
      } else {
        // Mostrar error si no se pueden obtener permisos
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo acceder a la ubicación'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        _buildMap(),
        Positioned(
          right: 16,
          bottom: 96, // Ajusta esta posición según necesites
          child: LocationButton(
            onPressed: _toggleLocationTracking,
            isTracking: _isTracking,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    if (_useGoogleMaps == true) {
      return SizedBox(
        height: widget.height,
        child: google_maps.GoogleMap(
          initialCameraPosition: google_maps.CameraPosition(
            target: _getGoogleLatLng(),
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _googleMapController = controller;
            widget.onMapCreated?.call(controller);
          },
          myLocationEnabled: widget.myLocationEnabled,
          myLocationButtonEnabled: false, // Desactivamos el botón por defecto
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _getLatLng(),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.panda.repartidor',
          ),
          if (_currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 80,
                  height: 80,
                  point: _getLatLng(),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  LatLng _getLatLng() {
    return _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(-5.944436, -77.306495);
  }

  google_maps.LatLng _getGoogleLatLng() {
    return _currentPosition != null
        ? google_maps.LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          )
        : const google_maps.LatLng(-5.944436, -77.306495);
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _googleMapController?.dispose();
    super.dispose();
  }
}