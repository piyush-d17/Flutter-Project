import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class InfoPage extends StatefulWidget {
  final Map<String, dynamic> member;

  const InfoPage({required this.member});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0); 
  List<Map<String, dynamic>> _visitedLocations = [];
  LatLng? _selectedDestination;
  bool _isLoading = true;
  String _errorMessage = '';
  double? _distance; 
  String? _duration; 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _fetchVisitedLocations() async {
    setState(() {
      _visitedLocations = [
        {'location': LatLng(28.4595, 77.0299), 'time': '10:00 AM', 'name': 'Location A'},
        {'location': LatLng(28.4620, 77.0315), 'time': '12:30 PM', 'name': 'Location B'},
        {'location': LatLng(28.4650, 77.0330), 'time': '02:45 PM', 'name': 'Location C'},
        {'location': LatLng(28.4670, 77.0350), 'time': '04:00 PM', 'name': 'Location D'},
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

  void _showRoute(LatLng destination, String name) async {
    double distance = Geolocator.distanceBetween(
          _currentPosition.latitude,
          _currentPosition.longitude,
          destination.latitude,
          destination.longitude,
        ) /
        1000; 
    double avgSpeed = 50; 
    double travelTime = distance / avgSpeed; 

    setState(() {
      _selectedDestination = destination;
      _distance = double.parse(distance.toStringAsFixed(2));
      _duration = '${(travelTime * 60).toStringAsFixed(0)} min'; 
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentPosition.latitude < destination.latitude
                ? _currentPosition.latitude
                : destination.latitude,
            _currentPosition.longitude < destination.longitude
                ? _currentPosition.longitude
                : destination.longitude,
          ),
          northeast: LatLng(
            _currentPosition.latitude > destination.latitude
                ? _currentPosition.latitude
                : destination.latitude,
            _currentPosition.longitude > destination.longitude
                ? _currentPosition.longitude
                : destination.longitude,
          ),
        ),
        50,
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Divider(),
          Text(
            'From: ${widget.member['address']}',
            style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
          ),
          Text(
            'To: ${_visitedLocations.firstWhere((loc) => loc['location'] == _selectedDestination, orElse: () => {'name': 'Unknown'})['name']}',
            style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Total Distance',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '${_distance ?? "--"} Kms',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Total Duration',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '${_duration ?? "--"}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      itemCount: _visitedLocations.length,
      itemBuilder: (context, index) {
        final location = _visitedLocations[index];
        return ListTile(
          leading: Icon(Icons.location_on, color: Colors.blue),
          title: Text(location['name']),
          subtitle: Text('Visited at: ${location['time']}'),
          onTap: () {
            _showRoute(location['location'], location['name']);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Live Location')),
      body: Column(
        children: [
          if (_selectedDestination != null) _buildRouteCard(),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14.0,
              ),
              onMapCreated: _onMapCreated,
              markers: {
                Marker(
                  markerId: MarkerId('current_location'),
                  position: _currentPosition,
                  infoWindow: InfoWindow(title: 'Your Location (Source)'),
                ),
                if (_selectedDestination != null)
                  Marker(
                    markerId: MarkerId('destination'),
                    position: _selectedDestination!,
                    infoWindow: InfoWindow(title: 'Destination'),
                  ),
              },
              polylines: {
                if (_selectedDestination != null)
                  Polyline(
                    polylineId: PolylineId('route'),
                    points: [_currentPosition, _selectedDestination!],
                    color: Colors.blue,
                    width: 5,
                  ),
              },
            ),
          ),

          Container(
            height: 250,
            child: _buildTimeline(),
          ),
        ],
      ),
    );
  }
}