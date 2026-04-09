import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SubmissionMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String plantName;

  const SubmissionMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.plantName,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('$plantName Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('submission_loc'),
            position: position,
            infoWindow: InfoWindow(title: plantName),
          ),
        },
      ),
    );
  }
}