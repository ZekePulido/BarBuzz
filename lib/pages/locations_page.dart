import 'package:flutter/material.dart';
import '../utils/location_card.dart';
import '../pages/bar_page.dart';

class LocationsPage extends StatefulWidget {
  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  void _navigateToBarPage(String imagePath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarPage(
          imagePath: imagePath,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;

    // Calculate search bar height as a percentage of screen height
    final double searchBarHeight = screenSize.height * 0.07; 

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              SizedBox(
                height: searchBarHeight, // Set dynamic height based on screen size
                child: Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.black,
                  child: TextField(
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

              // Location cards
              LocationCard(
                imagePath: 'assets/logos/arepas.jpg',
                title: "Arepas Coffee & Bar",
                onTap: () => _navigateToBarPage('assets/logos/arepas.jpg', 'Arepas Coffee & Bar'),
              ),
              LocationCard(
                imagePath: 'assets/logos/boardtown.jpg',
                title: "BoardTown",
                onTap: () => _navigateToBarPage('assets/logos/boardtown.jpg', 'BoardTown'),
              ),
              // Add more LocationCard widgets here
            ],
          ),
        ),
      ),
    );
  }
}
