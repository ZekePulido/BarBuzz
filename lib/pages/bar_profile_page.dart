import 'package:barbuzz/pages/apply_location_page.dart';
import 'package:flutter/material.dart';

class BarProfilePage extends StatefulWidget {
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
        backgroundColor: Color.fromARGB(220, 255, 179, 0),
        title: Center(
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bar Name",
              style: TextStyle(
                color: _textColor,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Image.asset(
              'assets/logos/BarBuzz.png',
              height: 200,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Website.com',
              style: TextStyle(
                color: _textColor,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'This is a bar',
              style: TextStyle(
                color: _textColor,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Above is how your profile will look followed by a list of your upcoming events.',
              style: TextStyle(
                color: _textColor,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyLocationPage(),  // Replace with your target page
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(220, 255, 179, 0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    color: _textColor,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Edit',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                // Handle continue to payment action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(220, 255, 179, 0),
              ),
              child: Text(
                'CONTINUE TO PAYMENT',
                style: TextStyle(
                  color: _textColor,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
