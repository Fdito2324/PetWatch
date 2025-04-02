import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 🔹 Firestore

  Future<String?> signUpWithEmail(String email, String password, String nombreCompleto) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(nombreCompleto);
        await user.reload();

        // 🔹 Guardar usuario en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nombre': nombreCompleto,
          'correo': email,
          'creadoEn': DateTime.now(),
        });

        await analytics.logSignUp(signUpMethod: 'email_password');
        return null; // Éxito, no hay error
      }
    } on FirebaseAuthException catch (e) {
      return _getFirebaseErrorMessage(e.code);
    } catch (e) {
      return "❌ Error inesperado: $e";
    }
    return "❌ No se pudo registrar. Intenta nuevamente.";
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await analytics.logLogin(loginMethod: 'email_password');
      return null; 
    } on FirebaseAuthException catch (e) {
      return _getFirebaseErrorMessage(e.code);
    } catch (e) {
      return "❌ Error inesperado: $e";
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '❌ No se encontró una cuenta con este correo.';
      case 'wrong-password':
        return '❌ La contraseña ingresada es incorrecta.';
      case 'email-already-in-use':
        return '⚠ Este correo ya está registrado.';
      case 'weak-password':
        return '⚠ La contraseña es demasiado débil.';
      case 'invalid-email':
        return '❌ El formato del correo no es válido.';
      case 'network-request-failed':
        return '⚠ No hay conexión a Internet.';
      case 'too-many-requests':
        return '⚠ Demasiados intentos fallidos. Inténtalo más tarde.';
      default:
        return '❌ Error desconocido. Código: $errorCode';
    }
  }
}
