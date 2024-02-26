import 'package:flutter/material.dart';
import 'activity.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); 
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); 
}

class _CartScreenState extends State<CartScreen> {
  List<Activity> cartActivities = []; 
  double total = 0.0; 

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
      throw Exception('Échec du chargement des activités du panier');
    }
  }

  Future<void> removeFromCart(String userId, Activity activity) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/cart/remove'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'activityId': activity.id,
      }),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Échec de la suppression de l\'activité du panier');
    }
  }

  Future<void> removeAllFromCart(String userId) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/cart/removeAll'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Échec de la suppression de toutes les activités du panier');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
        actions: [
          IconButton(
  icon: Icon(Icons.delete_sweep),
  onPressed: () async {
    String? userId = await getUserId();
    if (userId != null) {
      removeAllFromCart(userId).then((_) {
        setState(() {
          cartActivities.clear(); 
          total = 0.0; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Panier vidé avec succès')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du videment du panier')),
        );
      });
    }
  },
),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
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
                      String? userId = await getUserId();
                      if (userId != null) {
                        removeFromCart(userId, activity).then((_) {
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
              separatorBuilder: (context, index) => Divider(color: Colors.grey),
            ),
          ),
          Divider(color: Colors.black),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total général: $total€',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
