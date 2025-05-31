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
  double _maxDistance = 50;

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
      setState(() => _startDate = picked);
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
      setState(() => _endDate = picked);
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _userPosition = pos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ubicación obtenida: (${pos.latitude}, ${pos.longitude})")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  Future<void> _searchDogs() async {
    setState(() {
      isLoading = true;
      _hasSearched = true;
    });

    final snapshot = await FirebaseFirestore.instance.collection('lost_dogs').get();
    final results = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final breed = breedController.text.toLowerCase();
      final color = colorController.text.toLowerCase();
      final docBreed = (data['breed'] ?? '').toLowerCase();
      final docColor = (data['color'] ?? '').toLowerCase();
      final timestamp = data['timestamp'] as Timestamp?;
      final latitude = data['latitude'] as double?;
      final longitude = data['longitude'] as double?;

      if (breed.isNotEmpty && !docBreed.contains(breed)) return false;
      if (color.isNotEmpty && !docColor.contains(color)) return false;
      if (_startDate != null && timestamp != null && timestamp.toDate().isBefore(_startDate!)) return false;
      if (_endDate != null && timestamp != null && timestamp.toDate().isAfter(_endDate!)) return false;

      if (_userPosition != null && latitude != null && longitude != null) {
        final distance = _calculateDistance(_userPosition!.latitude, _userPosition!.longitude, latitude, longitude);
        if (distance > _maxDistance) return false;
      }

      return true;
    }).toList();

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text('Buscar Perros Perdidos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField('Raza', breedController),
            _buildTextField('Color', colorController),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectStartDate,
                    icon: const Icon(Icons.date_range),
                    label: Text(_startDate != null
                        ? DateFormat('dd/MM/yyyy').format(_startDate!)
                        : 'Fecha inicio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectEndDate,
                    icon: const Icon(Icons.date_range),
                    label: Text(_endDate != null
                        ? DateFormat('dd/MM/yyyy').format(_endDate!)
                        : 'Fecha fin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _getUserLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Obtener ubicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Slider(
              min: 1,
              max: 100,
              divisions: 20,
              value: _maxDistance,
              label: '${_maxDistance.toStringAsFixed(0)} km',
              onChanged: (value) => setState(() => _maxDistance = value),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _searchDogs,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            if (_hasSearched)
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: searchResults.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final List images = data['images'] ?? [];
                        final String imageUrl = images.isNotEmpty ? images[0] : '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentsScreen(reportId: doc.id),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Raza: ${data['breed'] ?? 'Desconocida'}'),
                                      Text('Color: ${data['color'] ?? 'Desconocido'}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
          ],
        ),
      ),
    );
  }
}
