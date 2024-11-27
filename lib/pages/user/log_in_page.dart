import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import this for Firestore
import 'main_page.dart';
import 'sign_up_page.dart';
import '../bar/bar_profile_page.dart';
import 'forgot_password_page.dart';
import '../auth/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _login() async {
  final email = _usernameController.text;
  final password = _passwordController.text;

  try {
    // Sign in with Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // Fetch the user's ID token to check custom claims
    User? user = userCredential.user;
    if (user != null) {
      IdTokenResult idTokenResult = await user.getIdTokenResult();

      // Check if the user has the 'isAdmin' claim
      if (idTokenResult.claims != null && idTokenResult.claims!['isAdmin'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminMainPage(selectedIndex: 1),
          ),
        );
      } else {
        // Navigate based on non-admin roles (e.g., regular user, bar profile)
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        int userType = userData['userType'];

        if (userType == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BarProfilePage(),
            ),
          );
        } else if (userType == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(selectedIndex: 1),
            ),
          );
        }
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to log in: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "BARBUZZ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
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
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
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
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
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
                          obscureText: true,
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
                            width: screenWidth * 0.5,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  _login();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              'FORGOT PASSWORD?',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: screenWidth * 0.4,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'BACK',
                                    style: TextStyle(color: Colors.white),
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
