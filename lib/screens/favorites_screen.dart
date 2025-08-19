// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_tienda/models/product_model.dart';
import 'package:mi_tienda/services/firestore_service.dart';
import 'package:mi_tienda/widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Instancia de nuestro servicio para acceder a los métodos de Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Puedes usar el mismo estilo de AppBar que en HomeScreen si quieres
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A86FF), Color(0xFF83C5BE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text('Mis Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<List<String>>(
        // 1. PRIMER STREAM: Escuchamos la lista de IDs de favoritos del usuario.
        stream: _firestoreService.getUserFavoritesStream(),
        builder: (context, snapshotOfIds) {
          // --- Manejo de estados del primer stream ---
          if (snapshotOfIds.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotOfIds.hasError) {
            return Center(child: Text('Error: ${snapshotOfIds.error}'));
          }
          // El caso más importante: si la lista de favoritos está vacía.
          if (!snapshotOfIds.hasData || snapshotOfIds.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Aún no tienes favoritos.\n¡Toca el corazón en un producto para guardarlo aquí!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }

          // Si llegamos aquí, tenemos una lista de IDs de favoritos.
          final favoriteIds = snapshotOfIds.data!;

          // 2. SEGUNDO STREAM: Usamos los IDs para buscar los documentos de esos productos.
          return StreamBuilder<QuerySnapshot>(
            // La consulta `whereIn` es la clave: busca documentos cuyo ID esté en nuestra lista.
            stream: FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: favoriteIds)
                .snapshots(),
            builder: (context, snapshotOfProducts) {
              // --- Manejo de estados del segundo stream ---
              if (snapshotOfProducts.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshotOfProducts.hasError) {
                return Center(child: Text('Error al cargar productos: ${snapshotOfProducts.error}'));
              }
              if (!snapshotOfProducts.hasData || snapshotOfProducts.data!.docs.isEmpty) {
                // Esto puede pasar brevemente si el usuario quita el último favorito.
                return const Center(child: Text('No se encontraron productos.'));
              }

              // Mapeamos los documentos de Firestore a objetos Product.
              final products = snapshotOfProducts.data!.docs.map((doc) {
                return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              // 3. MOSTRAMOS LA LISTA: Usamos el mismo ProductCard que ya tienes.
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  // Le pasamos la información al ProductCard.
                  // Aquí, initialIsFavorite SIEMPRE es true.
                  return ProductCard(
                    product: product,
                    initialIsFavorite: true,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}