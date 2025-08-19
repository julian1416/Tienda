// lib/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_tienda/services/auth_service.dart';
import 'package:mi_tienda/screens/login_screen.dart';
import 'package:mi_tienda/screens/main_layout_screen.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.user,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
            body: Center(
              child:  CircularProgressIndicator(),
            ),
          );
        }
        if(snapshot.hasData){
          return const MainLayoutScreen();
        }else{
          return const LoginScreen();
        }
      },
    );
  }
}