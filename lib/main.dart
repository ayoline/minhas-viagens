import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'SplashScreen.dart';

void main() async {
  // Sempre que usar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Minhas viagens",
    home: SplashScreen(),
  ));
}
