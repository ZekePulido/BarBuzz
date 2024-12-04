import 'package:barbuzz/pages/user/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int _currentIndex = 0; // Track the current page index
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  bool get _loggedIn => _auth.currentUser != null;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.jumpToPage(index);
  }

  Future<void> _logout() async {
    await _auth.signOut();
    setState(() {}); // Update state to reflect logged-out status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
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
          const LocationsPage(),
          const CalendarPage(),
          _loggedIn ? const UserProfilePage() : const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(100, 105, 105, 105),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
