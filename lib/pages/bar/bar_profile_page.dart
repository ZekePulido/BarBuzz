import 'package:barbuzz/pages/bar/create_events_page.dart';
import 'package:barbuzz/pages/bar/delete_event_page.dart';
import 'package:barbuzz/pages/bar/edit_event_page.dart';
import 'package:barbuzz/pages/bar/edit_location_page.dart';
import 'package:barbuzz/pages/user/log_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barbuzz/models/event.dart';
import 'package:barbuzz/pages/user/event_details_page.dart';

class BarProfilePage extends StatefulWidget {
  const BarProfilePage({super.key});

  @override
  _BarProfilePageState createState() => _BarProfilePageState();
}

class _BarProfilePageState extends State<BarProfilePage> {
  static const Color _textColor = Colors.white;
  String venueName = "Loading...";
  String venueAddress = "Loading...";
  String venueDescription = "Loading...";
  String locationId = "";
  Future<List<Event>>? _events;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchBarProfile();
  }

  Future<void> _fetchBarProfile() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        // Fetch the user document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          setState(() {
            venueName = data?['venueName'] ?? 'Unknown Venue';
            venueAddress = data?['venueAddress'] ?? 'Unknown Address';
            venueDescription = data?['venueDescription'] ?? 'No Description';
          });

          // Fetch the location subcollection and get the first location document's ID
          QuerySnapshot locationSnapshot = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('location')
              .limit(1) // Assuming there's only one location document for the user
              .get();

          if (locationSnapshot.docs.isNotEmpty) {
            DocumentSnapshot locationDoc = locationSnapshot.docs.first;
            setState(() {
              locationId = locationDoc.id; // Get the location document ID
            });

            // Only fetch events if locationId is not empty
            if (locationId.isNotEmpty) {
              _events = fetchEventsForLocation(currentUser.uid, locationId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location ID is missing. Cannot load events.')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No location found for this user.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile not found.')),
          );
        }
      } catch (e, stackTrace) {
        print("Error loading profile: $e");
        print(stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } else {
      _logout();
    }
  }

  bool isDateInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  Future<List<Event>> fetchEventsForLocation(String userId, String locationId) async {
    if (locationId.isEmpty) {
      throw Exception('Location ID is empty. Cannot fetch events.');
    }

    try {
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('location')
          .doc(locationId)
          .collection('events')
          .get();

      final events = eventsSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      // Filter events for the current week
      final currentWeekEvents = events.where((event) =>
          isDateInCurrentWeek(event.startTime) ||
          isDateInCurrentWeek(event.endTime)).toList();

      return currentWeekEvents;
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.085),
          child: Center(
            child: Image.asset(
              'assets/logos/BarBuzz.png',
              height: 80,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (String result) {
              switch (result) {
                case 'Edit Profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditLocationPage(),
                    ),
                  );
                  break;
                case 'Log Out':
                  _logout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Edit Profile',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'Log Out',
                child: Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/logos/BarBee.png',
                    width: screenWidth * 0.45,
                    height: screenWidth * 0.45,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        venueAddress,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        venueDescription,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateEventsPage(locationId: locationId, userId: _auth.currentUser!.uid),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: _textColor,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'NEW EVENT',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your push notification logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(220, 255, 179, 0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: _textColor,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'SEND PUSH',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _events,
                builder: (context, eventsSnapshot) {
                  if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (eventsSnapshot.hasError) {
                    return Center(child: Text('Error: ${eventsSnapshot.error}'));
                  } else if (!eventsSnapshot.hasData || eventsSnapshot.data!.isEmpty) {
                    return const Center(child: Text('No upcoming events.'));
                  } else {
                    return ListView.builder(
                      itemCount: eventsSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final event = eventsSnapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditEventPage(
                                  eventId: event.eventId,
                                  locationId: locationId,
                                  userId: _auth.currentUser!.uid,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white24,
                            child: ListTile(
                              title: Text(
                                event.title,
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                              subtitle: Text(
                                '${event.getFormattedStartTime()} - ${event.getFormattedEndTime()}',
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: _textColor),
                                    onPressed: () {
                                      if (event.eventId.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditEventPage(
                                              eventId: event.eventId,
                                              locationId: locationId,
                                              userId: _auth.currentUser!.uid,
                                            ),
                                          ),
                                        );
                                      } 
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: _textColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DeleteEventPage(
                                            eventId: event.eventId,
                                            locationId: locationId,
                                            userId: _auth.currentUser!.uid,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
