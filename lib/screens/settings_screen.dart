import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text('Paramètres', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsItem('Langues', Icons.language),
          _buildSettingsItem('Gestion des données', Icons.storage),
          _buildSettingsItem('Partager l’application', Icons.share),
          _buildSettingsItem('Mode daltonien', Icons.accessibility),
          _buildSettingsItem('Politique de confidentialité', Icons.privacy_tip),
          _buildSettingsItem('Conditions générales', Icons.description),
          _buildSettingsItem('About us (nous contacter)', Icons.contact_support),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: TextStyle(fontSize: 16)),
        onTap: () {
          // Ajoutez ici la logique pour chaque option
        },
      ),
    );
  }
}