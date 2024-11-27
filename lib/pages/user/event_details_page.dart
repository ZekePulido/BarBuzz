import 'package:flutter/material.dart';
import 'package:barbuzz/models/event.dart'; // Ensure this is the correct path

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.15),
          child: Center(
            child: Image.asset(
              'assets/logos/BarBuzz.png',
              height: 80,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/logos/BarBee.png',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/logos/BarBee.png', // Placeholder image
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 16),

            // Event Title
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Event Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_pin,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.locationName?.isNotEmpty == true
                        ? event.locationName!
                        : 'Location not available.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Event Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${event.getFormattedStartTime()} - ${event.getFormattedEndTime()}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event Description Header
            Text(
              'Event Description',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Event Description
            Text(
              event.description?.isNotEmpty == true
                  ? event.description!
                  : 'No description available.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5, // Improves readability for longer text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
