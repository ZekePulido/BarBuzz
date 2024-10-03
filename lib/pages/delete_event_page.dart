import 'package:barbuzz/pages/bar_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class DeleteEventPage extends StatelessWidget {
  final String eventId;

  const DeleteEventPage({super.key, required this.eventId});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _deleteEvent(BuildContext context) async {
    final token = await _storage.read(key: 'auth_token'); // Get the token

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/events/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BarProfilePage(),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete event.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.10),
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: Container(
        color: Colors.black, // Set background color here
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: screenWidth * 0.2,
            ),
            SizedBox(height: screenHeight * 0.02),

            // Warning Text
            Text(
              "Are you sure you want to delete the event?",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Use white for better contrast
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),
            // Delete Button
            ElevatedButton(
              onPressed: () => _deleteEvent(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.2,
                  vertical: screenHeight * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Delete",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back without deleting
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
