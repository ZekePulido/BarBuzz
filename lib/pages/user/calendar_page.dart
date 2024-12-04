import 'package:barbuzz/pages/user/full_calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final String locationName;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.title,
    required this.locationName,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      title: data['title'] ?? 'No Title',
      locationName: data['locationName'] ?? 'No Location',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
    );
  }

  String get formattedStartTime {
    return DateFormat('h:mm a').format(startTime);
  }

  String get formattedEndTime {
    return DateFormat('h:mm a').format(endTime);
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String _selectedTag = 'All';
  List<Event> _todayEvents = [];
  List<Event> _tomorrowEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchAndSetEvents();
  }

  Future<void> _fetchAndSetEvents({String? tag}) async {
    try {
      // Firestore query to get events
      Query eventsQuery = FirebaseFirestore.instance.collection('events');

      // Apply tag filter if a specific tag is selected
      if (tag != null && tag != 'All') {
        eventsQuery = eventsQuery.where('tag', isEqualTo: tag);
      }

      final querySnapshot = await eventsQuery.get();
      final events = querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      final today = DateTime.now();
      final tomorrow = DateTime.now().add(const Duration(days: 1));

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
      _fetchAndSetEvents(tag: tag == 'All' ? null : tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.15),
          child: Center(
            child: Image.asset(
              'assets/logos/BarBuzz.png',
              height: 80,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FullCalendarPage()),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${event.locationName} • ${event.formattedStartTime} - ${event.formattedEndTime}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : const Center(
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
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${event.locationName} • ${event.formattedStartTime} - ${event.formattedEndTime}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : const Center(
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.yellow : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.yellow : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
