import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  final Map<String, dynamic> member;

  LocationPage({required this.member});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? mapController; // Nullable to handle initialization timing
  LatLng _currentPosition = LatLng(0.0, 0.0); // Default position
  bool _isLoading = true; // Loading state
  String _errorMessage = ''; // Error message state

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch initial location
    _listenToLiveLocation(); // Start listening to live location updates
  }

  // Fetch the current location
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

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Update map camera to current location (only if mapController is initialized)
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

  // Listen for live location updates
  void _listenToLiveLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Update the map camera to follow the live location (if controller is initialized)
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    });
  }

  // Map creation callback
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; // Initialize the controller

    // Move the camera to the current position when map is initialized
    if (_currentPosition.latitude != 0.0 && _currentPosition.longitude != 0.0) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location for ${widget.member['name']}')),
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
