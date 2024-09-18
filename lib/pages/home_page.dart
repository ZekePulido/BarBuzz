import 'package:barbuzz/pages/apply_location_page.dart';
import 'package:barbuzz/pages/main_page.dart';
import 'package:flutter/material.dart';
import '../pages/log_in_page.dart';
import '../pages/sign_up_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              width: screenWidth * 0.8,
              height: screenHeight * 0.5,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),

            // Button Row with spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Center buttons horizontally
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),  // Space around buttons
                  child: SizedBox(
                    width: screenWidth * 0.4,  // 40% of the screen width
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to SignUpPage when SIGN UP button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                      ),
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),  // Space around buttons
                  child: SizedBox(
                    width: screenWidth * 0.4,  // 40% of the screen width
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to LoginPage when LOG IN button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                      ),
                      child: const Text(
                        'LOG IN',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // SKIP Button
            SizedBox(
              width: screenWidth * 0.4,  // 40% of the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page when SKIP button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(selectedIndex: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.08 ),

            // Apply My Business Button
            SizedBox(
              width: screenWidth * 0.6,  // 40% of the screen width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page or perform an action when APPLY MY BUSINESS button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyLocationPage(), // Adjust as necessary
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                ),
                child: const Text(
                  'APPLY MY BUSINESS',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  softWrap: true, // Allow text to wrap
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
