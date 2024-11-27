import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String description;
  final VoidCallback onTap;

  const EventCard({
    Key? key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Smaller rounded corners
        ),
        color: Colors.grey[850], // Dark background for the card
        elevation: 4, // Slightly reduced shadow
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18, // Slightly smaller font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6), // Reduced spacing

              // Start Time
              Text(
                'Start: $startTime',
                style: const TextStyle(
                  fontSize: 13, // Smaller font size
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),

              // End Time
              Text(
                'End: $endTime',
                style: const TextStyle(
                  fontSize: 13, // Smaller font size
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6), // Reduced spacing

              // Event Description
              Text(
                description,
                maxLines: 2, // Limit to 2 lines for better card aesthetics
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13, // Smaller font size
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
