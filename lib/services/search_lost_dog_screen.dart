import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:fernandovidal/services/comments_screen.dart';

class SearchLostDogScreen extends StatefulWidget {
  const SearchLostDogScreen({super.key});

  @override
  _SearchLostDogScreenState createState() => _SearchLostDogScreenState();
}

class _SearchLostDogScreenState extends State<SearchLostDogScreen> {
  final TextEditingController breedController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  String? selectedStatus;
  
  DateTime? _startDate;
  DateTime? _endDate;
  Position? _userPosition;
  double _maxDistance = 50; // Distancia máxima en kilómetros

  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false;
  bool _hasSearched = false;

  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = pos;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ubicación obtenida: (${pos.latitude}, ${pos.longitude})")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error obteniendo ubicación: $e")),
      );
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Retorna la distancia en kilómetros
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  Future<void> _searchDogs() async {
    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance.collection('lost_dogs');

    if (breedController.text.isNotEmpty) {
      query = query.where('breed', isEqualTo: breedController.text.trim());
    }
    if (colorController.text.isNotEmpty) {
      query = query.where('color', isEqualTo: colorController.text.trim());
    }
    if (selectedStatus != null) {
    
      query = query.where('found', isEqualTo: selectedStatus == "Encontrado");
    }
    if (_startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!));
    }
    if (_endDate != null) {
      DateTime adjustedEndDate = _endDate!.add(const Duration(days: 1));
      query = query.where('timestamp', isLessThan: Timestamp.fromDate(adjustedEndDate));
    }

    QuerySnapshot result = await query.get();
    List<DocumentSnapshot> docs = result.docs;

    // Filtrar localmente por distancia si se obtuvo la ubicación del usuario
    if (_userPosition != null) {
      docs = docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['latitude'] != null && data['longitude'] != null) {
          double? lat = double.tryParse(data['latitude'].toString());
          double? lon = double.tryParse(data['longitude'].toString());
          if (lat != null && lon != null) {
            double distance = _calculateDistance(_userPosition!.latitude, _userPosition!.longitude, lat, lon);
            return distance <= _maxDistance;
          }
        }
        return false;
      }).toList();
    }

    setState(() {
      searchResults = docs;
      isLoading = false;
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    breedController.dispose();
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text("🔍 Buscar un Perro Perdido")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtros básicos
            TextField(
              controller: breedController,
              decoration: const InputDecoration(labelText: "🐾 Raza"),
            ),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: "🎨 Color"),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              hint: const Text("Estado"),
              items: ["Perdido", "Encontrado"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedStatus = newValue;
                });
              },
            ),
            // Filtros de fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _selectStartDate,
                  child: Text(_startDate == null ? "Fecha desde" : "Desde: ${formatter.format(_startDate!)}"),
                ),
                ElevatedButton(
                  onPressed: _selectEndDate,
                  child: Text(_endDate == null ? "Fecha hasta" : "Hasta: ${formatter.format(_endDate!)}"),
                ),
              ],
            ),
            // Filtros de ubicación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _getUserLocation,
                  child: Text(_userPosition == null ? "Obtener mi ubicación" : "Ubicación obtenida"),
                ),
                Text("Distancia: ${_maxDistance.toStringAsFixed(0)} km"),
              ],
            ),
            Slider(
              min: 1,
              max: 100,
              divisions: 99,
              value: _maxDistance,
              label: _maxDistance.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchDogs,
              child: const Text("🔎 Buscar"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _hasSearched
                        ? (searchResults.isEmpty
                            ? const Center(child: Text("❌ No se encontraron resultados"))
                            : ListView.builder(
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot doc = searchResults[index];
                                  Map<String, dynamic> dog = doc.data() as Map<String, dynamic>;
                                  return ListTile(
                                    leading: () {
                                      if (dog['imageUrls'] != null &&
                                          dog['imageUrls'] is List &&
                                          (dog['imageUrls'] as List).isNotEmpty) {
                                        String firstImageUrl = (dog['imageUrls'] as List)[0];
                                        return Image.network(
                                          firstImageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.image_not_supported, size: 50, color: Colors.red);
                                          },
                                        );
                                      } else if (dog['imageUrl'] != null && dog['imageUrl'].toString().isNotEmpty) {
                                        return Image.network(
                                          dog['imageUrl'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.image_not_supported, size: 50, color: Colors.red);
                                          },
                                        );
                                      } else {
                                        return const Icon(Icons.pets, size: 50, color: Colors.grey);
                                      }
                                    }(),
                                    title: Text(dog['name'] ?? "Sin nombre"),
                                    subtitle: Text("🐾 ${dog['breed'] ?? 'Desconocido'} | 🎨 ${dog['color'] ?? 'No especificado'}"),
                                    onTap: () => _showDetails(context, doc),
                                  );
                                },
                              ))
                        : Container(),
                  ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> dog = doc.data() as Map<String, dynamic>;
    List<dynamic> imageUrls = [];
    if (dog['imageUrls'] != null && dog['imageUrls'] is List) {
      imageUrls = dog['imageUrls'];
    } else if (dog['imageUrl'] != null && dog['imageUrl'].toString().isNotEmpty) {
      imageUrls = [dog['imageUrl']];
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dog['name'] ?? "Sin nombre"),
        content: Container(
          width: double.maxFinite,
          height: 400, // Altura fija para el contenido del diálogo
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imageUrls.isNotEmpty
                    ? Container(
                        height: 200, // Altura fija para el carrusel
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: double.infinity,
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                                },
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                const SizedBox(height: 10),
                Text("🐾 Raza: ${dog['breed'] ?? 'Desconocido'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("🎨 Color: ${dog['color'] ?? 'No especificado'}"),
              ],
            ),
          ),
        ),
        actions: [
          if (dog['found'] != true)
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('lost_dogs')
                      .doc(doc.id)
                      .update({
                    'found': true,
                    'foundTimestamp': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reporte marcado como encontrado.")),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error marcando como encontrado: $e")),
                  );
                }
              },
              child: const Text("Marcar como encontrado"),
            ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(reportId: doc.id),
                ),
              );
            },
            child: const Text("Ver comentarios"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }
}
