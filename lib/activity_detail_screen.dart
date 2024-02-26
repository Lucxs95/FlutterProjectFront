import 'package:flutter/material.dart';
import 'activity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); 
}

Future<void> addToCart(Activity activity) async {
  final jwtToken = await getJwtToken(); 
  final userId = await getUserId(); 
  if (jwtToken == null || userId == null) {
    print(' JWT Token ou userId est null');
    return;
  }

  final url = Uri.parse('http://localhost:5000/api/cart/add');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken', 
    },
    body: jsonEncode(<String, dynamic>{
      'userId': userId, 
      'activityId': activity.id,
    }),
  );

  if (response.statusCode == 200) {
    print('Activité ajoutée au panier');
  } else {
    throw Exception('Échec de l\'ajout d\'une activité au panier');
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Activité ajoutée au panier')),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
                        );
                      });
                    },
                    child: Text('Ajouter au panier'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    child: Text('Retour'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey, 
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
