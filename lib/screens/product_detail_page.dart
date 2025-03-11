import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  ProductDetailPage({required this.productData});

  // Liste des ingrédients contenant du gluten
  final List<String> glutenIngredients = [
    'blé', 'orge', 'seigle', 'avoine', 'gluten', 'farine de blé', 'malt', 'wheat', 'barley', 'rye', 'oats', 'gluten', 'wheat flour', 'malt', 'trigo', 'cebada', 'centeno', 'avena', 'gluten', 'harina de trigo', 'malta', '小麦', 'xiǎomài', '大麦', 'dàmài', '黑麦', 'hēimài', '燕麦', 'yànmài', '麸质', 'fūzhì', '小麦粉', 'xiǎomài fěn', '麦芽', 'màiyá', 'गेहूँ', 'gehū̃', 'जौ', 'jau', 'राई', 'rāī', 'जई', 'jaī', 'ग्लूटेन', 'glūṭena', 'गेहूँ का आटा', 'gehū̃ kā āṭā', 'माल्ट', 'mālṭa', 'قمح', 'qamḥ', 'شعير', 'sha‘īr', 'جاودار', 'jāwdār', 'شوفان', 'shūfān', 'غلوتين', 'ghlūtīn', 'دقيق القمح', 'daqīq al-qamḥ', 'مالت', 'mālt', 'গম', 'gama', 'যব', 'jaba', 'রাই', 'rāi', 'জই', 'jai', 'গ্লুটেন', 'gluṭena', 'গমের আটা', 'gamer āṭā', 'মাল্ট', 'mālṭa', 'trigo', 'cevada', 'centeio', 'aveia', 'glúten', 'farinha de trigo', 'malte', 'пшеница', 'pshenitsa', 'ячмень', 'yachmen', 'рожь', 'roz', 'овёс', 'ovos', 'глютен', 'glyuten', 'пшеничная мука', 'pshenichnaya muká', 'солод', 'solod', '小麦', 'komugi', '大麦', 'ōmugi', 'ライ麦', 'raimugi', 'オートミール', 'ōtomīru', 'グルテン', 'guruten', '小麦粉', 'komugiko', 'モルト', 'moruto', 'ਕਣਕ', 'kaṇak', 'ਜਵਾਂ', 'javā̃', 'ਰਾਈ', 'rāī', 'ਜਵਾਈ', 'javāī', 'ਗਲੂਟਨ', 'galūṭana', 'ਕਣਕ ਦਾ ਆਟਾ', 'kaṇak dā āṭā', 'ਮਾਲਟ', 'mālaṭa', 'Weizen', 'Gerste', 'Roggen', 'Hafer', 'Gluten', 'Weizenmehl', 'Malz', 'gandum', 'jelai', 'jagung', 'oat', 'gluten', 'tepung gandum', 'malt', 'గోధుమ', 'gōdhuma', 'యవ్వ', 'yavva', 'రాగి', 'rāgi', 'ఓట్స్', 'ōṭs', 'గ్లూటెన్', 'glūṭen', 'గోధుమ పిండి', 'gōdhuma piṇḍi', 'మాల్ట్', 'mālṭ', 'lúa mì', 'đại mạch', 'lúa mạch đen', 'yến mạch', 'gluten', 'bột mì', 'mạch nha', 'buğday', 'arpa', 'çavdar', 'yulaf', 'gluten', 'buğday unu', 'malt', '밀', 'mil', '보리', 'bori', '호밀', 'homil', '귀리', 'gwiri', '글루텐', 'geulluten', '밀가루', 'milgaru', '맥아', 'maega', 'grano', 'orzo', 'segale', 'avena', 'glutine', 'farina di grano', 'malto', 'கோதுமை', 'kōtumai', 'பார்லி', 'pārli', 'ராய்', 'rāy', 'ஓட்ஸ்', 'ōṭs', 'குளூட்டன்', 'kuḷūṭṭaṉ', 'கோதுமை மாவு', 'kōtumai māvu', 'மால்ட்', 'mālṭ', 'گیہوں', 'gehū̃', 'جو', 'jau', 'رائی', 'rāī', 'جئی', 'jaī', 'گلوٹین', 'glūṭīn', 'گیہوں کا آٹا', 'gehū̃ kā āṭā', 'مالٹ', 'mālṭ',
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
