import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:map_box_example/home/home_page.dart';
import 'package:http/http.dart' as http;

mixin HomePageMixin on State<OpeenStreetMapPage> {
  final MapController mapController = MapController();
  final Location location = Location();
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];
  @override
  void initState() {
    super.initState();
    initLocation();
  }

  Future<void> fetchCoordinatesPoint(String location) async {
    final uri = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]["lat"]);
        final lon = double.parse(data[0]["lon"]);
        destination = LatLng(lat, lon);
        setState(() {
          destination = LatLng(lat, lon);
        });
        mapController.move(destination!, 15);
      } else {
        errorMessage("Location not found");
      }
    } else {
      errorMessage("Error fetching location");
    }
  }

  Future<void> initLocation() async {
    if (!await checkRequestPeremision()) return;
    location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false;
          mapController.move(currentLocation!, 15);
        });
      }
    });
    /*    final LocationData locationData = await location.getLocation();
    currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    mapController.move(currentLocation!, 15);*/
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<bool> checkRequestPeremision() async {
    final bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      final bool serviceRequest = await location.requestService();
      if (!serviceRequest) return false;
    }
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<void> userCurrentLocation() async {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location not found'),
        ),
      );
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    print('Lat: ${position.latitude}, Lng: ${position.longitude}');
  }
}
