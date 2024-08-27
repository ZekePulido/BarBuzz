import 'package:barbuzz/pages/bar_profile_page.dart';
import 'package:flutter/material.dart';

class ApplyLocationPage extends StatefulWidget {
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
                      color: Color.fromARGB(175, 114, 0, 0),
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
                          obscureText: true, // Obscure text for password field
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter password...',
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
                        // Venue Image Label
                        Text(
                          'Venue Image *This will be displayed*',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidth * 0.5, // 50% of the screen width
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BarProfilePage(),  // Replace with your target page
                                  ),
                                );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(175, 168, 0, 0), // Background color of the button
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
                                backgroundColor: Color.fromARGB(175, 168, 0, 0), // Background color of the button
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
