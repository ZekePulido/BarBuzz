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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding around the content
        child: SingleChildScrollView( // Wrap Column in SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left)
            children: [
              // Search bar
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16.0), // Spacing below the search bar

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
