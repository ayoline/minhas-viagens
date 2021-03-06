import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas viagens"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xff0066cc),
        onPressed: () {
          _adicionarLocal();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot? querySnapshot = snapshot.data;
              List<DocumentSnapshot> viagens = querySnapshot!.docs.toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: viagens.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot item = viagens[index];
                        String titulo = item["titulo"];
                        String idViagem = item.id;

                        return GestureDetector(
                          onTap: () {
                            _abrirMapa(idViagem);
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(titulo),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _excluirViagem(idViagem);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  _adicionarListenerViagens() async {
    final stream = _db.collection("viagens").snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _adicionarLocal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Mapa(
          idViagem: '',
        ),
      ),
    );
  }

  _excluirViagem(String idViagem) {
    _db.collection("viagens").doc(idViagem).delete();
  }

  _abrirMapa(String idViagem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Mapa(
          idViagem: idViagem,
        ),
      ),
    );
  }
}
