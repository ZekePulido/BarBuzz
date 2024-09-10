import 'dart:convert';
import 'package:barbuzz/pages/full_calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package

class Event {
  final String title;
  final String locationName; // Use locationName instead of location
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.title,
    required this.locationName, // Update to use locationName
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? 'No Title',
      locationName: json['locationName'] ?? 'No Location', // Update to use locationName
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
    );
  }

  String get formattedStartTime {
    return DateFormat('h:mm a').format(startTime); // Format to show time only
  }

  String get formattedEndTime {
    return DateFormat('h:mm a').format(endTime); // Format to show time only
  }
}

const String apiUrl = 'http://10.0.2.2:3000/events'; // Adjust URL as needed

Future<List<Event>> fetchEvents({String? tag}) async {
  try {
    final uri = tag == null 
      ? Uri.parse(apiUrl)
      : Uri.parse('$apiUrl/tag/$tag'); // Use the tag endpoint

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final eventsJsonList = jsonResponse['events'] as List<dynamic>;
      return eventsJsonList.map((eventJson) => Event.fromJson(eventJson)).toList();
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
  String _selectedTag = 'All'; // Default tag

  List<Event> _todayEvents = [];
  List<Event> _tomorrowEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchAndSetEvents();
  }

  Future<void> _fetchAndSetEvents({String? tag}) async {
    try {
      final events = await fetchEvents(tag: tag);

      final today = DateTime.now();
      final tomorrow = DateTime.now().add(Duration(days: 1));

      setState(() {
        _todayEvents = events.where((event) {
          final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
          return eventDate == DateTime(today.year, today.month, today.day);
        }).toList();

        _tomorrowEvents = events.where((event) {
          final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
          return eventDate == DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        }).toList();
      });
    } catch (error) {
      print('Failed to fetch events: $error');
    }
  }

  void _onTagSelected(String tag) {
    setState(() {
      _selectedTag = tag;
      _fetchAndSetEvents(tag: tag == 'All' ? null : tag); // Pass null for "All" to fetch all events
    });
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
                _buildNavItem(Icons.local_offer, "All Deals", 'All'),
                _buildNavItem(Icons.fastfood, "Food", 'Food'),
                _buildNavItem(Icons.local_drink, "Drinks", 'Drinks'),
                _buildNavItem(Icons.music_note, "Events", 'Events'),
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
                                  '${event.locationName} • ${event.formattedStartTime} - ${event.formattedEndTime}',
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
                                  '${event.locationName} • ${event.formattedStartTime} - ${event.formattedEndTime}',
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

  Widget _buildNavItem(IconData icon, String label, String tag) {
    final isSelected = _selectedTag == tag;

    return GestureDetector(
      onTap: () => _onTagSelected(tag),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add padding for better touch area
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.withOpacity(0.2) : Colors.transparent, // Highlight background
          borderRadius: BorderRadius.circular(8), // Rounded corners for the highlight
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.yellow : Colors.grey), // Highlight icon
            SizedBox(height: 4), // Add spacing between icon and label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.yellow : Colors.grey, // Highlight label
              ),
            ),
          ],
        ),
      ),
    );
  }
}
