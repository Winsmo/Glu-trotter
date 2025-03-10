import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'calendar_screen.dart'; // Importation de la classe Event

void main() {
  runApp(MaterialApp(
    home: RecipesPage(),
  ));
}

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final List<Map<String, String>> recipes = [
    {
      "title": "Pâtes Carbonara",
      "image": "assets/carbonara.jpg",
      "description": "Pâtes Carbonara sans gluten\n\nIngrédients:\n- 200g pâtes sans gluten\n- 100g guanciale ou pancetta\n- 3 œufs\n- 50g parmesan\n- 50g pecorino\n- poivre noir\n- sel\n\nÉtapes:\nFaire cuire les pâtes selon les instructions du paquet. Pendant ce temps, couper le guanciale en petits dés et le faire revenir dans une poêle jusqu'à ce qu'il soit croustillant. Dans un bol, battre les œufs avec le parmesan, le pecorino, une pincée de sel et une généreuse quantité de poivre noir. Une fois les pâtes cuites et égouttées, les ajouter rapidement dans la poêle avec le guanciale, puis retirer du feu et incorporer le mélange d'œufs en remuant vigoureusement pour éviter que les œufs ne cuissent trop. Servir immédiatement."
    },
    {
      "title": "Salade César",
      "image": "assets/cesar.jpg",
      "description": "Salade César sans gluten\n\nIngrédients:\n- 1 laitue romaine\n- 100g poulet grillé\n- 50g parmesan\n- croûtons sans gluten\n- sauce César sans gluten\n- huile d'olive\n- jus de citron\n\nÉtapes:\nLaver et couper la laitue romaine en morceaux. Ajouter le poulet grillé coupé en dés, les copeaux de parmesan et les croûtons sans gluten. Préparer la sauce César en mélangeant de la mayonnaise, de l'ail écrasé, du jus de citron, de la moutarde de Dijon, de l'huile d'olive et du parmesan râpé. Verser la sauce sur la salade et bien mélanger avant de servir."
    },
    {
      "title": "Tarte aux pommes",
      "image": "assets/tarte.jpg",
      "description": "Tarte aux pommes sans gluten\n\nIngrédients:\n- 200g farine de riz\n- 50g fécule de maïs\n- 100g beurre froid\n- 4-5 cuillères à soupe d'eau froide\n- 4 pommes\n- 50g sucre\n- 1 cuillère à café cannelle\n\nÉtapes:\nPréparer la pâte en mélangeant la farine de riz, la fécule de maïs et le beurre froid coupé en morceaux jusqu'à obtenir une texture sableuse. Ajouter l'eau froide et mélanger jusqu'à former une boule de pâte. Étaler la pâte dans un moule à tarte. Éplucher et couper les pommes en fines tranches, puis les disposer sur la pâte. Saupoudrer de sucre et de cannelle. Cuire au four à 180°C pendant 30-35 minutes, jusqu'à ce que les pommes soient tendres et la pâte dorée."
    },
    {
      "title": "Pizza Margherita",
      "image": "assets/pizza.jpg",
      "description": "Pizza Margherita sans gluten\n\nIngrédients:\n- 200g farine sans gluten\n- 100ml eau tiède\n- 1 sachet levure sèche\n- 200g sauce tomate\n- 125g mozzarella\n- feuilles de basilic frais\n- 2 cuillères à soupe huile d'olive\n- sel\n\nÉtapes:\nMélanger la farine sans gluten, la levure, l'eau tiède, une pincée de sel et l'huile d'olive. Pétrir jusqu'à obtenir une pâte lisse et élastique. Laisser reposer 1 heure. Étaler la pâte sur une plaque de cuisson. Étaler la sauce tomate sur la pâte, ajouter la mozzarella tranchée et les feuilles de basilic. Arroser d'un filet d'huile d'olive. Cuire au four à 220°C pendant 15-20 minutes, jusqu'à ce que la pâte soit dorée et le fromage fondu."
    },
    {
      "title": "Soupe à l'oignon",
      "image": "assets/soupe.jpg",
      "description": "Soupe à l'oignon sans gluten\n\nIngrédients:\n- 4 gros oignons\n- 1L bouillon de bœuf\n- 50g beurre\n- 100ml vin blanc\n- 2 tranches pain sans gluten\n- 100g gruyère râpé\n- sel\n- poivre\n\nÉtapes:\nÉmincer les oignons et les faire revenir dans le beurre jusqu'à ce qu'ils soient bien dorés. Ajouter le vin blanc et laisser réduire. Verser le bouillon de bœuf, saler et poivrer, puis laisser mijoter 20 minutes. Pendant ce temps, faire griller les tranches de pain sans gluten. Servir la soupe dans des bols, ajouter les croûtons de pain et saupoudrer de gruyère râpé. Passer sous le gril quelques minutes pour gratiner le fromage."
    },
    {
      "title": "Bœuf Bourguignon",
      "image": "assets/boeuf.jpg",
      "description": "Bœuf Bourguignon sans gluten\n\nIngrédients:\n- 800g bœuf à braiser\n- 500ml vin rouge\n- 2 carottes\n- 2 oignons\n- 2 gousses d'ail\n- 200ml bouillon de bœuf\n- 2 cuillères à soupe fécule de maïs\n- bouquet garni\n- sel\n- poivre\n\nÉtapes:\nCouper le bœuf en gros morceaux et le faire revenir dans une cocotte avec un peu d'huile. Ajouter les carottes et les oignons émincés, l'ail écrasé, le bouquet garni, puis verser le vin rouge et le bouillon. Saler et poivrer. Laisser mijoter à couvert pendant 2 heures. Délayer la fécule de maïs dans un peu d'eau et l'ajouter à la préparation pour épaissir la sauce. Cuire encore quelques minutes et servir chaud."
    },
    {
      "title": "Mousse au chocolat",
      "image": "assets/mousse.jpg",
      "description": "Mousse au chocolat sans gluten\n\nIngrédients:\n- 200g chocolat noir sans gluten\n- 4 œufs\n- 50g sucre\n- 1 pincée de sel\n\nÉtapes:\nFaire fondre le chocolat au bain-marie. Séparer les blancs des jaunes d'œufs. Fouetter les jaunes avec le sucre jusqu'à ce que le mélange blanchisse. Incorporer le chocolat fondu. Monter les blancs en neige ferme avec une pincée de sel, puis les incorporer délicatement au mélange chocolaté. Répartir dans des ramequins et réfrigérer au moins 2 heures avant de servir."
    },
    {
      "title": "Crêpes Sucrées",
      "image": "assets/crepes.jpg",
      "description": "Crêpes Sucrées sans gluten\n\nIngrédients:\n- 200g farine sans gluten\n- 3 œufs\n- 500ml lait\n- 2 cuillères à soupe de sucre\n- 1 pincée de sel\n- beurre pour la cuisson\n\nÉtapes:\nDans un grand bol, mélanger la farine sans gluten, les œufs, le lait, le sucre et une pincée de sel jusqu'à obtenir une pâte lisse et sans grumeaux. Laisser reposer la pâte 30 minutes. Faire chauffer une poêle légèrement huilée et y verser une louche de pâte. Cuire jusqu'à ce que les bords se décollent, puis retourner la crêpe et cuire encore une minute. Servir avec du sucre, de la confiture ou du chocolat fondu."
    }
  ];

  Set<String> likedRecipes = {};

  @override
  void initState() {
    super.initState();
    _loadLikedRecipes();
  }

  Future<void> _loadLikedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final likedRecipesJson = prefs.getString('likedRecipes') ?? '[]';
    setState(() {
      likedRecipes = Set<String>.from(json.decode(likedRecipesJson));
    });
  }

  Future<void> _toggleLike(String title) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (likedRecipes.contains(title)) {
        likedRecipes.remove(title);
      } else {
        likedRecipes.add(title);
      }
    });
    await prefs.setString('likedRecipes', json.encode(likedRecipes.toList()));
  }

  Future<void> _addRecipeToCalendar(BuildContext context, String title, String description) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final event = Event(title, pickedTime, description);
        final prefs = await SharedPreferences.getInstance();
        final dayKey = pickedDate.toIso8601String().split('T')[0]; // Utiliser uniquement la date
        final eventsData = prefs.getString('events') ?? '{}';
        final decodedEvents = json.decode(eventsData) as Map<String, dynamic>;

        if (decodedEvents[dayKey] == null) {
          decodedEvents[dayKey] = [];
        }
        decodedEvents[dayKey].add({
          'name': event.name,
          'hour': event.time.hour,
          'minute': event.time.minute,
          'description': event.description,
        });

        await prefs.setString('events', json.encode(decodedEvents));
        print('Recette ajoutée : $event');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recette ajoutée au calendrier !')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text('Recettes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedRecipesPage(likedRecipes: likedRecipes.toList(), recipes: recipes),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final isLiked = likedRecipes.contains(recipe['title']);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      title: recipe['title']!,
                      imagePath: recipe['image']!,
                      description: recipe['description']!,
                    ),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.orange),
                      onPressed: () {
                        _addRecipeToCalendar(context, recipe['title']!, recipe['description']!);
                      },
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image.asset(
                        recipe['image']!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipe['title']!,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                _toggleLike(recipe['title']!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LikedRecipesPage extends StatelessWidget {
  final List<String> likedRecipes;
  final List<Map<String, String>> recipes;

  LikedRecipesPage({required this.likedRecipes, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final likedRecipesList = recipes.where((recipe) => likedRecipes.contains(recipe['title'])).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Recettes Likées'),
        backgroundColor: Colors.grey[400],
      ),
      body: ListView.builder(
        itemCount: likedRecipesList.length,
        itemBuilder: (context, index) {
          final recipe = likedRecipesList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(
                    title: recipe['title']!,
                    imagePath: recipe['image']!,
                    description: recipe['description']!,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    child: Image.asset(
                      recipe['image']!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe['title']!,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  RecipeDetailPage({required this.title, required this.imagePath, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey[400],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(imagePath, width: double.infinity, height: 250, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}