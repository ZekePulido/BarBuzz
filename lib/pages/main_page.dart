import 'package:flutter/material.dart';
import 'locations_page.dart'; // Import LocationsPage widget
import 'calendar_page.dart'; // Import CalendarPage widget
import 'profile_page.dart';  // Import ProfilePage widget

class MainPage extends StatefulWidget {
  final int selectedIndex;

  MainPage({required this.selectedIndex});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController _pageController;
  int _currentIndex = 0; // Track the current page index

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
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
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          LocationsPage(), // Use LocationsPage widget
          CalendarPage(),  // Use CalendarPage widget
          ProfilePage(),   // Use ProfilePage widget
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(100, 105, 105, 105),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color.fromARGB(175, 168, 0, 0), // Color for selected item
        unselectedItemColor: Color.fromARGB(150, 192, 192, 192), // Color for unselected items
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
