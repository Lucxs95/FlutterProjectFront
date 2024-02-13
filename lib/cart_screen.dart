import 'package:flutter/material.dart';
import 'activity.dart'; // Importez votre modèle Activity
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour utiliser json.decode
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // Utilisez la clé 'token' pour récupérer le JWT
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); // Utilisez la clé 'userId' pour récupérer l'identifiant de l'utilisateur
}

class _CartScreenState extends State<CartScreen> {
  List<Activity> cartActivities = []; // Liste pour stocker les activités du panier
  double total = 0.0; // Total général

@override
void initState() {
  super.initState();
  getUserId().then((userId) {
    if (userId != null) {
      fetchCartActivities(userId).then((activities) {
        setState(() {
          cartActivities = activities;
          total = activities.fold(0, (prev, activity) => prev + activity.price);
        });
      }).catchError((error) {
        // Handle errors, for example, by showing a snackbar
      });
    }
  });
}

  Future<List<Activity>> fetchCartActivities(String userId) async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/cart/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> activitiesJson = json.decode(response.body);
      return activitiesJson.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cart activities');
    }
  }


Future<void> removeFromCart(String userId, Activity activityId) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/api/cart/remove'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'userId': userId,
      'activityId': activityId.id,
    }),
  );

  if (response.statusCode == 200) {
    // Mise à jour de l'interface utilisateur ou rafraîchissement de la liste des activités du panier ici
  } else {
    throw Exception('Failed to remove activity from cart');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartActivities.length,
              itemBuilder: (context, index) {
                Activity activity = cartActivities[index];
                return ListTile(
                  leading: Image.network(activity.imageUrl),
                  title: Text(activity.title),
                  subtitle: Text('${activity.location} - ${activity.price}€'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      String? userId = await getUserId(); // Assurez-vous d'avoir une méthode pour récupérer l'userId
                      if (userId != null) {
                        removeFromCart(userId, activity).then((_) {
                          // Après la suppression, vous pourriez vouloir rafraîchir la liste des activités dans le panier
                          // Peut-être en appelant à nouveau fetchCartActivities ou en mettant à jour l'état local
                          setState(() {
                            cartActivities.removeAt(index);
                            total -= activity.price;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Activité retirée du panier')),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la suppression de l\'activité')),
                          );
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Text('Total général: $total€'),
        ],
      ),
    );
  }
}
