import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryMapEntry {
  final double latitude;
  final double longitude;
  final String plantName;

  const HistoryMapEntry({
    required this.latitude,
    required this.longitude,
    required this.plantName,
  });
}

class SubmissionMapPage extends StatelessWidget {
  final List<HistoryMapEntry> entries;
  final int selectedIndex;

  const SubmissionMapPage({
    super.key,
    required this.entries,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final selected = entries[selectedIndex];
    final position = LatLng(selected.latitude, selected.longitude);

    final markers = <Marker>{};
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      markers.add(Marker(
        markerId: MarkerId('entry_$i'),
        position: LatLng(e.latitude, e.longitude),
        zIndex: i == selectedIndex ? 1.0 : 0.0,
        icon: i == selectedIndex
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: e.plantName),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${selected.plantName} location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 12.0,
        ),
        markers: markers,
      ),
    );
  }
}
