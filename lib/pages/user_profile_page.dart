import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:barbuzz/pages/log_in_page.dart'; // Ensure this import is correct

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _username = 'Loading...';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        setState(() {
          _username = 'Not logged in';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _username = data['username'];
        });
      } else {
        setState(() {
          _username = 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        _username = 'Error fetching profile';
      });
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), // Navigate back to login page
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top left section
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Padding from the edges
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Welcome, $_username!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(), // Spacer widget to push logout button to the bottom
          // Logout button
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Padding around the button
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(220, 255, 179, 0), // Background color of the button
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Makes the Row only as wide as its content
                children: [
                  const Icon(Icons.directions_run_outlined, color: Colors.white), // Add icon to the button
                  SizedBox(width: screenWidth * 0.02), // Space between the icon and text
                  const Text(
                    'LOG OUT',
                    style: TextStyle(
                      color: Colors.white, // Text color of the button
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
