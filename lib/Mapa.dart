import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
      ),
      body: Container(
        child: GoogleMap(
          markers: _marcadores,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(-11.098188694141436, -37.13673762628679),
            zoom: 18,
          ),
          onMapCreated: _onMapCreated,
          onLongPress: _exibirMarcador,
        ),
      ),
    );
  }

  _exibirMarcador(LatLng latLng) {
    Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(title: "Marcador"));

    setState(() {
      _marcadores.add(marcador);
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
