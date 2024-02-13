import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour utiliser json.decode
import 'activity.dart'; // Votre modèle d'activité
import 'activity_detail_screen.dart'; // Importez ActivityDetailScreen


Future<List<Activity>> fetchActivities() async {
  final response = await http.get(Uri.parse('http://localhost:5000/api/activities'));

  if (response.statusCode == 200) {
    List activitiesJson = json.decode(response.body);
    return activitiesJson.map((json) => Activity.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load activities');
  }
}

class ActivitiesScreen extends StatefulWidget {
  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  Future<List<Activity>>? activitiesFuture;

  @override
  void initState() {
    super.initState();
    activitiesFuture = fetchActivities(); // Remplacez par votre fonction de récupération
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Activity activity = snapshot.data![index];
              return Card(
                elevation: 5, // Ajoute une petite ombre sous la carte pour un effet de profondeur
                margin: EdgeInsets.all(10), // Ajoute de l'espace autour de chaque carte
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(activity: activity),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        ClipRRect( // Utilisez ClipRRect pour arrondir les coins de l'image
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            activity.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded( // Utilisez Expanded pour que le texte prenne tout l'espace restant
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  activity.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Ajoute '...' si le texte est trop long
                                ),
                                SizedBox(height: 5), // Ajoute un petit espace
                                Text(
                                  activity.location,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 5), // Ajoute un petit espace
                                Text(
                                  '${activity.price}€',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }
        return Center(child: CircularProgressIndicator()); // Affiche un indicateur de chargement pendant la récupération des données
      },
    );
  }
}
