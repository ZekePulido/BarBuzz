import 'package:barbuzz/pages/bar/bar_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date and time
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventsPage extends StatefulWidget {
  final String locationId; // The location document ID
  final String userId; // The user document ID
  const CreateEventsPage(
      {super.key, required this.locationId, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _CreateEventsPageState createState() => _CreateEventsPageState();
}

class _CreateEventsPageState extends State<CreateEventsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  List<String> selectedTags = [];
  final List<String> tagOptions = ['Drinks', 'Food', 'Events'];

  @override
  void dispose() {
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

 Future<void> _createEvent() async {
  final title = _eventTitleController.text;
  final description = _eventDescriptionController.text;

  if (_startDateTime == null || _endDateTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select valid start and end times')),
    );
    return;
  }

  final startTime = _startDateTime!.toUtc();
  final endTime = _endDateTime!.toUtc();
  final String tag = selectedTags.isNotEmpty ? selectedTags.first : '';

  try {
    // Generate a unique ID for the event
    String eventId = FirebaseFirestore.instance.collection('events').doc().id;

    // Fetch only the 'location' field from the location document
    DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('location')
        .doc(widget.locationId)
        .get();

    if (locationSnapshot.exists) {
      String locationName =
          locationSnapshot.get('locationName') ?? 'Unknown Location';

      // Build event data
      final eventData = {
        'title': title,
        'description': description,
        'startTime': startTime,
        'endTime': endTime,
        'locationName': locationName, // Store only the location name
        'tag': tag,
        'userId': widget.userId,
        'locationId': widget.locationId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add the event under the user's location in Firestore with the specified event ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('location')
          .doc(widget.locationId)
          .collection('events')
          .doc(eventId)
          .set(eventData);

      // Add the event under the top-level 'locations' collection with the same event ID
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
          .collection('events')
          .doc(eventId)
          .set(eventData);

      // Also add the event to the top-level 'events' collection with the same event ID
      await FirebaseFirestore.instance.collection('events').doc(eventId).set(eventData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully.')),
      );

      // Navigate to the BarProfilePage upon successful event creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BarProfilePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found.')),
      );
    }
  } catch (e) {
    print('Error occurred: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create event: $e')),
    );
  }
}


  Future<void> _selectDateTime(BuildContext context,
      TextEditingController controller, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final DateTime cstDateTime =
            fullDateTime.subtract(const Duration(hours: 5));

        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(cstDateTime);

        setState(() {
          if (isStartTime) {
            _startDateTime = fullDateTime;
            _startTimeController.text = getFormattedStartTime();
          } else {
            _endDateTime = fullDateTime;
            _endTimeController.text = getFormattedEndTime();
          }
        });
      }
    }
  }

  String getFormattedStartTime() {
    return _startDateTime != null
        ? DateFormat('MMMM dd, yyyy, h:mm a').format(_startDateTime!)
        : '';
  }

  String getFormattedEndTime() {
    return _endDateTime != null
        ? DateFormat('MMMM dd, yyyy, h:mm a').format(_endDateTime!)
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(220, 255, 179, 0),
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.10),
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(220, 255, 179, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Create Event',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Event Title
                        TextFormField(
                          controller: _eventTitleController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter event title...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the event title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Event Description
                        TextFormField(
                          controller: _eventDescriptionController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Enter event description...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the event description';
                            }
                            return null;
                          },
                          maxLines: 3,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Start Time
                        TextFormField(
                          controller: _startTimeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Select start time...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors.grey),
                              onPressed: () => _selectDateTime(
                                  context, _startTimeController, true),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the start time';
                            }
                            return null;
                          },
                          readOnly: true,
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // End Time
                        TextFormField(
                          controller: _endTimeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            hintText: 'Select end time...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors.grey),
                              onPressed: () => _selectDateTime(
                                  context, _endTimeController, false),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the end time';
                            }
                            return null;
                          },
                          readOnly: true,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Tags Selection
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          value: selectedTags.isNotEmpty
                              ? selectedTags.first
                              : null,
                          hint: const Text('Select tag'),
                          onChanged: (newValue) {
                            setState(() {
                              selectedTags = [newValue!];
                            });
                          },
                          items: tagOptions.map((String tag) {
                            return DropdownMenuItem<String>(
                              value: tag,
                              child: Text(tag),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // Submit Button
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _createEvent();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.15,
                                vertical: screenHeight * 0.015,
                              ),
                              backgroundColor: Colors.black,
                            ),
                            child: Text(
                              'Create Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
