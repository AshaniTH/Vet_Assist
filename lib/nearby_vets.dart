import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyVetHospitalsPage extends StatefulWidget {
  const NearbyVetHospitalsPage({super.key});

  @override
  _NearbyVetHospitalsPageState createState() => _NearbyVetHospitalsPageState();
}

class _NearbyVetHospitalsPageState extends State<NearbyVetHospitalsPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String googleApiKey = 'AIzaSyDniHGOafCwwdG50n2nXBmsfMyYDMsD4_g';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = LatLng(position.latitude, position.longitude);

    print('Current position: $_currentPosition');

    setState(() {});
    _fetchNearbyVetHospitals();
  }

  Future<void> _fetchNearbyVetHospitals() async {
    if (_currentPosition == null) return;

    print(
      'Searching near: ${_currentPosition!.latitude},${_currentPosition!.longitude}',
    );

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
      '&radius=10000' // Increased radius to 10 km
      '&keyword=veterinary' // Changed keyword to 'veterinary'
      '&key=$googleApiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    print('Places API status: ${data['status']}');
    print('Vet clinics found: ${data['results']?.length ?? 0}');

    if (data['status'] == 'OK') {
      final List results = data['results'];

      Set<Marker> newMarkers =
          results.map((place) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            final placeId = place['place_id']; // Unique ID
            final name = place['name'];
            return Marker(
              markerId: MarkerId(placeId),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
              onTap: () {
                _getDirections(LatLng(lat, lng));
              },
            );
          }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    } else {
      print('Places API Error: ${data['status']}');
      setState(() {
        _markers = {};
      });
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    final origin =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final dest = '${destination.latitude},${destination.longitude}';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$origin&destination=$dest'
      '&mode=driving'
      '&key=$googleApiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      final routeCoords = _decodePolyline(points);
      setState(() {
        _polylines = {
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: routeCoords,
          ),
        };
      });
    } else {
      print('Directions API Error: ${data['status']}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Vet Clinics'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
    );
  }
}
