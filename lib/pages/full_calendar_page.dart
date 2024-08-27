import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:barbuzz/pages/main_page.dart';

// Event class definition
class Event {
  final String title;
  final String location;
  final DateTime time;

  Event({required this.title, required this.location, required this.time});
}

class FullCalendarPage extends StatefulWidget {
  @override
  _FullCalendarPageState createState() => _FullCalendarPageState();
}

class _FullCalendarPageState extends State<FullCalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Sample event data with Event model
  final Map<DateTime, List<Event>> _events = {
    DateTime(2024, 8, 27): [
      Event(title: 'Event 1', location: 'Location A', time: DateTime(2024, 8, 27, 10, 0)),
      Event(title: 'Event 2', location: 'Location B', time: DateTime(2024, 8, 27, 14, 30)),
    ],
    DateTime(2024, 8, 28): [
      Event(title: 'Event 3', location: 'Location C', time: DateTime(2024, 8, 28, 9, 0)),
    ],
    // Add more events here
  };

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(175, 168, 0, 0),
        title: Center(
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: TableCalendar(
              locale: 'en_US',
              rowHeight: 43,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: _onDaySelected,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color.fromARGB(150, 225, 71, 44),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(150, 33, 150, 243),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.white),
                selectedTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.red),
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
                            margin: EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              availableGestures: AvailableGestures.all,
            ),
          ),
          Expanded(
            flex: 2,
            child: _selectedDayEvents.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: _selectedDayEvents.map((event) {
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
                      }).toList(),
                    ),
                  )
                : Center(
                    child: Text(
                      'No events for selected day',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(100, 105, 105, 105),
        currentIndex: 1,
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(selectedIndex: index),
            ),
          );
        },
        selectedItemColor: Color.fromARGB(150, 225, 71, 44),
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
