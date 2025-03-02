import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  ProductDetailPage({required this.productData});

  // Liste des ingrédients contenant du gluten
  final List<String> glutenIngredients = [
    'blé', 'orge', 'seigle', 'avoine', 'gluten', 'farine de blé'
  ];

  @override
  Widget build(BuildContext context) {
    // Déterminer la couleur du bandeau en fonction de la présence de gluten
    Color bannerColor;
    String bannerText;
    String ingredients = productData['ingredients_text'] ?? 'Non disponible';
    bool containsGluten = glutenIngredients.any((ingredient) =>
        ingredients.toLowerCase().contains(ingredient));

    if (containsGluten) {
      bannerColor = Colors.red;
      bannerText = 'Contient du gluten';
    } else if (!containsGluten && ingredients != 'Non disponible') {
      bannerColor = Colors.green;
      bannerText = 'Sans gluten';
    } else {
      bannerColor = Colors.orange;
      bannerText = 'Information sur le gluten non disponible';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du produit'),
      ),
      body: Column(
        children: [
          Container(
            color: bannerColor,
            padding: EdgeInsets.all(16),
            width: double.infinity,
            child: Text(
              bannerText,
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom du produit : ${productData['product_name'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Marque : ${productData['brands'] ?? 'Non disponible'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ingrédients : $ingredients',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Composants : ${productData['components'] ?? 'Non disponible'}', // Exemple de champ, à adapter selon l'API
                    style: TextStyle(fontSize: 16),
                  ),
                  if (containsGluten) ...[
                    SizedBox(height: 16),
                    Text(
                      'Attention : Ce produit contient du gluten. Êtes-vous sûr de vouloir continuer ?',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
