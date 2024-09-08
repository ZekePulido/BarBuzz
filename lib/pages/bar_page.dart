import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'main_page.dart';
import 'package:intl/intl.dart';

// Event class for parsing event details
class Event {
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? 'No Title',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now(),
    );
  }

  String get formattedStartDateTime {
    return DateFormat('MMMM d, yyyy h:mm a').format(startTime);
  }

  String get formattedEndDateTime {
    return DateFormat('h:mm a').format(endTime);
  }
}

class BarPage extends StatefulWidget {
  final String imagePath;
  final String locationId;
  final String locationName;

  BarPage({
    required this.imagePath,
    required this.locationId,
    required this.locationName,
  });

  @override
  _BarPageState createState() => _BarPageState();
}

class _BarPageState extends State<BarPage> {
  late Future<Map<String, dynamic>> _locationDetails;
  late Future<List<Event>> _events;
  bool _isFavorited = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _locationDetails = fetchLocationDetails(widget.locationId);
    _events = fetchEventsForLocation(widget.locationId);
    _checkFavoriteStatus();
  }

 Future<Map<String, dynamic>> fetchLocationDetails(String locationId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/locations/$locationId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load location details');
  }
}


  bool isDateInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(Duration(days: 1)));
  }

  Future<List<Event>> fetchEventsForLocation(String locationId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/locations/$locationId/events'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> eventsJson = data['events'];
      final events = eventsJson.map((json) => Event.fromJson(json)).toList();

      // Filter events for the current week
      final currentWeekEvents = events.where((event) =>
          isDateInCurrentWeek(event.startTime) || isDateInCurrentWeek(event.endTime)).toList();

      return currentWeekEvents;
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isFavorited = data['favorites'].any((fav) => fav['_id'] == widget.locationId);
        });
      }
    } catch (e) {
      print('Error fetching favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'locationId': widget.locationId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      } else {
        print('Failed to update favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(220, 255, 179, 0),
      title: Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.005),
        child: Center(
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border,
            color: _isFavorited ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    ),
    backgroundColor: Colors.black,
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _locationDetails,
        builder: (context, locationSnapshot) {
          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (locationSnapshot.hasError) {
            return Center(child: Text('Error: ${locationSnapshot.error}'));
          } else if (!locationSnapshot.hasData || locationSnapshot.data!.isEmpty) {
            return Center(child: Text('No details available.'));
          } else {
            final location = locationSnapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        widget.imagePath.isNotEmpty ? widget.imagePath : 'https://via.placeholder.com/150',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.locationName.isNotEmpty ? widget.locationName : 'Unknown Location',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Address: ${location['address'] ?? 'No address provided'}",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Description: ${location['description'] ?? 'No description provided'}",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                FutureBuilder<List<Event>>(
                  future: _events,
                  builder: (context, eventsSnapshot) {
                    if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (eventsSnapshot.hasError) {
                      return Center(child: Text('Error: ${eventsSnapshot.error}'));
                    } else if (!eventsSnapshot.hasData || eventsSnapshot.data!.isEmpty) {
                      return Center(child: Text('No events available.'));
                    } else {
                      final events = eventsSnapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return ListTile(
                              title: Text(
                                event.title,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${event.formattedStartDateTime} - ${event.formattedEndDateTime}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                )
              ],
            );
          }
        },
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Color.fromARGB(100, 105, 105, 105),
      currentIndex: 0,
      onTap: (index) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(selectedIndex: index),
          ),
        );
      },
      selectedItemColor: Color.fromARGB(220, 255, 179, 0),
      unselectedItemColor: Color.fromARGB(150, 192, 192, 192),
      items: [
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