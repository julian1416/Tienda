import 'package:flutter/material.dart';
import 'package:mi_tienda/screens/register_screen.dart'; // Asegúrate que esta ruta es correcta
import 'package:mi_tienda/services/auth_service.dart';   // Asegúrate que esta ruta es correcta

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- TU LÓGICA EXISTENTE ---
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- ESTADO PARA LA NUEVA UI ---
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // --- MÉTODO DE LOGIN MEJORADO ---
  Future<void> _login() async {
    // Si ya estamos procesando, no hacemos nada.
    if (_isLoading) return;

    // Validamos el formulario con la clave que ya tenías.
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Mostramos el indicador de carga

      try {
        // Usamos tu misma llamada al servicio de autenticación
        dynamic result = await _auth.signInWithEmailAndPassword(
          _emailController.text.trim(), // Usamos .trim() para limpiar espacios
          _passwordController.text.trim(),
        );

        // Si el resultado es nulo, significa que hubo un error de credenciales
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo iniciar sesión con esas credenciales.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Si el login es exitoso, tu AuthWrapper se encargará de la navegación.
        // No necesitamos hacer Navigator.pop() aquí.

      } catch (e) {
        // Atrapamos cualquier otro error (ej. sin conexión)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocurrió un error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Importante: Nos aseguramos de ocultar el indicador de carga
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
    super.dispose();
  }

  // --- A PARTIR DE AQUÍ ESTÁ LA NUEVA UI ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Usamos un Stack para poner el formulario encima del fondo
      body: Stack(
        children: [
          buildBackground(size),
          buildLoginForm(context, size),
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
                  // Puedes cambiar este texto por el nombre de tu app
                  "MI TIENDA",
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

  Widget buildLoginForm(BuildContext context, Size size) {
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
            // Usamos tu Form con su _formKey para la validación
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3A86FF)),
                  ),
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () { /* TODO: Implementar lógica de olvidar contraseña */ },
                      child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón de Login que llama a tu lógica
                  GestureDetector(
                    onTap: _login,
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
                            : const Text("INICIAR SESIÓN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Link para ir a Registrarse
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: const Text("Regístrate", style: TextStyle(color: Color(0xFF3A86FF), fontWeight: FontWeight.bold)),
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

// CustomClipper para crear la forma de ola en el header
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