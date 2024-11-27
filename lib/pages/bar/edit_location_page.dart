import 'package:barbuzz/pages/bar/bar_profile_page.dart';
import 'package:barbuzz/pages/user/log_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLocationPage extends StatefulWidget {
  const EditLocationPage({super.key});

  @override
  _EditLocationPageState createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueDescriptionController = TextEditingController();
  final TextEditingController _venueWebsiteController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String locationId = ""; // Location document ID

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
    _fetchBarProfile();
  }

  Future<void> _submitForm() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please log in again.')),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final profileData = {
        'venueAddress': _venueAddressController.text,
        'venueName': _venueNameController.text,
        'venueDescription': _venueDescriptionController.text,
        'venueWebsite': _venueWebsiteController.text,
      };

      try {
        // Update user profile in Firestore
        await _firestore.collection('users').doc(currentUser.uid).update(profileData);

        await _updateLocationDetails(); // Update the location details
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BarProfilePage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _updateLocationDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || locationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location ID is missing. Cannot update.')),
      );
      return;
    }

    final locationData = {
      'locationName': _venueNameController.text,
      'description': _venueDescriptionController.text,
      'address': _venueAddressController.text,
      'website': _venueWebsiteController.text,
    };

    try {
      // Update user-specific location document
      await _firestore.collection('users').doc(currentUser.uid).collection('location').doc(locationId).update(locationData);

      // Update or create corresponding document in the top-level "locations" collection
      await _firestore.collection('locations').doc(locationId).set({
        ...locationData,
        'userId': currentUser.uid, // Reference back to the user
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update location: $e')),
      );
    }
  }

  Future<void> _fetchProfileDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please log in again.')),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _venueAddressController.text = userDoc['venueAddress'] ?? '';
          _venueNameController.text = userDoc['venueName'] ?? '';
          _venueDescriptionController.text = userDoc['venueDescription'] ?? '';
          _venueWebsiteController.text = userDoc['venueWebsite'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile details.')),
      );
    }
  }

  Future<void> _fetchBarProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      QuerySnapshot locationSnapshot = await _firestore.collection('users').doc(currentUser.uid).collection('location').limit(1).get();
      if (locationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot locationDoc = locationSnapshot.docs.first;
        setState(() {
          locationId = locationDoc.id;
          _venueNameController.text = locationDoc['locationName'] ?? '';
          _venueAddressController.text = locationDoc['address'] ?? '';
          _venueDescriptionController.text = locationDoc['description'] ?? '';
          _venueWebsiteController.text = locationDoc['website'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location found for this user.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load bar profile.')),
      );
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
                        _buildTextField('Venue Address', _venueAddressController, 'Enter venue address...', false),
                        _buildTextField('Venue Name *This will be displayed*', _venueNameController, 'Enter venue name...', false),
                        _buildTextField('Description *This will be displayed*', _venueDescriptionController, 'Enter description...', false),
                        _buildTextField('Venue Website', _venueWebsiteController, 'Enter venue website...', false),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.08,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white, width: 1.5),
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

  Widget _buildTextField(String label, TextEditingController controller, String hint, bool isObscure) {
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
            contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
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
