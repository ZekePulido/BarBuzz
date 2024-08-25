import 'package:barbuzz/pages/main_page.dart';
import 'package:flutter/material.dart';
import '../pages/log_in_page.dart';
import '../pages/sign_up_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtain screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/BarBee.png',
              width: screenWidth * 0.6,
              height: screenHeight * 0.4,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: screenWidth * 0.5,  // 50% of the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page when SIGN UP button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),  // Replace with your target page
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(175, 168, 0, 0),  // Background color of the button
                ),
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(
                    color: Colors.white,  // Text color of the button
                  ),
                ),
              ),
            ),

            // Label
            Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: () {
                  // Navigate to login page or any other action
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),  // Replace with your target page
                    ),
                  );
                },
                child: Text(
                  'ALREADY HAVE AN ACCOUNT?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,  // Text color of the label
                    decoration: TextDecoration.underline,  // Optional: underline the text to indicate it's clickable
                  ),
                ),
              ),
            ),

            // Bottom Button with more width
            SizedBox(
              width: screenWidth * 0.4,  // 40% of the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page when SKIP button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(),  // Replace with your target page
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(175, 168, 0, 0),  // Background color of the button
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white, // Color of the icon
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.white,  // Text color of the button
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}