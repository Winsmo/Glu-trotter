import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Pour la localisation
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'dart:convert'; // Pour décoder les réponses JSON
import 'package:image_picker/image_picker.dart'; // Pour sélectionner une photo
import 'dart:io'; // Pour gérer les fichiers image

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController(); // Contrôleur pour la carte
  final TextEditingController _searchController = TextEditingController(); // Contrôleur pour le champ de recherche
  final TextEditingController _nameController = TextEditingController(); // Contrôleur pour le nom du lieu
  final TextEditingController _descriptionController = TextEditingController(); // Contrôleur pour la description du lieu
  LatLng _center = LatLng(48.8566, 2.3522); // Centre initial de la carte (Paris)
  bool _isLoading = true; // Indicateur de chargement
  List<LatLng> _searchMarkers = []; // Liste des marqueurs pour les résultats de recherche
  List<Map<String, dynamic>> _customMarkers = []; // Liste des marqueurs personnalisés
  File? _selectedImage; // Image sélectionnée pour le lieu
  LatLng? _selectedLocation; // Emplacement sélectionné manuellement
  bool _isSelectingLocation = false; // Indique si l'utilisateur est en train de sélectionner un emplacement

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

  // Fonction pour sélectionner une photo
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fonction pour ajouter un lieu personnalisé
  void _addCustomPlace() {
    if (_nameController.text.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir le nom et sélectionner un emplacement')),
      );
      return;
    }

    setState(() {
      _customMarkers.add({
        'position': _selectedLocation!, // Position sélectionnée
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': _selectedImage,
      });
      _nameController.clear();
      _descriptionController.clear();
      _selectedImage = null;
      _selectedLocation = null;
      _isSelectingLocation = false; // Désactiver la sélection d'emplacement
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lieu ajouté avec succès')),
    );
  }

  // Fonction pour afficher le formulaire d'ajout de lieu
  void _showAddPlaceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un lieu'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Cliquez sur la carte pour sélectionner un emplacement'),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nom du lieu'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description (facultatif)'),
                ),
                SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 100)
                    : Text('Aucune image sélectionnée'),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Sélectionner une photo (facultatif)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _addCustomPlace();
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher les détails d'un lieu
  void _showPlaceDetails(Map<String, dynamic> place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(place['name']),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place['image'] != null)
                  Image.file(place['image'], height: 200, width: double.infinity, fit: BoxFit.cover),
                SizedBox(height: 16),
                Text('Nom: ${place['name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (place['description'] != null && place['description'].isNotEmpty)
                  Text('Description: ${place['description']}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Coordonnées: ${place['position'].latitude}, ${place['position'].longitude}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text('Carte', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isSelectingLocation = true; // Activer la sélection d'emplacement
              });
              _showAddPlaceDialog(); // Afficher le formulaire d'ajout de lieu
            },
          ),
        ],
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
                minZoom: 5.0, // Zoom minimum pour éviter que la carte ne disparaisse
                maxZoom: 18.0, // Zoom maximum pour éviter que la carte ne disparaisse
                onTap: (tapPosition, latLng) {
                  if (_isSelectingLocation) {
                    setState(() {
                      _selectedLocation = latLng; // Enregistrer l'emplacement sélectionné
                    });
                  }
                },
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
                // Marqueurs personnalisés
                MarkerLayer(
                  markers: _customMarkers.map((marker) {
                    return Marker(
                      point: marker['position'],
                      builder: (context) => IconButton(
                        icon: Icon(Icons.place, color: Colors.purple, size: 40),
                        onPressed: () {
                          _showPlaceDetails(marker); // Afficher les détails du lieu
                        },
                      ),
                    );
                  }).toList(),
                ),
                // Marqueur pour l'emplacement sélectionné manuellement
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        builder: (context) => Icon(Icons.location_on, color: Colors.orange, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}