import 'package:flutter/material.dart';
import 'package:fyp_orvba/Utils/components/Buttons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationDetails extends StatefulWidget {
  LatLng latLng;
  bool isCustomer;
  LocationDetails(
      {super.key,
      this.latLng = const LatLng(0.0, 0.0),
      this.isCustomer = false});

  @override
  State<LocationDetails> createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  late GoogleMapController mapController;

  late LatLng _center;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LatLng? currentLocation;
  Future<void> _determinePosition() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      currentLocation =
          LatLng(_locationData.latitude!, _locationData.longitude!);
      mapController.animateCamera(CameraUpdate.newLatLng(currentLocation!));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _center = widget.latLng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
        if (widget.isCustomer == false)
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                    onTap: () async {
                      await _determinePosition();
                      Navigator.pop(context, currentLocation);
                    },
                    child: SmoothButton(title: "Use Current Location")),
              ))
      ],
    ));
  }
}
