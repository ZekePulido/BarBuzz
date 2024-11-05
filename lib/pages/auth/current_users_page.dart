import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CurrentUserPage extends StatefulWidget {
  const CurrentUserPage({super.key});

  @override
  _CurrentUserPageState createState() => _CurrentUserPageState();
}

class _CurrentUserPageState extends State<CurrentUserPage> {
  String _username = 'Loading...';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
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
                'Current Users',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
         ],
      ),
    );
  }
}
