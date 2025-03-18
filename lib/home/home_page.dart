import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_box_example/home/home_page_mixin.dart';

class OpeenStreetMapPage extends StatefulWidget {
  const OpeenStreetMapPage({super.key});

  @override
  State<OpeenStreetMapPage> createState() => _OpeenStreetMapPageState();
}

class _OpeenStreetMapPageState extends State<OpeenStreetMapPage>
    with HomePageMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OpenStreetMap',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 94, 90, 99),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(0, 0),
              initialZoom: 2,
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                maxZoom: 100,
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  markerDirection:
                      MarkerDirection.north, // Sensorni to‘liq o‘chiradi
                ),
              )
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 0, onPressed: () async{
           await initLocation();
          }, child: const Icon(Icons.my_location)),
    );
  }
}
