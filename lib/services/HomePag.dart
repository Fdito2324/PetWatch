import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'map_screen.dart';
import 'report_lost_dog_screen.dart';
import 'search_lost_dog_screen.dart';
import '../auth_screen.dart';
import 'user_profile_screen.dart';
import 'dashboard_screen.dart';
import 'my_reports_screen.dart';
import 'conversation_list_screen.dart';

// 🎨 Paleta de colores clara y moderna
const Color kBackgroundColor = Color(0xFFFAFAFA);
const Color kButtonColor = Color(0xFFA5D6A7);
const Color kButtonTextColor = Color(0xFF2E3A59);
const Color kAppBarColor = Color(0xFF81C784);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("PetWatch 🐶"),
        backgroundColor: kAppBarColor,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConversationListScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble, color: Colors.white, size: 22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Selecciona una opción:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kButtonTextColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuButton(context, "📍 Ver Mapa de Reportes", Icons.map, const MapScreen()),
              _buildMenuButton(context, "🐾 Reportar un Perro Perdido", Icons.pets, const ReportLostDogScreen()),
              _buildMenuButton(context, "🔍 Buscar un Perro Perdido", Icons.search, const SearchLostDogScreen()),
              _buildMenuButton(context, "📋 Mis Reportes", Icons.article, const MyReportsScreen()),
              _buildMenuButton(context, "📊 Dashboard", Icons.bar_chart, const DashboardScreen()),
              _buildMenuButton(
                context,
                "🚪 Cerrar Sesión",
                Icons.logout,
                null,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, Widget? screen,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20, color: kButtonTextColor),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, color: kButtonTextColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: kButtonTextColor,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen!),
              );
            },
      ),
    );
  }
}
