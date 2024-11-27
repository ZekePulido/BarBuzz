import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String imagePath;
  final String location;
  final String locationId;
  final VoidCallback onTap;

  const LocationCard({
    Key? key,
    required this.imagePath,
    required this.location,
    required this.locationId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Image.network(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/logos/BarBee.png', // Fallback image
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),

            // Arrow Icon
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
