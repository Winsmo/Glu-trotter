import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_detail_page.dart'; // Importez la page de détails du produit

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedData;
  Map<String, dynamic>? productData; // Pour stocker les données du produit

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // Fonction pour récupérer les données du produit par code-barres
  Future<void> fetchProductData(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Décoder le JSON
      if (data['status'] == 1) {
        setState(() {
          productData = data['product'];
        });
        // Naviguer vers la page de détails du produit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productData: productData!),
          ),
        );
      } else {
        setState(() {
          productData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit non trouvé'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion à l\'API'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Fonction pour récupérer les données du produit par nom
  Future<void> fetchProductByName(String productName) async {
    final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&search_simple=1&action=process&json=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Décoder le JSON
      if (data['products'] != null && data['products'].isNotEmpty) {
        setState(() {
          productData = data['products'][0]; // Prendre le premier produit de la liste
        });
        // Naviguer vers la page de détails du produit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productData: productData!),
          ),
        );
      } else {
        setState(() {
          productData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucun produit trouvé'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion à l\'API'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Fonction pour rechercher un produit (par code-barres ou par nom)
  void _searchProduct() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        bool searchByName = false; // Par défaut, recherche par code-barres

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Rechercher un produit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: searchByName ? 'Entrez le nom du produit' : 'Entrez le code-barres',
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Rechercher par nom'),
                      Switch(
                        value: searchByName,
                        onChanged: (value) {
                          setState(() {
                            searchByName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la boîte de dialogue
                  },
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    if (searchQuery.isNotEmpty) {
                      if (searchByName) {
                        fetchProductByName(searchQuery); // Rechercher par nom
                      } else {
                        fetchProductData(searchQuery); // Rechercher par code-barres
                      }
                      Navigator.pop(context); // Fermer la boîte de dialogue
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Veuillez entrer une recherche valide'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text('Rechercher'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text('Scanner', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _searchProduct, // Appeler la fonction de recherche
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final barcode = barcodes.first.rawValue;
                  if (barcode != null && barcode != scannedData) {
                    setState(() {
                      scannedData = barcode;
                    });
                    fetchProductData(barcode); // Appeler l'API avec le code-barres
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Scanné : $barcode'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          // Supprimez ou commentez cette partie pour enlever le bandeau "Données scannées"
          /*
          if (scannedData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Données scannées : $scannedData',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
          */
        ],
      ),
    );
  }
}