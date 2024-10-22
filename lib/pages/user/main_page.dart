import 'package:barbuzz/pages/user/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'locations_page.dart'; // Import LocationsPage widget
import 'calendar_page.dart'; // Import CalendarPage widget
import 'profile_page.dart';  // Import ProfilePage widget

class MainPage extends StatefulWidget {
  final int selectedIndex;

  const MainPage({super.key, required this.selectedIndex});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController _pageController;
  bool _loggedIn = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int _currentIndex = 0; // Track the current page index

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final token = await _storage.read(key: 'auth_token');
    setState(() {
      _loggedIn = token != null; // Update the state based on token presence
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      // Reset the CalendarPage if the Calendar tab is tapped
      setState(() {
        _pageController.jumpToPage(index);
        _pageController = PageController(initialPage: index); // Recreate PageController
      });
    } else {
      setState(() {
        _currentIndex = index;
        _pageController.jumpToPage(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1 // Only show AppBar for CalendarPage
          ? null
          : AppBar(
              automaticallyImplyLeading: false, // Remove the back arrow
              backgroundColor: const Color.fromARGB(220, 255, 179, 0),
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
          const LocationsPage(), // Use LocationsPage widget
          const CalendarPage(),  // Use CalendarPage widget
          _loggedIn ? const UserProfilePage() : const ProfilePage(), // Conditional page based on login status
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(100, 105, 105, 105),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color.fromARGB(220, 255, 179, 0), // Color for selected item
        unselectedItemColor: const Color.fromARGB(150, 192, 192, 192), // Color for unselected items
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
