import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-11.098188694141436, -37.13673762628679),
    zoom: 18,
  );

  @override
  void initState() {
    super.initState();

    _adicionarListenerLocalizacao();
  }

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
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _exibirMarcador,
        ),
      ),
    );
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        _posicaoCamera,
      ),
    );
  }

  _adicionarListenerLocalizacao() {
    Geolocator.getPositionStream(
      distanceFilter: 5, // monitora o usurio para atualizar a cada 5metros
      desiredAccuracy: LocationAccuracy.best,
    ).listen((Position position) {
      setState(() {
        print("localização atual: " +
            position.latitude.toString() +
            " , " +
            position.longitude.toString());
        _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
        );
        _movimentarCamera();
      });
    });
  }

  _exibirMarcador(LatLng latLng) async {
    List<Placemark> listaEnderecos = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    if (listaEnderecos.length > 0) {
      Placemark endereco = listaEnderecos[0];
      String? rua = endereco.thoroughfare;

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(
            title: rua,
          ));

      setState(() {
        _marcadores.add(marcador);
      });
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
