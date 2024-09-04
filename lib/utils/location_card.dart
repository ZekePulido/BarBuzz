import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationCard extends StatefulWidget {
  final String imagePath;
  final String location; // Use location instead of locationId
  final String locationId; // Keep locationId for favoriting functionality
  final Function onTap;

  LocationCard({
    required this.imagePath,
    required this.location, // Pass the location name
    required this.locationId, // Keep locationId for favoriting functionality
    required this.onTap,
  });

  @override
  _LocationCardState createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  bool _isFavorited = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isFavorited = data['favorites'].any((fav) => fav['_id'] == widget.locationId);
        });
      }
    } catch (e) {
      print('Error fetching favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'locationId': widget.locationId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      } else {
        print('Failed to update favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = 100.0; // Adjust size as needed

    return Card(
      color: Colors.grey[800],
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: SizedBox(
          width: imageSize,
          height: imageSize,
          child: Image.network(
            widget.imagePath,
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
              return Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),
        title: Text(widget.location, style: TextStyle(color: Colors.white)), // Display location name
        trailing: IconButton(
          icon: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border,
            color: _isFavorited ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
        onTap: () => widget.onTap(),
      ),
    );
  }
}
