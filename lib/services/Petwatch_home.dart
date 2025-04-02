import 'package:flutter/material.dart';
import 'report_lost_dog_screen.dart';
import 'reports_list_screen.dart';

class PetwatchHome extends StatelessWidget {
  const PetwatchHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🐾 PetWatch")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportLostDogScreen()),
                );
              },
              child: const Text("🐕 Reportar un Perro Perdido"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsListScreen()),
                );
              },
              child: const Text("📜 Ver reportes"),
            ),
          ],
        ),
      ),
    );
  }
}
