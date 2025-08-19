// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mi_tienda/screens/auth_wrapper.dart';
import 'package:mi_tienda/screens/home_screen.dart';
import 'firebase_options.dart'; // Importa el archivo generado por FlutterFire CLI

void main() async {
  // Asegúrate de que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Tienda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Un color de fondo gris claro
      ),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
