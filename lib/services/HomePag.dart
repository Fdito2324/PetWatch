import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';
import 'report_lost_dog_screen.dart';
import 'search_lost_dog_screen.dart';
import '../auth_screen.dart';
import 'package:fernandovidal/services/user_profile_screen.dart';
import 'package:fernandovidal/services/dashboard_screen.dart';
import 'package:fernandovidal/services/my_reports_screen.dart';
import 'package:fernandovidal/services/conversation_list_screen.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PetWatch 🐶"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Selecciona una opción:",
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuButton(
                    context,
                    "📍 Ver Mapa de Reportes",
                    Colors.amber,
                    Icons.map,
                    const MapScreen(),
                  ),
                  _buildMenuButton(
                    context,
                    "🐾 Reportar un Perro Perdido",
                    Colors.redAccent,
                    Icons.pets,
                    const ReportLostDogScreen(),
                  ),
                  _buildMenuButton(
                    context,
                    "🔍 Buscar un Perro Perdido",
                    Colors.green,
                    Icons.search,
                    const SearchLostDogScreen(),
                  ),
                  _buildMenuButton(
                    context,
                    "👤 Perfil del Usuario",
                    Colors.blue,
                    Icons.person,
                    const UserProfileScreen(),
                  ),
                  _buildMenuButton(
                    context,
                    "📊 Dashboard",
                    Colors.purple,
                    Icons.dashboard,
                    const DashboardScreen(),
                  ),
                  _buildMenuButton(
                    context,
                    "📜 Mis Reportes",
                    Colors.orange,
                    Icons.history,
                    const MyReportsScreen(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black26, thickness: 1),
                  _buildLogoutButton(context),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, Color color, IconData icon, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        icon: Icon(icon, size: 30),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        },
        icon: const Icon(Icons.logout, size: 30, color: Colors.white),
        label: const Text("Cerrar Sesión", style: TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
