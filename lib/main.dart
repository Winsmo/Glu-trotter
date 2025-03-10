import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importez firebase_core
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assurez-vous que Flutter est initialisé
  await Firebase.initializeApp(); // Initialisez Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}