import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/location_card.dart';
import '../bar/bar_page.dart';

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

  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      location: data['locationName'] ?? 'Unknown Location',
      image: data['image'] ?? '',
      address: data['address'] ?? 'No Address Provided',
    );
  }
}

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

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
    final querySnapshot = await FirebaseFirestore.instance.collection('locations').get();

    return querySnapshot.docs.map((doc) => Location.fromFirestore(doc)).toList();
  }

  void _navigateToBarPage(Location location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarPage(
          imagePath: location.image,
          locationId: location.id,
          locationName: location.location,
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: searchBarHeight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.black,
                  child: TextField(
                    onChanged: _onSearchQueryChanged,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              FutureBuilder<List<Location>>(
                future: _locations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No locations available.'));
                  } else {
                    final locations = snapshot.data!
                        .where((location) => location.location
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                    return Column(
                      children: locations.map((location) {
                        return LocationCard(
                          imagePath: location.image.isNotEmpty
                              ? location.image // Use the image URL if available
                              : 'assets/logos/BarBee.png', // Fallback image
                          location: location.location.isNotEmpty ? location.location : 'Unknown Location',
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
