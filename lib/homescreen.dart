import 'package:flutter/material.dart';
import 'activities_screen.dart'; // Importer ActivitiesScreen
import 'cart_screen.dart'; // Importer CartScreen


// Dans homescreen.dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index de l'onglet sélectionné
  
static List<Widget> _widgetOptions = <Widget>[
  ActivitiesScreen(), // Écran des activités
  CartScreen(), // Utilisez CartScreen au lieu du placeholder
  Text('Profil'), // Placeholder pour Profil (à remplacer par votre écran de profil le moment venu)
];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MIAGED'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
