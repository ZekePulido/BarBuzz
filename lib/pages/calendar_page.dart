import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Current selected index for the bottom navigation bar
  int _selectedIndex = 0;

  // Function to handle item tap on the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation or actions based on selected index
    // For example, you can navigate to different pages or perform actions
    // if (index == 0) { ... }
    // if (index == 1) { ... }
    // if (index == 2) { ... }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Color.fromARGB(175, 168, 0, 0),
        title: Center(
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Calendar Page',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(100, 105, 105, 105),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
