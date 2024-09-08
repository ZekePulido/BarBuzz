import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/location_card.dart';
import '../pages/bar_page.dart';

// Location model
class Location {
  final String id;
  final String location;
  final String image;
  final String address;

  Location({
    required this.id,
    required this.location,
    required this.image,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'],
      location: json['location'],
      image: json['image'],
      address: json['address'],
    );
  }
}

class LocationsPage extends StatefulWidget {
  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  late Future<List<Location>> _locations;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _locations = fetchLocations();
  }

  Future<List<Location>> fetchLocations() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/locations'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Location.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  void _navigateToBarPage(Location location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarPage(
          imagePath: location.image,
          locationId: location.id,
          locationName: location.location, // Pass the location name
        ),
      ),
    );
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final double searchBarHeight = screenSize.height * 0.07;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: searchBarHeight,
              child: Container(
                padding: EdgeInsets.all(4),
                color: Colors.black,
                child: TextField(
                  onChanged: _onSearchQueryChanged,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            FutureBuilder<List<Location>>(
              future: _locations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No locations available.'));
                } else {
                  final locations = snapshot.data!
                      .where((location) => location.location
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  return Column(
                    children: locations.map((location) {
                      return LocationCard(
                        imagePath: location.image.isNotEmpty ? location.image : 'https://via.placeholder.com/150', // Default image
                        location: location.location.isNotEmpty ? location.location : 'Unknown Location', // Default name
                        locationId: location.id,
                        onTap: () => _navigateToBarPage(location),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

}
