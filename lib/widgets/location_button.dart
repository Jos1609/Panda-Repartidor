import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTracking;

  const LocationButton({
    super.key,
    required this.onPressed,
    this.isTracking = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      child: Icon(
        isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
        color: isTracking ? Colors.blue : Colors.grey,
      ),
    );
  }
}