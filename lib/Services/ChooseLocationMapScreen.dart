import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _initialPosition = LatLng(13.0561, 80.1054);
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  late Position position;
  late String location;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('Location services are disabled. Please enable them.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    location = '${position.latitude}, ${position.longitude}';
    print(location);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'This is your current location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen), // Customize this icon
      ));
      _mapController?.moveCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_pickedLocation != null) {
                Navigator.of(context).pop(_pickedLocation);
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        // onTap: (position) {
        //   setState(() {
        //     _pickedLocation = position;
        //   });
        // },
        onTap: (position) {
          setState(() {
            _pickedLocation = position;
            markers.add(Marker(
              markerId: MarkerId('picked-location'),
              position: position,
            ));
          });
        },
        markers: markers,

        // markers: _pickedLocation == null
        //     ? {}
        //     : {
        //         Marker(
        //           markerId: MarkerId('picked-location'),
        //           position: _pickedLocation!,
        //         ),
        //       },
      ),
    );
  }
}
