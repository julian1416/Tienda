// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:mi_tienda/services/auth_service.dart';
import 'package:mi_tienda/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(
          child: Text("Usuario no encontrado.\nPor favor, inicie sesión de nuevo.", textAlign: TextAlign.center),
        ),
      );
    }

    return Scaffold(
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
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _firestoreService.getUserStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudieron cargar los datos del perfil.'));
          }

          final userData = snapshot.data!;
          final String name = userData['name'] ?? '';
          final String address = userData['address'] ?? '';
          final String email = userData['email'] ?? 'Email no disponible';
          
          // Datos para el método de pago
          final String? paymentType = userData['paymentType'];
          final String? paymentDetails = userData['paymentDetails'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(name, email),
              const SizedBox(height: 24),
              const Text('Información de la cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),

              // Tiles editables para nombre y dirección
              _buildEditableInfoTile(context, 'Nombre completo', name, 'name', Icons.person_outline),
              _buildEditableInfoTile(context, 'Dirección de envío', address, 'address', Icons.location_on_outlined),

              // Tile especial para el método de pago
              _buildPaymentInfoTile(context, paymentType, paymentDetails),
              
              const SizedBox(height: 40),
              // Botón de Cerrar Sesión
              ElevatedButton.icon(
                onPressed: () => _authService.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE LA PANTALLA ---

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.teal.shade100,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: TextStyle(fontSize: 48, color: Colors.teal.shade800),
          ),
        ),
        const SizedBox(height: 12),
        Text(name.isNotEmpty ? name : 'Sin nombre', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ],
    );
  }

  // Widget genérico para campos simples como nombre y dirección
  Widget _buildEditableInfoTile(BuildContext context, String title, String value, String fieldToUpdate, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : 'Toca para añadir'),
        trailing: const Icon(Icons.edit, size: 20, color: Colors.grey),
        onTap: () {
          _showSimpleEditDialog(context, title, value, fieldToUpdate);
        },
      ),
    );
  }

  // Widget especializado para mostrar la información de pago
  Widget _buildPaymentInfoTile(BuildContext context, String? type, String? details) {
    IconData icon;
    String subtitle = 'Toca para añadir';

    switch (type) {
      case 'Visa':
        icon = Icons.credit_card;
        if (details != null && details.length >= 4) {
          subtitle = 'Visa terminada en ${details.substring(details.length - 4)}';
        } else {
          subtitle = 'Visa (detalles incompletos)';
        }
        break;
      case 'Mastercard':
        icon = Icons.credit_card;
        if (details != null && details.length >= 4) {
          subtitle = 'Mastercard terminada en ${details.substring(details.length - 4)}';
        } else {
          subtitle = 'Mastercard (detalles incompletos)';
        }
        break;
      case 'PayPal':
        icon = Icons.paypal;
        subtitle = details ?? 'Añadir correo';
        break;
      default:
        icon = Icons.credit_card_outlined;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.edit, size: 20, color: Colors.grey),
        onTap: () {
          _showPaymentEditDialog(context, type, details);
        },
      ),
    );
  }

  // Diálogo simple para editar nombre y dirección
  void _showSimpleEditDialog(BuildContext context, String title, String currentValue, String fieldToUpdate) {
  final TextEditingController controller = TextEditingController(text: currentValue);
  final Map<String, IconData> icons = {
    'name': Icons.person,
    'address': Icons.location_on,
  };

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      icon: Icon(icons[fieldToUpdate] ?? Icons.edit, color: const Color(0xFF3A86FF), size: 40),
      title: Text('Editar $title', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Nuevo valor',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icons[fieldToUpdate]),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A86FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final newValue = controller.text.trim();
            await _firestoreService.updateUserData({fieldToUpdate: newValue});
            Navigator.pop(context);
          },
          child: const Text('Guardar', style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

  // Diálogo avanzado para editar el método de pago
  void _showPaymentEditDialog(BuildContext context, String? currentType, String? currentDetails) {
  final TextEditingController controller = TextEditingController(text: currentDetails);
  String? selectedType = currentType;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            icon: const Icon(Icons.payment, color: Color(0xFF3A86FF), size: 40),
            title: const Text('Método de Pago', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Usamos un estilo más compacto y visual para los RadioListTile
                  RadioListTile<String>(
                    title: const Text('Visa'),
                    secondary: const Icon(Icons.credit_card),
                    value: 'Visa',
                    groupValue: selectedType,
                    onChanged: (value) => setDialogState(() => selectedType = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('Mastercard'),
                    secondary: const Icon(Icons.credit_card),
                    value: 'Mastercard',
                    groupValue: selectedType,
                    onChanged: (value) => setDialogState(() => selectedType = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('PayPal'),
                    secondary: const Icon(Icons.paypal),
                    value: 'PayPal',
                    groupValue: selectedType,
                    onChanged: (value) => setDialogState(() => selectedType = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  if (selectedType != null)
                    TextField(
                      controller: controller,
                      keyboardType: selectedType == 'PayPal' ? TextInputType.emailAddress : TextInputType.number,
                      decoration: InputDecoration(
                        labelText: selectedType == 'PayPal' ? 'Correo de PayPal' : 'Número:',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A86FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final newDetails = controller.text.trim();
                  if (newDetails.isNotEmpty && selectedType != null) {
                    await _firestoreService.updateUserData({
                      'paymentType': selectedType,
                      'paymentDetails': newDetails,
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Guardar', style: TextStyle(fontSize: 16)),
              ),
            ],
          );
        },
      );
    },
  );
}
}