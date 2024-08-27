import 'package:flutter/material.dart';
import 'package:barbuzz/pages/log_in_page.dart'; // Ensure this import is correct

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top left section
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05), // Padding from the edges
              child: Text(
                'Welcome, User!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Centered section
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Makes the Column only as tall as its content
                children: [
                  Text(
                    'Your reward points:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Space between texts
                  Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.1, // Larger font size for emphasis
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Login button
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Padding around the button
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(), // Replace with your target page
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(175, 168, 0, 0), // Background color of the button
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Makes the Row only as wide as its content
                children: [
                  Icon(Icons.directions_run_outlined, color: Colors.white), // Add icon to the button
                  SizedBox(width: screenWidth * 0.02), // Space between the icon and text
                  Text(
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
