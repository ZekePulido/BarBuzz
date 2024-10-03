import 'dart:convert';
import 'package:barbuzz/pages/create_events_page.dart';
import 'package:barbuzz/pages/delete_event_page.dart';
import 'package:barbuzz/pages/edit_event_page.dart';
import 'package:barbuzz/pages/log_in_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:barbuzz/pages/apply_location_page.dart';
import 'package:barbuzz/models/event.dart';
import 'package:barbuzz/pages/event_details_page.dart';

class BarProfilePage extends StatefulWidget {
  const BarProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BarProfilePageState createState() => _BarProfilePageState();
}

class _BarProfilePageState extends State<BarProfilePage> {
  static const Color _textColor = Colors.white;
  String venueName = "Loading...";
  String venueAddress = "Loading...";
  String venueDescription = "Loading...";
  String locationId = "";
  Future<List<Event>>? _events;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchBarProfile();
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

        // Fetch upcoming events after profile data is fetched
        _events = fetchEventsForLocation(locationId); // Pass locationId properly
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile.')),
      );
    }
  }

  bool isDateInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  Future<List<Event>> fetchEventsForLocation(String locationId) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/locations/$locationId/events'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> eventsJson = data['events'];
      final events = eventsJson.map((json) => Event.fromJson(json)).toList();

      // Filter events for the current week
      final currentWeekEvents = events
          .where((event) =>
              isDateInCurrentWeek(event.startTime) ||
              isDateInCurrentWeek(event.endTime))
          .toList();

      return currentWeekEvents;
    } else {
      throw Exception('Failed to load events');
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
                      builder: (context) => const ApplyLocationPage(),
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
      body: SingleChildScrollView(
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
                              CreateEventsPage(locationId: locationId),
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
            SizedBox(height: screenHeight * 0.04),
            // Display the list of upcoming events
            FutureBuilder<List<Event>>(
              future: _events,
              builder: (context, eventsSnapshot) {
                if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (eventsSnapshot.hasError) {
                  return Center(child: Text('Error: ${eventsSnapshot.error}'));
                } else if (!eventsSnapshot.hasData ||
                    eventsSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No upcoming events.'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eventsSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      final event = eventsSnapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsPage(event: event),
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
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
