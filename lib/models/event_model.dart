class Event {
  final String title;
  final String location;
  final DateTime startingTime;
  final DateTime endingTime;
  final DateTime actualDate;

  Event({
    required this.title,
    required this.location,
    required this.startingTime,
    required this.endingTime,
    required this.actualDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      location: json['location'],
      startingTime: DateTime.parse(json['startingTime']),
      endingTime: DateTime.parse(json['endingTime']),
      actualDate: DateTime.parse(json['actualDate']),
    );
  }
}
