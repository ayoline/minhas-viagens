import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {
  String idViagem;

  Mapa({required this.idViagem});
  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  FirebaseFirestore _db = FirebaseFirestore.instance;
  Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-11.098188694141436, -37.13673762628679),
    zoom: 18,
  );

  @override
  void initState() {
    super.initState();

    // Recupera viagem pelo ID
    _recuperarViagemPeloID(widget.idViagem);
    //_adicionarListenerLocalizacao();
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
          onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }

  _recuperarViagemPeloID(String idViagem) async {
    if (idViagem.length > 0) {
      // Exibir marcador para IdViagem
      DocumentSnapshot documentSnapshot =
          await _db.collection("viagens").doc(idViagem).get();

      var dados = documentSnapshot;
      String titulo = dados["titulo"];
      LatLng latLng = LatLng(dados["latitude"], dados["longitude"]);

      setState(() {
        Marker marcador = Marker(
            markerId:
                MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(
              title: titulo,
            ));

        _marcadores.add(marcador);
        _posicaoCamera = CameraPosition(
          target: latLng,
          zoom: 16,
        );
        _movimentarCamera();
      });
    } else {
      _adicionarListenerLocalizacao();
    }
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

  _adicionarMarcador(LatLng latLng) async {
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

        // Salva no Firebase
        Map<String, dynamic> viagem = Map();
        viagem["titulo"] = rua;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;
        _db.collection("viagens").add(viagem);
      });
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
