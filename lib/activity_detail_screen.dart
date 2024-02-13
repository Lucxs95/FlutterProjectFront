import 'package:flutter/material.dart';
import 'activity.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour utiliser json.decode
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('flutter.token'); // Utilisez la clé que vous avez utilisée pour sauvegarder le token
}

Future<void> addToCart(Activity activity) async {
  final jwtToken = await getJwtToken(); // Récupération du token
  if (jwtToken == null) {
    print('JWT Token is null');
    return;
  }

  final url = Uri.parse('http://localhost:5000/api/cart/add');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken', // Utilisation du token
    },
    body: jsonEncode(<String, dynamic>{
      'activityId': activity.id,
    }),
  );

  if (response.statusCode == 200) {
    print('Activité ajoutée au panier');
  } else {
    throw Exception('Failed to add activity to cart');
  }
}

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;

  ActivityDetailScreen({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(activity.imageUrl),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(activity.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Catégorie: ${activity.category}', style: TextStyle(fontSize: 18)),
                  Text('Lieu: ${activity.location}', style: TextStyle(fontSize: 18)),
                  Text('Nombre de personnes minimum: ${activity.minPeople}', style: TextStyle(fontSize: 18)),
                  Text('Prix: ${activity.price}€', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      addToCart(activity).then((_) {
                        // Afficher un Snackbar, par exemple, pour confirmer l'ajout
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Activité ajoutée au panier')),
                        );
                      }).catchError((error) {
                        // Gérer l'erreur, par exemple, en affichant un message d'erreur
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
                        );
                      });
                    },
                    child: Text('Ajouter au panier'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Retour à la page précédente
                    },
                    child: Text('Retour'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, // Couleur du bouton
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
