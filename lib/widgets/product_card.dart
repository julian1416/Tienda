// lib/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:mi_tienda/models/product_model.dart';

import 'package:mi_tienda/screens/product_detail_screen.dart';
import 'package:mi_tienda/services/firestore_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool initialIsFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.initialIsFavorite,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialIsFavorite;
  }
  
  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsFavorite != oldWidget.initialIsFavorite) {
      setState(() {
        isFavorite = widget.initialIsFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CAMBIO CLAVE: Usamos un patrón personalizado para forzar el símbolo al inicio.
    final formatCurrency = NumberFormat.currency(
      locale: 'es_CO', // Se mantiene para usar '.' como separador de miles.
      customPattern: '\$ #,##0', // Patrón: Símbolo, espacio, y el número formateado.
      decimalDigits: 0,
    );

    final bool hasDiscount = widget.product.originalPrice != null && widget.product.originalPrice! > widget.product.price;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.product.id,
              child: SizedBox(
                width: 100,
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey[700],
                          size: 24.0,
                        ),
                        onPressed: () async {
                          setState(() { isFavorite = !isFavorite; });
                          await _firestoreService.toggleFavoriteStatus(widget.product.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (hasDiscount)
                    Text(
                      formatCurrency.format(widget.product.originalPrice),
                      style: TextStyle(
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                        fontSize: 15,
                      ),
                    ),

                  Text(
                    formatCurrency.format(widget.product.price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),

                  if (hasDiscount)
                    Text(
                      '${((1 - widget.product.price / widget.product.originalPrice!) * 100).toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  const SizedBox(height: 4),

                  Text(
                    'Envío gratis',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}