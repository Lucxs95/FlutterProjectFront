import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'activity.dart';
import 'activity_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

Future<List<Activity>> fetchActivities() async {
  final response = await http.get(Uri.parse('http://localhost:5000/api/activities'));
  if (response.statusCode == 200) {
    List activitiesJson = json.decode(response.body);
    return activitiesJson.map((json) => Activity.fromJson(json)).toList();
  } else {
    throw Exception('Échec du chargement des activités');
  }
}

class ActivitiesScreen extends StatefulWidget {
  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  Future<List<Activity>>? activitiesFuture;
  final List<String> categories = ["Toutes", "Shopping", "Sport", "Voyage"];

  @override
  void initState() {
    super.initState();
    activitiesFuture = fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activités'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  activitiesFuture = fetchActivities();
                });
              },
            ),
          ],
        ),
        body: TabBarView(
          children: categories.map((category) {
            return FutureBuilder<List<Activity>>(
              future: activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    List<Activity> activities = snapshot.data!;
                    if (category != "Toutes") {
                      activities = activities.where((activity) => activity.category == category).toList();
                    }
                    return ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) => buildActivityCard(context, activities[index]),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildActivityCard(BuildContext context, Activity activity) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetailScreen(activity: activity))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: activity.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      SizedBox(height: 5),
                      Text(activity.location, style: TextStyle(fontSize: 14)),
                      SizedBox(height: 5),
                      Text('${activity.price}€', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}