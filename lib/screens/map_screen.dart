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
  final TextEditingController _searchController = TextEditingController(); // Contrôleur pour le champ de recherche
  LatLng _center = LatLng(48.8566, 2.3522); // Centre initial de la carte (Paris)
  bool _isLoading = true; // Indicateur de chargement
  List<LatLng> _searchMarkers = []; // Liste des marqueurs pour les résultats de recherche

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtenir la localisation au démarrage
  }

  // Fonction pour obtenir la localisation actuelle
  Future<void> _getCurrentLocation() async {
    // Vérifier les permissions
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

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude); // Mettre à jour le centre de la carte
      _isLoading = false; // Fin du chargement
    });
    _mapController.move(_center, 13.0); // Déplacer la carte vers la position actuelle
  }

  // Fonction pour rechercher un lieu
  Future<void> _searchPlace(String query) async {
    final String url =
        'https://nominatim.openstreetmap.org/search?format=json&q=$query';

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
            }).toList(); // Mettre à jour la liste des marqueurs de recherche
          });

          // Déplacer la carte vers le premier résultat de la recherche
          final LatLng firstResult = LatLng(
            double.parse(results[0]['lat']),
            double.parse(results[0]['lon']),
          );
          _mapController.move(firstResult, 13.0); // Correction ici
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
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un lieu ou un commerce...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPlace(_searchController.text); // Lancer la recherche
                  },
                ),
              ),
            ),
          ),
          // Carte
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement
                : FlutterMap(
              mapController: _mapController, // Contrôleur de la carte
              options: MapOptions(
                center: _center, // Centre de la carte
                zoom: 13.0, // Niveau de zoom initial
                onTap: (_, __) {}, // Activer les interactions de la carte
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Marqueur pour la position actuelle (point bleu)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      builder: (context) => Icon(Icons.location_pin, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
                // Marqueurs pour les résultats de recherche (points verts)
                MarkerLayer(
                  markers: _searchMarkers.map((latLng) {
                    return Marker(
                      point: latLng,
                      builder: (context) => Icon(Icons.location_pin, color: Colors.green, size: 40),
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