import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotUsernamePage extends StatefulWidget {
  const ForgotUsernamePage({super.key});

  @override
  _ForgotUsernamePageState createState() => _ForgotUsernamePageState();
}

class _ForgotUsernamePageState extends State<ForgotUsernamePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  String? _username; // Store the retrieved username
  String? _error; // Store any error messages

  Future<void> _retrieveUsername() async {
    final email = _emailController.text;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/forgot-username/$email'),
      );

      if (response.statusCode == 200) {
        // Parse the response and retrieve the username
        final data = jsonDecode(response.body);
        setState(() {
          _username = data['username']; // Update the username state
          _error = null; // Clear any previous error
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'User not found'; // Handle user not found case
          _username = null;
        });
      } else {
        setState(() {
          _error = 'An error occurred'; // Generic error handling
          _username = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to the server'; // Handle connection errors
        _username = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding:
            EdgeInsets.all(screenWidth * 0.05), // Padding as 5% of screen width
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: screenWidth *
                    0.8), // Constrain max width to 80% of screen width
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
                      fontSize: screenWidth *
                          0.10, // Font size as 10% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: screenHeight *
                          0.02), // Spacing as 2% of screen height

                  Container(
                    padding: EdgeInsets.all(
                        screenWidth * 0.04), // Padding as 4% of screen width
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(220, 255, 179, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Forgot Username',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth *
                                  0.06, // Font size as 6% of screen width
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth *
                                0.04, // Font size as 4% of screen width
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.01), // Space between label and text field as 1% of screen height
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor:
                                Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter your email...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth *
                                  0.04, // Horizontal padding as 4% of screen width
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.02), // Spacing as 2% of screen height

                        // Buttons in a row
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Retrieve Username Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _retrieveUsername();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  child: const Text(
                                    'Retrieve Username',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02), // Spacing
                              // Back Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  child: const Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        
                        // Display the retrieved username or error message centered
                        if (_username != null)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Your username is: $_username',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (_error != null)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: screenWidth * 0.05,
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
