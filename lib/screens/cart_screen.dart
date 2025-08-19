// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mi_tienda/models/product_model.dart';
import 'package:mi_tienda/services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. APPBAR CON ESTILO CONSISTENTE
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A86FF), Color(0xFF83C5BE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text('Mi Carrito', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      // 2. FONDO GRIS CLARO PARA RESALTAR LAS TARJETAS
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getCartStream(),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tu carrito está vacío.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final cartItems = cartSnapshot.data!.docs;
          final productIds = cartItems.map((item) => item.id).toList();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('products').where(FieldPath.documentId, whereIn: productIds).snapshots(),
            builder: (context, productsSnapshot) {
              if (productsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!productsSnapshot.hasData || productsSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Cargando productos...'));
              }

              final productsData = { for (var doc in productsSnapshot.data!.docs) doc.id: Product.fromFirestore(doc.data(), doc.id) };
              double totalPrice = 0;
              for (var item in cartItems) {
                final product = productsData[item.id];
                if (product != null) {
                  final quantity = item.data()['quantity'] as int;
                  totalPrice += product.price * quantity;
                }
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final product = productsData[cartItem.id];
                        final quantity = cartItem.data()['quantity'] as int;
                        if (product == null) {
                          return const SizedBox.shrink(); // No muestra nada si el producto no se encuentra
                        }
                        return _buildCartItemCard(product, quantity);
                      },
                    ),
                  ),
                  _buildTotalBar(totalPrice),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES REDISEÑADOS ---

  /// 3. TARJETA DE PRODUCTO REDISEÑADA
  Widget _buildCartItemCard(Product product, int quantity) {
    final formatCurrency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency.format(product.price),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _firestoreService.removeCartItem(product.id),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                )
              ],
            ),
          ),
          // Controles de cantidad mejorados
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => _firestoreService.updateCartItemQuantity(product.id, quantity - 1),
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _firestoreService.updateCartItemQuantity(product.id, quantity + 1),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 4. BARRA DE TOTAL REDISEÑADA
  Widget _buildTotalBar(double totalPrice) {
    final formatCurrency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Text(
                formatCurrency.format(totalPrice),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                showDialog(
                  context: context, 
                  builder: (BuildContext ctx){
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      icon: const Icon(
                        Icons.shopping_cart_checkout,
                        color: Color(0xFF3A86FF),
                        size: 48,
                      ),

                      title: const Text(
                        'Confirmar Compra',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      content: Text(
                        '¿Deseas finalizar tu compra por un total de \n${formatCurrency.format(totalPrice)}?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                              onPressed: (){
                                Navigator.of(ctx).pop();
                              }, 
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A86FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Sí, confirmar', style: TextStyle(fontSize: 16)),
                              onPressed: () async{
                                Navigator.of(ctx).pop();
                                await _firestoreService.checkout();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('!Compra realizada con éxito¡'),
                                    backgroundColor: Colors.green,
                                  )
                                );
                              },
                            )
                          ],
                        )
                      ],
                    );
                  }
                );
              },              
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3483FA),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continuar', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}