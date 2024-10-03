import 'package:intl/intl.dart';

class Event {
  final String eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String image;
  final String? description;
  final String? locationName;
  final String? tag; 

  Event({
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.image = '',
    this.description,
    this.locationName,
    this.tag, 
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      image: json['image'] ?? '',
      description: json['description'],
      locationName: json['locationName'],
      tag: json['tag'], 
    );
  }

  String getFormattedStartTime() {
    return DateFormat('MMMM dd, yyyy, h:mm a')
        .format(startTime.toUtc().add(Duration(hours: -6))); // Adjust to CST
  }

  String getFormattedEndTime() {
    return DateFormat('MMMM dd, yyyy, h:mm a')
        .format(endTime.toUtc().add(Duration(hours: -6))); // Adjust to CST
  }
}
