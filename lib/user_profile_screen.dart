import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';


Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
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
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _profileImageUrl = 'https://tr.rbxcdn.com/70108dc7da4e002c8e5d2c1dcf0825fb/420/420/Hat/Png';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final jwtToken = await getJwtToken();
    final userId = await getUserId();
    final response = await http.get(
      Uri.parse('https://flutterprojectback.onrender.com/api/user/profile/$userId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final birthday = data['birthday'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data['birthday'])) : '';

      setState(() {
        _loginController.text = data['email'] ?? '';
        _birthdayController.text = birthday;
        _addressController.text = data['address'] ?? '';
        _postalCodeController.text = data['postalCode'] ?? '';
        _cityController.text = data['city'] ?? '';
        _passwordController.text = data['password'] ?? '';

      });
    }
  }

Future<void> saveUserProfile() async {
  final jwtToken = await getJwtToken();
  final userId = await getUserId();

  DateTime? birthday;
  try {
    final parts = _birthdayController.text.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      birthday = DateTime(year, month, day);
    }
  } catch (e) {
    print("Erreur lors de l'analyse de l'anniversaire: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Format d'anniversaire invalide")));
    return;
  }

  final response = await http.patch(
    Uri.parse('https://flutterprojectback.onrender.com/api/user/updateProfile/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode({
      'email': _loginController.text,
      'password': _passwordController.text,
      'birthday': birthday != null ? DateFormat('yyyy-MM-dd').format(birthday) : null,
      'address': _addressController.text,
      'postalCode': _postalCodeController.text,
      'city': _cityController.text,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mise à jour du profil réussie")));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Échec de la mise à jour du profil")));
  }
}

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImageUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil de l\'utilisateur')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_profileImageUrl),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
                enabled: false, 

            ),            
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),

              ),
                obscureText: true, 
            ),
            SizedBox(height: 20),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(
                labelText: 'Anniversaire',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            SizedBox(height: 20), 

            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Addresse',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            SizedBox(height: 20),
TextField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Code Postal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_post_office),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // This line enforces numeric input


            ),
            SizedBox(height: 20),
TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveUserProfile, child: Text('Sauvegarder')),
                        SizedBox(height: 20),

            ElevatedButton(onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              window.location.reload();
            }, child: Text('Se déconnecter'), style: ElevatedButton.styleFrom(primary: Colors.red)),
          ],
        ),
      ),
    );
  }
}
