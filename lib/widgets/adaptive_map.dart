import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';

class AdaptiveMap extends StatefulWidget {
  final double height;

  const AdaptiveMap({
    super.key,
    required this.height, required Function(dynamic controller) onMapCreated, required bool myLocationEnabled, required bool myLocationButtonEnabled,
  });

  @override
  State<AdaptiveMap> createState() => _AdaptiveMapState();
}

class _AdaptiveMapState extends State<AdaptiveMap> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationStream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final location = await _locationService.getCurrentLocation();
      
      if (mounted && location != null) {
        setState(() {
          _currentLocation = location;
          _isLoading = false;
        });
        
        // Mover el mapa a la ubicación actual
        _mapController.move(
          LatLng(location.latitude!, location.longitude!),
          _mapController.camera.zoom,
        );
        
        _startLocationUpdates();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startLocationUpdates() {
    _locationStream?.cancel();
    _locationStream = _locationService.getLocationStream().listen(
      (location) {
        if (mounted) {
          setState(() => _currentLocation = location);
          // Actualizar la posición del mapa
          _mapController.move(
            LatLng(location.latitude!, location.longitude!),
            _mapController.camera.zoom,
          );
        }
      },
      onError: (error) {
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                  : const LatLng(19.4326, -99.1332),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.panda.repartidor',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 50,
                      height: 50,
                      point: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'location_button',
              onPressed: _isLoading ? null : _getLocation,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: _isLoading ? Colors.grey : AppTheme.primaryColor,
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    super.dispose();
  }
}