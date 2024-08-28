import 'package:barbuzz/pages/full_calendar_page.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Today's Deals:",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Text(
              "Tomorrow's Deals:",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
