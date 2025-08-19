// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:mi_tienda/services/auth_service.dart'; // Asegúrate que esta ruta es correcta

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- TU LÓGICA EXISTENTE ---
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // --- MEJORA: AÑADIMOS UN CONTROLADOR PARA CONFIRMAR CONTRASEÑA ---
  final TextEditingController _confirmPasswordController = TextEditingController();

  // --- ESTADO PARA LA NUEVA UI ---
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // --- MÉTODO DE REGISTRO MEJORADO ---
  Future<void> _register() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      // Verificación extra: que las contraseñas coincidan
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden.'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Detenemos el proceso si no coinciden
      }

      setState(() => _isLoading = true);

      try {
        // Usamos tu misma llamada al servicio de registro
        dynamic result = await _auth.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (result == null) {
          // Firebase puede devolver null si el correo ya existe o es inválido
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo completar el registro. El correo podría ya estar en uso.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Si el registro es exitoso, volvemos a la pantalla anterior (Login)
          // para que el usuario pueda iniciar sesión.
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Cuenta creada exitosamente! Por favor, inicia sesión.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocurrió un error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- A PARTIR DE AQUÍ ESTÁ LA NUEVA UI ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          buildBackground(size),
          buildRegisterForm(context, size),
        ],
      ),
    );
  }

  Widget buildBackground(Size size) {
    return Column(
      children: [
        Container(
          height: size.height * 0.4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A86FF), Color(0xFF83C5BE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: Center(
                child: Text(
                  "CREAR CUENTA",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }

  Widget buildRegisterForm(BuildContext context, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: size.height * 0.25),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo de Email con tu validador
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Correo Electrónico"),
                    validator: (value) => value!.isEmpty ? 'Ingresa un correo' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de Contraseña con tu validador
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (value) => value!.length < 6 ? 'La contraseña debe tener al menos 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16),

                  // Nuevo Campo para Confirmar Contraseña
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: const InputDecoration(labelText: "Confirmar Contraseña"),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Botón de Registrarse
                  GestureDetector(
                    onTap: _register,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A86FF), Color(0xFF83C5BE)],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("REGISTRARSE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Link para volver a Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿Ya tienes una cuenta? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Simplemente vuelve atrás
                        child: const Text("Inicia Sesión", style: TextStyle(color: Color(0xFF3A86FF), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// El mismo CustomClipper de la pantalla de login
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}