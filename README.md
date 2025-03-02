import 'package:flutter/material.dart';

void main() {
runApp(GlutenFreeApp());
}

class GlutenFreeApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Gluten-Free App',
theme: ThemeData(
primarySwatch: Colors.green,
),
home: GlutenFreeHomePage(),
);
}
}

class GlutenFreeHomePage extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Gluten-Free Guide'),
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: <Widget>[
Text(
'Welcome to the Gluten-Free World!',
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
textAlign: TextAlign.center,
),
SizedBox(height: 20),
Padding(
padding: const EdgeInsets.all(16.0),
child: Text(
'Discover delicious gluten-free recipes, restaurants, and tips for living a gluten-free lifestyle.',
style: TextStyle(fontSize: 16),
textAlign: TextAlign.center,
),
),
SizedBox(height: 30),
ElevatedButton(
onPressed: () {
// Navigate to the recipes page or another section
// For now, let's just print a message
print('Navigating to Recipes...');
},
child: Text('Explore Recipes'),
),
],
),
),
);
}
}