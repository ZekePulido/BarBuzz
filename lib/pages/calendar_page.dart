import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'full_calendar_page.dart'; // Import FullCalendarPage if needed

// Event class definition (copy this from full_calendar_page.dart if it's not in a separate file)
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

// API URL (Replace with your actual API URL)
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
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03), // Add some padding to the edges
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left)
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FullCalendarPage()),
                  );
                },
                child: Text(
                  "See full calendar",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: screenWidth * 0.04,
                    decoration: TextDecoration.underline, // Optional: add underline to indicate it's clickable
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // Reduced space
            Text(
              "Today's Deals:",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // Reduced space
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
            SizedBox(height: screenHeight * 0.02), // Reduced space between the lists
            Text(
              "Tomorrow's Deals:",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // Reduced space
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
    );
  }
}
