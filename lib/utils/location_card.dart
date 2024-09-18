import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String imagePath;
  final String location; // Use location instead of locationId
  final String locationId; // Keep locationId for favoriting functionality
  final Function onTap;

  const LocationCard({super.key, 
    required this.imagePath,
    required this.location, // Pass the location name
    required this.locationId, // Keep locationId for favoriting functionality
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const imageSize = 100.0; // Adjust size as needed

    return Card(
      color: Colors.grey[800],
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: SizedBox(
          width: imageSize,
          height: imageSize,
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),
        title: Text(location, style: const TextStyle(color: Colors.white)), // Display location name
        onTap: () => onTap(),
      ),
    );
  }
}
