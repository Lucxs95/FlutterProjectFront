import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour utiliser json.decode

Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // Utilisez la clé 'token' pour récupérer le JWT
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); // Utilisez la clé 'userId' pour récupérer l'identifiant de l'utilisateur
}

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Supposons que vous ayez une classe User pour gérer les données de l'utilisateur
  // User currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Exemple de méthode pour récupérer le profil de l'utilisateur
Future<void> fetchUserProfile() async {
  final jwtToken = await getJwtToken(); // Utilisez la méthode pour obtenir le JWT
  final response = await http.get(
    Uri.parse('http://localhost:5000/api/user/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      _birthdayController.text = data['birthday'] ?? '';
      _addressController.text = data['address'] ?? '';
      _postalCodeController.text = data['postalCode'] ?? '';
      _cityController.text = data['city'] ?? '';
      // Mettez à jour d'autres contrôleurs de champ ici en fonction des données récupérées
    });
  } else {
    // Gérez l'erreur
    print('Failed to fetch user profile');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil utilisateur'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _birthdayController,
                decoration: InputDecoration(labelText: 'Anniversaire'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
              TextField(
                controller: _postalCodeController,
                decoration: InputDecoration(labelText: 'Code postal'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Ville'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Logique pour sauvegarder les modifications
                },
                child: Text('Valider'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Logique pour se déconnecter
                  logout();
                },
                child: Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprimez le token JWT
    await prefs.remove('userId'); // Supprimez l'userId
    Navigator.of(context).pushReplacementNamed('/login'); // Redirigez vers l'écran de login
  }
}
