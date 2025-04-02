import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});


  Future<Map<String, dynamic>> _fetchStatistics() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('lost_dogs').get();
    int total = snapshot.docs.length;
    int found = snapshot.docs.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['found'] == true;
    }).length;
    int lost = total - found;
    
  
    double totalResolutionTime = 0;
    int countResolved = 0;
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['found'] == true && data.containsKey('foundTimestamp')) {
        Timestamp created = data['timestamp'];
        Timestamp foundTime = data['foundTimestamp'];
        totalResolutionTime += foundTime.toDate().difference(created.toDate()).inMinutes;
        countResolved++;
      }
    }
    double avgResolutionTime = countResolved > 0 ? totalResolutionTime / countResolved : 0;

    return {
      'total': total,
      'found': found,
      'lost': lost,
      'avgResolutionTime': avgResolutionTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard de Reportes"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text("Total de Reportes"),
                    trailing: Text(stats['total'].toString()),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text("Reportes Encontrados"),
                    trailing: Text(stats['found'].toString()),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text("Reportes Perdidos"),
                    trailing: Text(stats['lost'].toString()),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text("Tiempo Promedio de Resolución (minutos)"),
                    trailing: Text(stats['avgResolutionTime'] > 0
                        ? stats['avgResolutionTime'].toStringAsFixed(1)
                        : "N/A"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
