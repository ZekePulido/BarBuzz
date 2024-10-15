import 'package:barbuzz/pages/bar_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date and time
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode

class CreateEventsPage extends StatefulWidget {
  final String locationId;
  const CreateEventsPage({super.key, required this.locationId});

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

  // Subtract 5 hours for CST (Central Standard Time)
  final updatedStartTime = _startDateTime!.subtract(const Duration(hours: 5)).toUtc().toIso8601String();
  final updatedEndTime = _endDateTime!.subtract(const Duration(hours: 5)).toUtc().toIso8601String();
  final String tag = selectedTags.isNotEmpty ? selectedTags.first : '';

  final Map<String, String> body = {
    'title': title,
    'description': description,
    'startTime': updatedStartTime,
    'endTime': updatedEndTime,  
    'location': widget.locationId,
    'tag': tag,
  };

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/events'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BarProfilePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event. Status code: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
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
        // Create a full DateTime object
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Adjust to Central Standard Time (CST) by subtracting 5 hours
        final DateTime cstDateTime = fullDateTime.subtract(const Duration(hours: 5));

        // Store the UTC time in the controller for posting
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(cstDateTime);

        // Update the displayed time in the text field using the desired format
        setState(() {
          if (isStartTime) {
            _startDateTime = fullDateTime; // Store the full date-time object
            _startTimeController.text =
                getFormattedStartTime(); // Display formatted time
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
                              onPressed: () =>
                                  _selectDateTime(context, _endTimeController, false),
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
