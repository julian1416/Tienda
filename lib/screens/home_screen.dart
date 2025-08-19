// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:mi_tienda/models/product_model.dart';
import 'package:mi_tienda/services/auth_service.dart';
import 'package:mi_tienda/services/firestore_service.dart';
import 'package:mi_tienda/widgets/product_card.dart';

// No es necesario convertirlo a StatefulWidget por ahora, un StatelessWidget funciona bien
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- TU NUEVA APPBAR - ¡Está perfecta! ---
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A86FF), Color(0xFF83C5BE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        title: const Text('Mi Tienda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            color: Colors.black,
            onPressed: () { /* TODO: Implementar carrito */ },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- TU NUEVA BARRA DE BÚSQUEDA - ¡Está perfecta! ---
          _buildSearchBar(),

          // --- ¡AQUÍ VIENE LA FUSIÓN CON LA LÓGICA DE FAVORITOS! ---
          Expanded(
            child: StreamBuilder<List<String>>( // 1. PRIMER STREAM: Escucha los favoritos
              stream: _firestoreService.getUserFavoritesStream(),
              builder: (context, favoritesSnapshot) {
                // Mientras esperamos, mostramos un cargador
                if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Guardamos los IDs de favoritos en un Set para búsquedas rápidas (más eficiente)
                final Set<String> favoriteProductIds = (favoritesSnapshot.data ?? []).toSet();

                // 2. SEGUNDO STREAM: Escucha los productos (como ya tenías)
                return StreamBuilder<List<Product>>(
                  stream: _firestoreService.getProductsStream(),
                  builder: (context, productsSnapshot) {
                    if (productsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (productsSnapshot.hasError) {
                      return Center(child: Text('Error: ${productsSnapshot.error}'));
                    }
                    if (!productsSnapshot.hasData || productsSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No hay productos disponibles.'));
                    }

                    final products = productsSnapshot.data!;

                    // 3. ListView.builder ahora usa la información combinada
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0), // Un poco de padding general
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        // La magia: verificamos si este producto es favorito
                        final bool isFavorite = favoriteProductIds.contains(product.id);
                        
                        // Y le pasamos esa información al ProductCard
                        return ProductCard(
                          product: product,
                          initialIsFavorite: isFavorite, // <-- ¡LA CONEXIÓN CLAVE!
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TU MÉTODO PARA LA BARRA DE BÚSQUEDA - ¡Está perfecto! ---
  Widget _buildSearchBar() {
    return Container( /* ... tu código de search bar se queda igual ... */ );
  }
}