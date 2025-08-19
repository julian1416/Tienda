// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_tienda/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna un Stream de la lista de productos.
  Stream<List<Product>> getProductsStream() {
    return _db
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Product.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id);
            }).toList());
  }

  // --- MÉTODO PARA AÑADIR/QUITAR FAVORITOS (COMPLETADO Y CORREGIDO) ---
  Future<void> toggleFavoriteStatus(String productId) async {
    // 1. Obtenemos el usuario actual
    final User? user = _auth.currentUser;

    // 2. Si no hay usuario, no hacemos nada.
    if (user == null) {
      return; 
    }

    // 3. Apuntamos al documento del usuario. ¡Esta línea debe estar DENTRO del método!
    final userDocRef = _db.collection('users').doc(user.uid);

    // 4. El 'try-catch' debe envolver la lógica.
    try {
      // 5. Obtenemos los datos actuales del usuario
      final doc = await userDocRef.get();
      
      // 6. Sacamos la lista de favoritos. Es más seguro convertirla a List<String>.
      //    Y usamos el nombre 'favoriteProductIds' que definimos en el AuthService.
      final List<String> favoriteProductIds = List<String>.from(doc.data()?['favoriteProductIds'] ?? []);

      // 7. La lógica del "toggle" para añadir o quitar
      if (favoriteProductIds.contains(productId)) {
        // Si ya es favorito, lo quitamos de la lista
        userDocRef.update({
          'favoriteProductIds': FieldValue.arrayRemove([productId])
        });
      } else {
        // Si no es favorito, lo añadimos a la lista
        userDocRef.update({
          'favoriteProductIds': FieldValue.arrayUnion([productId])
        });
      }
    } catch (e) {
      print("Error al actualizar favoritos: $e");
      // Opcional: podrías relanzar el error si quieres manejarlo en la UI.
      // throw e;
    }
  }

  // --- NUEVO MÉTODO PARA "ESCUCHAR" LA LISTA DE FAVORITOS ---
  /// Retorna un Stream con la lista de IDs de los productos favoritos del usuario.
  Stream<List<String>> getUserFavoritesStream() {
    final User? user = _auth.currentUser;
    if (user == null) {
      // Si no hay usuario, devolvemos un Stream que contiene una lista vacía.
      return Stream.value([]);
    }
    
    // Apuntamos al documento del usuario y escuchamos sus cambios
    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      // Verificamos si el documento existe y tiene datos
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      // Convertimos el campo 'favoriteProductIds' a una lista de Strings.
      // Si el campo no existe, devolvemos una lista vacía.
      return List<String>.from(snapshot.data()!['favoriteProductIds'] ?? []);
    });
  }

  /// (Para el futuro) Ejemplo de cómo obtener un solo producto por su ID.
  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<Map<String, dynamic>?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      return snapshot.data();
    });
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    try {
      await _db.collection('users').doc(currentUser.uid).update(data);
    } catch (e) {
      print("Error al actualizar datos del usuario: $e");
    }
  }

  Future<void> addProductToCart(String productId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final cartItemRef = _db.collection('users').doc(user.uid).collection('cart').doc(productId);

    final doc = await cartItemRef.get();

    if(doc.exists){
      await cartItemRef.update({
        'quantity': FieldValue.increment(1)});
    }else{
      // Si el documento no existe, lo creamos con una cantidad inicial de 1
      await cartItemRef.set({
        'productId': productId,
        'quantity': 1,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCartStream() {
  final User? user = _auth.currentUser;
  if (user == null) {
    return Stream.empty(); // Devuelve un stream vacío si no hay usuario
  }
  return _db
      .collection('users')
      .doc(user.uid)
      .collection('cart')
      .orderBy('addedAt', descending: true) // Opcional: para mostrar los más nuevos primero
      .snapshots();
}

/// Actualiza la cantidad de un producto en el carrito.
Future<void> updateCartItemQuantity(String productId, int newQuantity) async {
  final User? user = _auth.currentUser;
  if (user == null) return;

  final cartItemRef = _db.collection('users').doc(user.uid).collection('cart').doc(productId);

  if (newQuantity > 0) {
    await cartItemRef.update({'quantity': newQuantity});
  } else {
    // Si la cantidad llega a 0, eliminamos el producto del carrito
    await cartItemRef.delete();
  }
}

/// Elimina un producto del carrito.
Future<void> removeCartItem(String productId) async {
  final User? user = _auth.currentUser;
  if (user == null) return;

  await _db.collection('users').doc(user.uid).collection('cart').doc(productId).delete();
}

/// Simula la finalización de la compra vaciando el carrito del usuario.
Future<void> checkout() async {
  final User? user = _auth.currentUser;
  if (user == null) return;

  // 1. Obtenemos una referencia a la subcolección 'cart' del usuario.
  final CollectionReference cartRef = _db.collection('users').doc(user.uid).collection('cart');
  
  // 2. Obtenemos todos los documentos (items) que hay en el carrito.
  final QuerySnapshot cartSnapshot = await cartRef.get();

  // 3. Creamos un "batch" de escritura. Esto es mucho más eficiente
  //    que borrar los documentos uno por uno. Agrupa todas las operaciones
  //    en una sola solicitud al servidor.
  final WriteBatch batch = _db.batch();

  // 4. Recorremos cada documento del carrito y añadimos una operación de borrado al batch.
  for (final DocumentSnapshot doc in cartSnapshot.docs) {
    batch.delete(doc.reference);
  }

  // 5. Ejecutamos todas las operaciones de borrado a la vez.
  await batch.commit();
}
}