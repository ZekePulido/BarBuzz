import 'package:barbuzz/pages/bar_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplyLocationPage extends StatefulWidget {
  const ApplyLocationPage({super.key});

  @override
  _ApplyLocationPageState createState() => _ApplyLocationPageState();
}

class _ApplyLocationPageState extends State<ApplyLocationPage> {
  final _formKey = GlobalKey<FormState>(); 

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueDescriptionController = TextEditingController();
  final TextEditingController _venueWebsiteController = TextEditingController();

  Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final email = _emailController.text;
    final venueAddress = _venueAddressController.text;
    final venueName = _venueNameController.text;
    final venueDescription = _venueDescriptionController.text;
    final venueWebsite = _venueWebsiteController.text;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/signup'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'confirmEmail': _confirmEmailController.text,
          'venueAddress': venueAddress,
          'venueName': venueName,
          'venueDescription': venueDescription,
          'venueWebsite': venueWebsite,
          'type': 1, // Setting type to 1
        }),
      );

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarProfilePage(),  // Replace with your target page
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply location. ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
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
                  // Centered "Apply Location" Text
                  Text(
                    "APPLY LOCATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06, // Font size as 6% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Spacing as 2% of screen height
                  
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04), // Padding as 4% of screen width
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(220, 255, 179, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            hintStyle: const TextStyle(color: Colors.grey),
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
                          obscureText: true, // Obscure text for password field
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter password...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter email...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Text(
                          'Confirm Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _confirmEmailController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Confirm Email...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Text(
                          'Venue Address',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _venueAddressController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter venue address...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Text(
                          'Venue Name *This will be displayed*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _venueNameController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter venue name...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Text(
                          'Description *This will be displayed*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _venueDescriptionController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter description...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Text(
                          'Venue Website',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _venueWebsiteController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter venue website...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidth * 0.5, // 50% of the screen width
                            child: ElevatedButton(
                              onPressed: _submitForm, // Call _submitForm on press
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Background color of the button
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white, // Text color of the button
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidth * 0.5, // 50% of the screen width
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Background color of the button
                              ),
                              child: const Text(
                                'BACK',
                                style: TextStyle(
                                  color: Colors.white, // Text color of the button
                                ),
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
