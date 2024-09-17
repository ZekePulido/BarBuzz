import 'package:intl/intl.dart';

class Event {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String image;
  final String? description;
  final String? locationName;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.image = '',
    this.description,
    this.locationName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? 'No Title',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now(),
      image: json['image'] ?? '',
      description: json['description'],
      locationName: json['locationName'], // Corrected field name
    );
  }

  String get formattedStartDateTime {
    return DateFormat('MMMM d, yyyy h:mm a').format(startTime);
  }

  String get formattedEndDateTime {
    return DateFormat('h:mm a').format(endTime);
  }
}
