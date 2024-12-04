import 'package:barbuzz/pages/user/main_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;

  Event({
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.locationName,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      title: data['title'] ?? 'No Title',
      location: data['location'] ?? 'No Location',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      locationName: data['locationName'] ?? 'No Location Name',
    );
  }

  String get formattedStartTime {
    return DateFormat('h:mm a').format(startTime);
  }

  String get formattedEndTime {
    return DateFormat('h:mm a').format(endTime);
  }
}

class FullCalendarPage extends StatefulWidget {
  const FullCalendarPage({super.key});

  @override
  _FullCalendarPageState createState() => _FullCalendarPageState();
}

class _FullCalendarPageState extends State<FullCalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      // Query Firestore to get events
      final querySnapshot = await FirebaseFirestore.instance.collection('events').get();
      final Map<DateTime, List<Event>> eventsMap = {};

      for (var doc in querySnapshot.docs) {
        final event = Event.fromFirestore(doc);
        final normalizedDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);

        if (!eventsMap.containsKey(normalizedDate)) {
          eventsMap[normalizedDate] = [];
        }
        eventsMap[normalizedDate]!.add(event);
      }

      setState(() {
        _events = eventsMap;
      });
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  List<Event> get _selectedDayEvents {
    final normalizedDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    return _events[normalizedDate] ?? [];
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
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
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEvents,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                locale: 'en_US',
                rowHeight: 43,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: _onDaySelected,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(220, 255, 179, 0),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(150, 33, 150, 243),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: Colors.white),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Color.fromARGB(220, 255, 179, 0)),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final normalizedDate = DateTime(date.year, date.month, date.day);
                    final hasEvents = _events.containsKey(normalizedDate);

                    if (hasEvents) {
                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _events[normalizedDate]!.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 255, 179, 0),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                availableGestures: AvailableGestures.all,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: _selectedDayEvents.isNotEmpty
                ? ListView.builder(
                    itemCount: _selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedDayEvents[index];
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
                      'No events for selected day',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(100, 105, 105, 105),
        currentIndex: 1,
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
