import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_page.dart'; // Import MainPage widget

class BarPage extends StatefulWidget {
  final String imagePath;
  final String locationId;
  final String locationName; // Add locationName

  BarPage({
    required this.imagePath,
    required this.locationId,
    required this.locationName, // Add locationName
  });

  @override
  _BarPageState createState() => _BarPageState();
}

class _BarPageState extends State<BarPage> {
  late Future<Map<String, dynamic>> _locationDetails;

  @override
  void initState() {
    super.initState();
    _locationDetails = fetchLocationDetails(widget.locationId);
  }

  Future<Map<String, dynamic>> fetchLocationDetails(String locationId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/locations/$locationId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load location details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(175, 168, 0, 0),
        title: Center(
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _locationDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No details available.'));
            } else {
              final location = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title centered
                  Center(
                    child: Text(
                      widget.locationName, // Use locationName passed from LocationsPage
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16), // Spacing between title and image

                  // Circular Image centered
                  Center(
                    child: ClipOval(
                      child: Image.network(
                        widget.imagePath, // Use imagePath passed from LocationsPage
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // Spacing between image and address

                  // Address (aligned to the start)
                  Text(
                    "Address: ${location['address']}",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(100, 105, 105, 105),
        currentIndex: 0, // You can set this based on navigation history if needed
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(selectedIndex: index),
            ),
          );
        },
        selectedItemColor: Color.fromARGB(175, 168, 0, 0),
        unselectedItemColor: Color.fromARGB(150, 192, 192, 192),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
