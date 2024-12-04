import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomingUserPage extends StatefulWidget {
  const IncomingUserPage({super.key});

  @override
  _IncomingUserPageState createState() => _IncomingUserPageState();
}

class _IncomingUserPageState extends State<IncomingUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _applicants = [];

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('enabled', isEqualTo: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _applicants = snapshot.docs;
        });
      } else {
        setState(() {
          _applicants = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No applicants found.')),
        );
      }
    } catch (e) {
      print('Failed to load applicants: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load applicants: $e')),
      );
    }
  }

Future<void> _acceptApplicant(String applicantId) async {
  try {
    // Fetch the user's data to get venue information
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(applicantId).get();
    final userData = userSnapshot.data() as Map<String, dynamic>;

    // Enable the user by updating 'enabled' to true
    await _firestore.collection('users').doc(applicantId).update({
      'enabled': true,
    });

    // Generate a unique ID for the location
    String locationId = _firestore.collection('locations').doc().id;

    // Create location data based on user document fields
    final locationData = {
      'locationName': userData['venueName'] ?? 'Unknown Location',
      'image': '',
      'address': userData['venueAddress'] ?? 'No address provided',
      'description': userData['venueDescription'] ?? 'No description provided',
      'website': userData['venueWebsite'] ?? 'No website provided',
      'userId': applicantId,  // Optionally include the userId to track ownership
    };

    // Add location as a sub-collection in the user document with a specific ID
    await _firestore
        .collection('users')
        .doc(applicantId)
        .collection('location')
        .doc(locationId)
        .set(locationData);

    // Mirror the location data to the top-level 'locations' collection with the same ID
    await _firestore.collection('locations').doc(locationId).set(locationData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Applicant accepted and location created.')),
    );

    _fetchApplicants(); // Refresh the list
  } catch (e) {
    print('Failed to accept applicant: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to accept applicant: $e')),
    );
  }
}




  Future<void> _denyApplicant(String applicantId) async {
    try {
      await _firestore.collection('users').doc(applicantId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applicant denied.')),
      );
      _fetchApplicants(); // Refresh the list
    } catch (e) {
      print('Failed to deny applicant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to deny applicant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Incoming Bar Applicants',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: _applicants.isEmpty
                ? Center(
                    child: Text(
                      'No applicants at the moment.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: _applicants.length,
                    itemBuilder: (context, index) {
                      final applicant = _applicants[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            applicant['username'] ?? 'No name provided',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            applicant['email'] ?? 'No email provided',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _acceptApplicant(applicant.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _denyApplicant(applicant.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
