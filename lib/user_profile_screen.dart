import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

Future<void> fetchUserProfile() async {
  final jwtToken = await getJwtToken();
  final userId = await getUserId(); // Assurez-vous d'obtenir l'userId
  final response = await http.get(
    Uri.parse('http://localhost:5000/api/user/profile/$userId'), // Utilisez l'userId dans l'URL
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
  );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _loginController.text = data['email'] ?? '';
        _birthdayController.text = data['birthday'] ?? '';
        _addressController.text = data['address'] ?? '';
        _postalCodeController.text = data['postalCode'] ?? '';
        _cityController.text = data['city'] ?? '';
        _passwordController.text = data['password'] ?? '';

      });
    } else {
      // Handle the error
      print('Failed to fetch user profile');
    }
  }

  Future<void> saveUserProfile() async {
    final jwtToken = await getJwtToken();
    final userId = await getUserId();
    final response = await http.patch(
      Uri.parse('http://localhost:5000/api/user/updateProfile/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'login': _loginController.text,
        'password': _passwordController.text,
        'birthday': _birthdayController.text,
        'address': _addressController.text,
        'postalCode': _postalCodeController.text,
        'city': _cityController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(controller: _loginController, decoration: InputDecoration(labelText: 'Login'), readOnly: true),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true, readOnly: true),
            TextField(controller: _birthdayController, decoration: InputDecoration(labelText: 'Birthday')),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Address')),
            TextField(controller: _postalCodeController, decoration: InputDecoration(labelText: 'Postal Code'), keyboardType: TextInputType.number),
            TextField(controller: _cityController, decoration: InputDecoration(labelText: 'City')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveUserProfile, child: Text('Validate')),
            ElevatedButton(onPressed: logout, child: Text('Logout'), style: ElevatedButton.styleFrom(primary: Colors.red)),
          ],
        ),
      ),
    );
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
   window.location.reload();


  }
}
