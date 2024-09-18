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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            event.image.isNotEmpty
                ? Image.network(
                    event.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/logos/BarBee.png', // Placeholder image
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            const SizedBox(height: 8),
            if (event.locationName != null && event.locationName!.isNotEmpty)
              Text(
                event.locationName!,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              )
            else
              const Text(
                'Location not available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            Text(
              '${event.formattedStartDateTime} - ${event.formattedEndDateTime}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              )
            else
              const Text(
                'No description available.',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
