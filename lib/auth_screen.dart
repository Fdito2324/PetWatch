import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fernandovidal/auth_service.dart';
import 'package:fernandovidal/services/HomePag.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool isPasswordVisible = false;

  final Color backgroundColor = const Color(0xFFE0F2F1); // Verde-agua claro
  final Color primaryColor = const Color(0xFFFFA726); // Naranja vibrante
  final Color accentColor = const Color(0xFF004D40); // Verde oscuro profundo
  final Color buttonTextColor = Colors.white;

  Future<void> authenticate() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String nombreCompleto = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && nombreCompleto.isEmpty)) {
      mostrarMensaje('⚠ Por favor, completa todos los campos', context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? errorMessage;

      if (isLogin) {
        errorMessage = await AuthService().signInWithEmail(email, password);
      } else {
        errorMessage = await AuthService().signUpWithEmail(email, password, nombreCompleto);
      }

      if (errorMessage == null) {
        mostrarMensaje('✅ ${isLogin ? 'Inicio de sesión' : 'Registro'} exitoso', context);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => HomePage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        mostrarMensaje(errorMessage, context);
      }
    } catch (e) {
      mostrarMensaje('❌ Error inesperado: $e', context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
        mostrarMensaje("📩 Se ha enviado un enlace de recuperación a tu correo.", context);
      } catch (e) {
        mostrarMensaje("❌ Error al enviar el correo de recuperación.", context);
      }
    } else {
      mostrarMensaje("⚠ Ingresa tu correo para recuperar la contraseña.", context);
    }
  }

  void mostrarMensaje(String mensaje, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  InputDecoration customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/paw_logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                isLogin ? 'Bienvenido a PetWatch' : 'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 20),
              if (!isLogin)
                TextField(
                  controller: nameController,
                  decoration: customInputDecoration('Nombre completo'),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: customInputDecoration('Correo electrónico'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: customInputDecoration('Contraseña').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: buttonTextColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: isLoading ? null : authenticate,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isLogin ? 'Iniciar Sesión' : 'Registrarse'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: isLoading ? null : resetPassword,
                child: const Text("¿Olvidaste tu contraseña?"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
