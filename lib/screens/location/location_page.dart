import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class LocationPage extends StatefulWidget {
  final Map<String, dynamic> member;

  const LocationPage({required this.member});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController?
      mapController; 
  LatLng _currentPosition = LatLng(0.0, 0.0); 
  bool _isLoading = true; 
  String _errorMessage = ''; 
  DateTime _selectedDate = DateTime.now(); 
  List<Map<String, dynamic>> _visitedLocations = []; 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); 
    _listenToLiveLocation(); 
    _fetchVisitedLocations(); 
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

 
  Future<void> _fetchVisitedLocations() async {
    setState(() {
      _visitedLocations = [
        {
          'location': LatLng(28.4595, 77.0299),
          'time': '10:00 AM'
        }, 
        {
          'location': LatLng(28.4620, 77.0315),
          'time': '12:30 PM'
        }, 
        {'location': LatLng(28.4650, 77.0330), 'time': '02:45 PM'},
        {'location': LatLng(28.4670, 77.0350), 'time': '04:00 PM'},
      ];
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location for ${widget.member['name']}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Current Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _isLoading
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
                          ..._visitedLocations.map(
                            (loc) => Marker(
                              markerId: MarkerId(loc['time']),
                              position: loc['location'],
                              infoWindow: InfoWindow(
                                  title: loc['time'], snippet: 'Visited'),
                            ),
                          ),
                        },
                      ),
          ),

          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ..._visitedLocations.map((loc) {
                  return ListTile(
                    title: Text('Time: ${loc['time']}'),
                    subtitle: Text(
                        'Lat: ${loc['location'].latitude}, Lng: ${loc['location'].longitude}'),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
