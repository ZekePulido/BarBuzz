import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user/event_details_page.dart';
import '../user/main_page.dart';
import 'package:barbuzz/utils/event_card.dart';
import 'package:barbuzz/models/event.dart';

class BarPage extends StatefulWidget {
  final String imagePath;
  final String locationId;
  final String locationName;

  const BarPage({
    super.key,
    required this.imagePath,
    required this.locationId,
    required this.locationName,
  });

  @override
  _BarPageState createState() => _BarPageState();
}

class _BarPageState extends State<BarPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _locationDetails;
  late Future<List<Event>> _events;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _locationDetails = fetchLocationDetails(widget.locationId);
    _events = fetchEventsForLocation(widget.locationId);

    final user = FirebaseAuth.instance.currentUser;
     if (user != null) {
      _loadFavoriteStatus();
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchLocationDetails(String locationId) async {
    return FirebaseFirestore.instance.collection('locations').doc(locationId).get();
  }

  Future<void> _loadFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final userId = user.uid;
    final favoriteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.locationId)
        .get();

    setState(() {
      _isFavorited = favoriteDoc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final userId = user.uid;
    final favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites');

    if (_isFavorited) {
      // Remove from favorites
      await favoritesCollection.doc(widget.locationId).delete();
    } else {
      // Add to favorites
      await favoritesCollection.doc(widget.locationId).set({
        'locationName': widget.locationName,
        'imagePath': widget.imagePath,
      });
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  bool isDateInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  Future<List<Event>> fetchEventsForLocation(String locationId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('locations')
        .doc(locationId)
        .collection('events')
        .get();

    return querySnapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) =>
            isDateInCurrentWeek(event.startTime) ||
            isDateInCurrentWeek(event.endTime))
        .toList();
  }

  @override
   @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.005),
          child: Center(
            child: Image.asset(
              'assets/logos/BarBuzz.png',
              height: 80,
            ),
          ),
        ),
        actions: user != null
            ? [
                IconButton(
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ]
            : null, // If the user is not logged in, no actions
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _locationDetails,
          builder: (context, locationSnapshot) {
            if (locationSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (locationSnapshot.hasError) {
              return Center(child: Text('Error: ${locationSnapshot.error}'));
            } else if (!locationSnapshot.hasData || !locationSnapshot.data!.exists) {
              return const Center(child: Text('No details available.'));
            } else {
              final location = locationSnapshot.data!.data()!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: FadeInImage(
                          placeholder: const AssetImage('assets/logos/BarBee.png'),
                          image: widget.imagePath.isNotEmpty
                              ? NetworkImage(widget.imagePath)
                              : const AssetImage('assets/logos/BarBee.png'),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/logos/BarBee.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.locationName.isNotEmpty ? widget.locationName : 'Unknown Location',
                              style: const TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Address: ${location['address'] ?? 'No address provided'}",
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Description: ${location['description'] ?? 'No description provided'}",
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Event>>(
                      future: _events,
                      builder: (context, eventsSnapshot) {
                        if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (eventsSnapshot.hasError) {
                          return Center(child: Text('Error: ${eventsSnapshot.error}'));
                        } else if (!eventsSnapshot.hasData || eventsSnapshot.data!.isEmpty) {
                          return const Center(child: Text('No events available.'));
                        } else {
                          final events = eventsSnapshot.data!;
                          return ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: EventCard(
                                  title: event.title,
                                  startTime: event.getFormattedStartTime(),
                                  endTime: event.getFormattedEndTime(),
                                  description: event.description,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailsPage(event: event),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(100, 105, 105, 105),
        currentIndex: 0,
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(selectedIndex: index),
            ),
          );
        },
        selectedItemColor: const Color.fromARGB(220, 255, 179, 0),
        unselectedItemColor: const Color.fromARGB(150, 192, 192, 192),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}