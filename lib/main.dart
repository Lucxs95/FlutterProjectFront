import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homescreen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interface de Connexion Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: token == null ? LoginScreen() : HomeScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

Future<void> seConnecterAvecEmailEtMotDePasse(BuildContext context) async {
  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    afficherDialogErreur(context, "L'email et le mot de passe ne doivent pas être vides.");
    return;
  }

  final String backendUrl = 'https://flutterprojectback.onrender.com/api/auth/login';
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        var token = jsonDecode(response.body)['token'];
        await prefs.setString('token', token); 

        var userId = jsonDecode(response.body)['userId'];
        await prefs.setString('userId', userId);
        
        print('Connexion réussie. Token: $token, UserId: $userId');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        String messageErreur = 'Une erreur est survenue';
        try {
          final responseBody = jsonDecode(response.body);
          messageErreur = responseBody['message'] ?? messageErreur;
        } catch (e) {
          messageErreur = response.body.isNotEmpty ? response.body : messageErreur;
        }
        afficherDialogErreur(context, messageErreur);
      }
    } catch (e) {
      afficherDialogErreur(context, "Une erreur inattendue est survenue.");
    }
  }

  void afficherDialogErreur(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Fermer"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MIAGED'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Login',
              ),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => seConnecterAvecEmailEtMotDePasse(context),
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
