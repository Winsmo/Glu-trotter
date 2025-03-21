import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Pour la localisation
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'dart:convert'; // Pour décoder les réponses JSON

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController(); // Contrôleur pour la carte
  final TextEditingController _searchController = TextEditingController(); // Contrôleur pour la recherche
  LatLng _center = LatLng(48.8566, 2.3522); // Centre initial de la carte (Paris)
  bool _isLoading = true; // Indicateur de chargement
  List<LatLng> _searchMarkers = []; // Liste des marqueurs de recherche

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtenir la localisation au démarrage
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez activer la localisation')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Les permissions de localisation sont refusées')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Les permissions de localisation sont définitivement refusées')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
    _mapController.move(_center, 13.0);
  }

  Future<void> _searchPlace(String query) async {
    final String url = 'https://nominatim.openstreetmap.org/search?format=json&q=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          setState(() {
            _searchMarkers = results.map((result) {
              return LatLng(
                double.parse(result['lat']),
                double.parse(result['lon']),
              );
            }).toList();
          });

          final LatLng firstResult = LatLng(
            double.parse(results[0]['lat']),
            double.parse(results[0]['lon']),
          );
          _mapController.move(firstResult, 13.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lieu non trouvé')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la recherche')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text('Carte', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un lieu ou un commerce...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPlace(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center, // Correction ici
                initialZoom: 13.0, // Correction ici
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _searchMarkers.map<Marker>((latLng) {
                    return Marker(
                      point: latLng,
                      child: Icon(Icons.location_pin, color: Colors.green, size: 40),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
