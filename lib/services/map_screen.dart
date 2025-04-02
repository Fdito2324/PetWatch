import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _defaultCenter = const LatLng(-23.6509, -70.3975);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    FirebaseFirestore.instance.collection('lost_dogs').snapshots().listen((querySnapshot) {
      if (!mounted) return;
      setState(() {
        _markers.clear();
        for (var doc in querySnapshot.docs) {
          final data = doc.data();

          final double? latitude = double.tryParse(data['latitude'].toString());
          final double? longitude = double.tryParse(data['longitude'].toString());

          if (latitude != null && longitude != null) {
            final markerId = MarkerId(doc.id);
            final position = LatLng(latitude, longitude);
            final String name = data['name'] ?? "Desconocido";
            final String breed = data['breed'] ?? "Raza desconocida";
            final String details = data['details'] ?? "No hay observaciones";
            final String imageUrl = data['imageUrl'] ?? "";

            final marker = Marker(
              markerId: markerId,
              position: position,
              infoWindow: InfoWindow(
                title: name,
                snippet: "Raza: $breed\nDetalles: $details",
                onTap: () {
                  _showReportDetails(context, name, breed, details, imageUrl);
                },
              ),
            );

            _markers.add(marker);
          } else {
            print("⚠ Error: Coordenadas inválidas en Firestore para el documento ${doc.id}");
          }
        }
      });
    });
  }

  void _showReportDetails(BuildContext context, String name, String breed, String details, String imageUrl) {
    print("🖼️ Mostrando imagen: $imageUrl");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        children: [
                          const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text("❌ Error al cargar imagen: $error"),
                        ],
                      );
                    },
                  )
                : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            const SizedBox(height: 10),
            Text("🐾 Raza: $breed", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("📌 Detalles: $details"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Reportes 🗺")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _defaultCenter,
          zoom: 14.0,
        ),
        markers: _markers,
      ),
    );
  }
}
