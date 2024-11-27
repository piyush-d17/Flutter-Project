import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  final Map<String, dynamic> member;

  const LocationPage({required this.member});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0);
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToLiveLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permissions are permanently denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  void _listenToLiveLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (_currentPosition.latitude != 0.0 && _currentPosition.longitude != 0.0) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track live location')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14.0,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: {
                    Marker(
                      markerId: MarkerId('current_location'),
                      position: _currentPosition,
                      infoWindow: InfoWindow(title: 'Your Location'),
                    ),
                  },
                ),
    );
  }
}
