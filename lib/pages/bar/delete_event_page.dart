import 'package:barbuzz/pages/bar/bar_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteEventPage extends StatelessWidget {
  final String eventId;
  final String locationId;
  final String userId;

  const DeleteEventPage({
    super.key,
    required this.eventId,
    required this.locationId,
    required this.userId,
  });

 Future<void> _deleteEvent(BuildContext context) async {
  try {
    print('Deleting event with ID: $eventId');
    print('Location ID: $locationId');
    print('User ID: $userId');

    // Delete from user's nested location-specific events collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('location')
        .doc(locationId)
        .collection('events')
        .doc(eventId)
        .delete();

    // Delete from the top-level events collection
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .delete();

    // Delete from the top-level locations collection under location-specific events
    await FirebaseFirestore.instance
        .collection('locations')
        .doc(locationId)
        .collection('events')
        .doc(eventId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BarProfilePage(),
      ),
    );
  } catch (e) {
    print('Delete failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete event.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.10),
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: screenWidth * 0.2,
            ),
            SizedBox(height: screenHeight * 0.02),

            // Warning Text
            Text(
              "Are you sure you want to delete the event?",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),

            // Delete Button
            ElevatedButton(
              onPressed: () => _deleteEvent(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.2,
                  vertical: screenHeight * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Delete",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back without deleting
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
