import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.wifi),
                title: Text('Connexion backend'),
                subtitle: Text('WebSocket actif'),
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.memory),
                title: Text('Source prédiction'),
                subtitle: Text('LSTM via backend'),
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings_remote),
                title: Text('Mode système'),
                subtitle: Text('Automatique'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}