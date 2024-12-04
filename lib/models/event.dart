import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String image;
  final String description;
  final String locationName;
  final String tag;

  Event({
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.image = '',
    this.description = 'No Description',
    this.locationName = 'Unknown Location',
    this.tag = 'No Tag',
  });

  // Factory method to create an Event from Firestore document snapshot
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Event(
      eventId: doc.id,
      title: data['title'] ?? 'No Title',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      image: data['image'] ?? '',
      description: data['description'] ?? 'No Description',
      locationName: data['locationName'] ?? 'Unknown Location',
      tag: data['tag'] ?? 'No Tag',
    );
  }

  // Factory method to create an Event from JSON data
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      image: json['image'] ?? '',
      description: json['description'] ?? 'No Description',
      locationName: json['locationName'] ?? 'Unknown Location',
      tag: json['tag'] ?? 'No Tag',
    );
  }

  // Format Start Time
  String getFormattedStartTime() {
    return DateFormat('MMMM dd, yyyy, h:mm a').format(startTime);
  }

  // Format End Time
  String getFormattedEndTime() {
    return DateFormat('MMMM dd, yyyy, h:mm a').format(endTime);
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'image': image,
      'description': description,
      'locationName': locationName,
      'tag': tag,
    };
  }
}
