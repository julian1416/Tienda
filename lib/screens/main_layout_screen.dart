// lib/screens/main_layout_screen.dart

import 'package:flutter/material.dart';
import 'package:mi_tienda/screens/cart_screen.dart';
import 'package:mi_tienda/screens/favorites_screen.dart';
import 'package:mi_tienda/screens/home_screen.dart';
import 'package:mi_tienda/screens/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  // Variable de estado para saber qué pestaña está seleccionada
  int _selectedIndex = 0;

  // Lista de las pantallas que mostraremos. El orden es crucial.
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),      // Índice 0: Inicio
    FavoritesScreen(), // Índice 1: Favoritos
    CartScreen(),      // Índice 2: Carrito
    ProfileScreen(),   // Índice 3: Perfil
  ];

  // Método que se llama cuando el usuario toca un ícono
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El cuerpo de la app ahora es la pantalla seleccionada de nuestra lista
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // La barra de navegación inferior, ahora con los colores correctos
      bottomNavigationBar: BottomNavigationBar(
        // --- PROPIEDADES AÑADIDAS Y CORREGIDAS ---

        // 1. Tipo 'fixed': Mantiene el mismo aspecto para todos los ítems.
        //    Esencial para que los colores que definimos funcionen siempre.
        type: BottomNavigationBarType.fixed,

        // 2. Color para el ítem activo (el que ya tenías).
        selectedItemColor: Colors.teal[700], // Un teal un poco más oscuro se ve genial

        // 3. Color para los ítems inactivos (la clave de tu pregunta).
        unselectedItemColor: Colors.grey,

        // --- Propiedades que ya tenías bien ---
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
        // --- Lista de ítems de la barra ---
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Ícono cuando está activo
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}