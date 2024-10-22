import 'package:barbuzz/pages/bar/bar_profile_page.dart';
import 'package:barbuzz/pages/user/log_in_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditLocationPage extends StatefulWidget {
  const EditLocationPage({super.key});

  @override
  _EditLocationPageState createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueDescriptionController =
      TextEditingController();
  final TextEditingController _venueWebsiteController = TextEditingController();

  String venueName = "";
  String venueAddress = "";
  String venueDescription = "";
  String locationId = ""; // This is used to update the location

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails(); // Fetch the current profile details
    _fetchBarProfile(); // Fetch the bar profile including locationId
  }

  Future<void> _submitForm() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not authenticated. Please log in again.')),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_emailController.text != _confirmEmailController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and Confirm Email must match.')),
        );
        return;
      }

      final data = {
        'email': _emailController.text,
        'venueAddress': _venueAddressController.text,
        'venueName': _venueNameController.text,
        'venueDescription': _venueDescriptionController.text,
        'venueWebsite': _venueWebsiteController.text,
      };

      try {
        final profileResponse = await http.put(
          Uri.parse('http://10.0.2.2:3000/profile'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );

        if (profileResponse.statusCode == 200) {
          await _updateLocationDetails(); // Update the location details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BarProfilePage()),
          );
        } else {
          final responseBody = jsonDecode(profileResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update profile: ${responseBody['error'] ?? profileResponse.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    }
  }

  Future<void> _updateLocationDetails() async {
    final token = await _storage.read(key: 'auth_token');
    if (locationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location ID is missing. Cannot update.')),
      );
      return;
    }

    final data = {
      'location': _venueNameController.text,
      'description': _venueDescriptionController.text,
      'address': _venueAddressController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/location/$locationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      print(response.statusCode);

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update location: ${responseBody['error'] ?? response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while updating location: $error')),
      );
    }
  }

  Future<void> _fetchProfileDetails() async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not authenticated. Please log in again.')),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _emailController.text = data['email'] ?? '';
          _confirmEmailController.text = data['email'] ??
              ''; // Set confirm email to match the fetched email
          _venueAddressController.text = data['venueAddress'] ?? '';
          _venueNameController.text = data['venueName'] ?? '';
          _venueDescriptionController.text = data['venueDescription'] ?? '';
          _venueWebsiteController.text = data['venueWebsite'] ?? '';
        });
      } else {
        throw Exception('Failed to load profile details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile details.')),
      );
    }
  }

  Future<void> _fetchBarProfile() async {
    final token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/bar-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          venueName = data['venueName'];
          venueAddress = data['venueAddress'];
          venueDescription = data['venueDescription'];
          locationId = data['locationId'];
        });
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load bar profile.')),
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
                    "EDIT LOCATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
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
                        // Email field
                        _buildTextField(
                            'Email', _emailController, 'Enter email...', false),
                        // Confirm Email field
                        _buildTextField('Confirm Email',
                            _confirmEmailController, 'Confirm Email...', false),
                        // Venue Address field
                        _buildTextField(
                            'Venue Address',
                            _venueAddressController,
                            'Enter venue address...',
                            false),
                        // Venue Name field
                        _buildTextField('Venue Name *This will be displayed*',
                            _venueNameController, 'Enter venue name...', false),
                        // Description field
                        _buildTextField(
                            'Description *This will be displayed*',
                            _venueDescriptionController,
                            'Enter description...',
                            false),
                        // Venue Website field
                        _buildTextField(
                            'Venue Website',
                            _venueWebsiteController,
                            'Enter venue website...',
                            false),
                        SizedBox(height: screenHeight * 0.02),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.08,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: _submitForm,
                            child: Text(
                              'SUBMIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
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

  Widget _buildTextField(String label, TextEditingController controller,
      String hint, bool isObscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }
}
