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
          MaterialPageRoute(builder: (context) => const HomePage()),
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

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '❌ El correo ingresado no está registrado.';
      case 'wrong-password':
        return '❌ La contraseña es incorrecta.';
      case 'invalid-email':
        return '❌ Formato de correo inválido.';
      case 'weak-password':
        return '⚠ La contraseña es demasiado débil.';
      case 'email-already-in-use':
        return '⚠ Este correo ya está en uso.';
      default:
        return '❌ Error desconocido.';
    }
  }

  void mostrarMensaje(String mensaje, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              "assets/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animación con AnimatedSwitcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (widget, animation) =>
                              ScaleTransition(scale: animation, child: widget),
                          child: Text(
                            isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                            key: ValueKey<bool>(isLogin),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo de Nombre (Solo en registro)
                        if (!isLogin)
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre y Apellido',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        if (!isLogin) const SizedBox(height: 15),
                        // Campo de Correo Electrónico
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Campo de Contraseña con botón para mostrar/ocultar
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Botón "¿Olvidaste tu contraseña?"
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: resetPassword,
                            child: const Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Botón de iniciar sesión o registro
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: authenticate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                  textStyle: const TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                              ),
                        const SizedBox(height: 20),
                        // Botón para alternar entre login y registro
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(isLogin
                              ? '¿No tienes cuenta? Regístrate'
                              : '¿Ya tienes cuenta? Inicia sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
