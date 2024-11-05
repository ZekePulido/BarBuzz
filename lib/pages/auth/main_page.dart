import 'package:barbuzz/pages/auth/current_users_page.dart';
import 'package:barbuzz/pages/auth/incoming_users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminMainPage extends StatefulWidget {
  final int selectedIndex;

  const AdminMainPage({super.key, required this.selectedIndex});

  @override
  _AdminMainPageState createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  late PageController _pageController;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int _currentIndex = 0;

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
      if (index == 1) {
        _pageController.jumpToPage(index);
        _pageController = PageController(initialPage: index);
      } else {
        _currentIndex = index;
        _pageController.jumpToPage(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          const IncomingUserPage(),
          const CurrentUserPage(),
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
            icon: Icon(Icons.person),
            label: 'Incoming Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Current Users',
          ),
        ],
      ),
    );
  }
}
