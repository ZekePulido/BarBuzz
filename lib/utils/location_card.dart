import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap; // Add a callback for handling taps

  // Constructor
  LocationCard({
    required this.imagePath,
    required this.title,
    required this.onTap, // Initialize the callback
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap, // Handle tap events
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0), // Space below each card
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left)
          children: [
            Row(
              children: [
                Image.asset(
                  imagePath,
                  height: 50,
                ),
                SizedBox(width: screenWidth * 0.08),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0), // Space between text and line
            Container(
              color: Colors.white,
              height: 1.5, // Line thickness
              width: double.infinity, // Full width of the container
            ),
          ],
        ),
      ),
    );
  }
}
