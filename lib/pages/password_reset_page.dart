import 'package:barbuzz/pages/log_in_page.dart';
import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>(); 

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

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
                  // Centered "Password Reset" Text
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
                      color: const Color.fromARGB(220, 255, 179, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Password Reset',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06, // Font size as 6% of screen width
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04, // Font size as 4% of screen width
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01), // Space between label and text field as 1% of screen height
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter your email...',
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
                        
                        // New Password Label and TextFormField
                        Text(
                          'New Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true, // Obscure text for password field
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter new password...',
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
                        
                        // Confirm New Password Label and TextFormField
                        Text(
                          'Confirm New Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _confirmNewPasswordController,
                          obscureText: true, // Obscure text for password field
                          decoration: InputDecoration(
                            filled: true, // Fill the background with color
                            fillColor: Colors.white, // Set background color to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Confirm new password...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required.';
                            } else if (value != _newPasswordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Centered "Submit" Button
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
                                    builder: (context) => LoginPage(),  // Replace with your target page
                                  ),
                                  );
                                }
                              },
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
