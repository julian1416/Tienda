// lib/screens/product_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_tienda/models/product_model.dart';
import 'package:mi_tienda/services/firestore_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  ProductDetailScreen({super.key, required this.product});

  // Instancia del servicio para añadir al carrito
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Formateador de moneda para un look profesional
    final formatCurrency = NumberFormat.currency(
      locale: 'es_CO', // Formato colombiano
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      // 1. APPBAR MEJORADA
      appBar: AppBar(
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. IMAGEN GRANDE CON ANIMACIÓN
              Center(
                child: Hero(
                  tag: product.id,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 250,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. NOMBRE DEL PRODUCTO
              Text(
                product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 4. RATING Y OPINIONES (¡AÑADIDO!)
              Row(
                children: [
                  Text(product.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text('(${product.reviewCount} opiniones)', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // 5. PRECIOS CON DESCUENTO (¡AÑADIDO!)
              if (product.originalPrice != null)
                Text(
                  formatCurrency.format(product.originalPrice),
                  style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formatCurrency.format(product.price),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
                  ),
                  if (product.originalPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        '${((1 - product.price / product.originalPrice!) * 100).toStringAsFixed(0)}% OFF',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 6. ENVÍO GRATIS (¡AÑADIDO!)
              Row(
                children: const [
                  Icon(Icons.local_shipping, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Envío gratis', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 7. DESCRIPCIÓN (¡AÑADIDO!)
              const Text(
                'Descripción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.description ?? 'No hay descripción disponible.',
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),  
              ),
            ],
          ),
        ),
      ),
      // 8. BARRA INFERIOR CON BOTONES DE ACCIÓN (YA LA TENÍAS, PERO CON LA LÓGICA CORRECTA)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3483FA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de "Comprar ahora" no implementada.'))
                  );
                },
                child: const Text('Comprar ahora', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3483FA)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await _firestoreService.addProductToCart(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} fue añadido al carrito.'),
                      duration: const Duration(seconds: 2),
                    )
                  );
                },
                child: const Text('Agregar al carrito', style: TextStyle(color: Color(0xFF3483FA), fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}