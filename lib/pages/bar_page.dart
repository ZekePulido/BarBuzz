import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  bool _isFavorited = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _locationDetails = fetchLocationDetails(widget.locationId);
    _checkFavoriteStatus();
  }

  Future<Map<String, dynamic>> fetchLocationDetails(String locationId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/locations/$locationId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load location details');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isFavorited = data['favorites'].any((fav) => fav['_id'] == widget.locationId);
        });
      }
    } catch (e) {
      print('Error fetching favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'locationId': widget.locationId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      } else {
        print('Failed to update favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.005), // 10% padding on each side
          child: Center(
            child: Image.asset(
              'assets/logos/BarBuzz.png',
              height: 80,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
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
                  Center(
                    child: Text(
                      widget.locationName, // Use locationName passed from LocationsPage
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
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
                  SizedBox(height: 16),
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
        currentIndex: 0,
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(selectedIndex: index),
            ),
          );
        },
        selectedItemColor: Color.fromARGB(220, 255, 179, 0),
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
