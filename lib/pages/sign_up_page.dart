import 'package:flutter/material.dart';
import '../pages/log_in_page.dart';
import '../pages/home_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Controllers for each field
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Obtain screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05), // Padding as 5% of screen width
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.8), // Constrain max width to 80% of screen width
            child: Form(
              key: _formKey, // Assign the form key here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Centered "BARBUZZ" Text
                  Text(
                    "BARBUZZ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.10, // Font size as 10% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Spacing as 2% of screen height
                  
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04), // Padding as 4% of screen width
                    decoration: BoxDecoration(
                      color: Color.fromARGB(175, 114, 0, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Centered "Sign Up" Text
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06, // Font size as 6% of screen width
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02), // Spacing as 2% of screen height
                        // Username Label and TextFormField
                        Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04, // Font size as 4% of screen width
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01), // Space between label and text field as 1% of screen height
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter username...',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04, // Horizontal padding as 4% of screen width
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02), // Spacing as 2% of screen height
                        // Password Label and TextFormField
                        Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter password',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Nickname Label and TextFormField
                        Text(
                          'Nickname',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter nickname...',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Centered "SIGN UP" Button
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidth * 0.5, // 50% of the screen width
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  // Process data if form is valid
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),  // Replace with your target page
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(175, 168, 0, 0), // Background color of the button
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  color: Colors.white, // Text color of the button
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Align(
                          alignment: Alignment.center,
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
                                fontSize: screenWidth * 0.03, // Font size as 3% of screen width
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidth * 0.4, // 40% of the screen width
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to another page when BACK button is pressed
                               Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(175, 168, 0, 0), // Background color of the button
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.white, // Color of the icon
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'BACK',
                                    style: TextStyle(
                                      color: Colors.white, // Text color of the button
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
