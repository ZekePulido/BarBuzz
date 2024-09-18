import 'package:flutter/material.dart';
import 'package:barbuzz/pages/apply_location_page.dart';

class BarProfilePage extends StatefulWidget {
  const BarProfilePage({super.key});

  @override
  _BarProfilePageState createState() => _BarProfilePageState();
}

class _BarProfilePageState extends State<BarProfilePage> {
  static const Color _textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Center(
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for the image and venue details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with circular border
                ClipOval(
                  child: Image.asset(
                    'assets/logos/BarBee.png',
                    width: screenWidth * 0.45,
                    height: screenWidth * 0.45,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: screenWidth * 0.05), // Space between image and text
                // Venue details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Name
                      Text(
                        "Bar Name", // Replace with actual bar name
                        style: TextStyle(
                          color: _textColor,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // Venue Address
                      Text(
                        "123 Main St, City, Country", // Replace with actual address
                        style: TextStyle(
                          color: _textColor,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Description
                      Text(
                        'This is a bar', // Replace with actual description
                        style: TextStyle(
                          color: _textColor,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            // Row for the buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplyLocationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: _textColor,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'NEW EVENT',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01), // Adjust spacing between buttons
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplyLocationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: _textColor,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'SEND PUSH',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
