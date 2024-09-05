import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'full_calendar_page.dart'; // Import FullCalendarPage if needed

class Event {
  final String title;
  final String location;
  final DateTime time;

  Event({
    required this.title,
    required this.location,
    required this.time,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? 'No Title',
      location: json['location'] ?? 'No Location',
      time: json['time'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
    );
  }
}

const String apiUrl = 'http://10.0.2.2:3000/events'; // Adjust URL as needed

Future<List<Event>> fetchEvents() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['events'];
      print('Fetched events: $jsonResponse'); // Debug output
      return jsonResponse.map((eventJson) => Event.fromJson(eventJson)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  } catch (error) {
    print('Error fetching events: $error');
    return [];
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Event> _todayEvents = [];
  List<Event> _tomorrowEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchAndSetEvents();
  }

  Future<void> _fetchAndSetEvents() async {
    try {
      final events = await fetchEvents();
      final today = DateTime.now();
      final tomorrow = DateTime.now().add(Duration(days: 1));

      setState(() {
        _todayEvents = events.where((event) {
          final eventDate = DateTime(event.time.year, event.time.month, event.time.day);
          return eventDate == DateTime(today.year, today.month, today.day);
        }).toList();

        _tomorrowEvents = events.where((event) {
          final eventDate = DateTime(event.time.year, event.time.month, event.time.day);
          return eventDate == DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        }).toList();
      });
    } catch (error) {
      print('Failed to fetch events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.15), // 15% padding on the left
          child: Center(
            child: Image.asset(
              'assets/logos/BarBuzz.png',
              height: 80,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FullCalendarPage()),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Navigation bar below the AppBar
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 8), // Add vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.local_offer, "All Deals"),
                _buildNavItem(Icons.local_drink, "Drinks"),
                _buildNavItem(Icons.fastfood, "Food"),
                _buildNavItem(Icons.music_note, "Events"),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Deals:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Expanded(
                    child: _todayEvents.isNotEmpty
                        ? ListView.builder(
                            itemCount: _todayEvents.length,
                            itemBuilder: (context, index) {
                              final event = _todayEvents[index];
                              return ListTile(
                                title: Text(
                                  event.title,
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${event.location} • ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No events for today',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    "Tomorrow's Deals:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Expanded(
                    child: _tomorrowEvents.isNotEmpty
                        ? ListView.builder(
                            itemCount: _tomorrowEvents.length,
                            itemBuilder: (context, index) {
                              final event = _tomorrowEvents[index];
                              return ListTile(
                                title: Text(
                                  event.title,
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${event.location} • ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No events for tomorrow',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey),
        SizedBox(height: 2), // Add spacing between icon and label
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
