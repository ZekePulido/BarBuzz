import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:barbuzz/pages/bar_profile_page.dart'; // Adjust based on your project structure

class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({super.key, required this.eventId});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController(); // Added
  final TextEditingController _endTimeController = TextEditingController(); // Added

  DateTime? startTime;
  DateTime? endTime;
  bool isLoading = true;

  String? selectedTag; // Store the selected tag
  final List<String> tagOptions = ['Drinks', 'Food', 'Events']; // Tag options

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/events/${widget.eventId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          titleController.text = data['title'] ?? '';
          descriptionController.text = data['description'] ?? '';
          imageController.text = data['image'] ?? '';
          startTime = DateTime.parse(data['startTime']);
          endTime = DateTime.parse(data['endTime']);
          _startTimeController.text =
              DateFormat('yyyy-MM-dd – kk:mm').format(startTime!);
          _endTimeController.text =
              DateFormat('yyyy-MM-dd – kk:mm').format(endTime!);
          selectedTag = data['tag']; // Set the tag for the dropdown
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load event details.')),
      );
    }
  }

  Future<void> _submitEventUpdate() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/events/${widget.eventId}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'title': titleController.text,
            'description': descriptionController.text,
            'image': imageController.text,
            'startTime': startTime?.toIso8601String(),
            'endTime': endTime?.toIso8601String(),
            'tag': selectedTag, // Send the selected tag
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BarProfilePage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update event.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update event.')),
        );
      }
    }
  }

  Future<void> _pickDateTime(BuildContext context,
      {required TextEditingController controller,
      bool isStartTime = true}) async {
    final initialDate =
        isStartTime ? startTime ?? DateTime.now() : endTime ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartTime) {
            startTime = selectedDateTime;
          } else {
            endTime = selectedDateTime;
          }
          controller.text =
              DateFormat('yyyy-MM-dd – kk:mm').format(selectedDateTime);
        });
      }
    }
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
          padding: EdgeInsets.only(left: screenWidth * 0.12),
          child: Image.asset(
            'assets/logos/BarBuzz.png',
            height: 80,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(220, 255, 179, 0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Edit Event',
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
                            controller: titleController,
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
                                return 'Please enter an event title';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Event Description
                          TextFormField(
                            controller: descriptionController,
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
                            maxLines: 3,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Tag Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedTag,
                            items: tagOptions
                                .map((tag) => DropdownMenuItem(
                                      value: tag,
                                      child: Text(tag),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTag = value;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              hintText: 'Select event tag...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a tag';
                              }
                              return null;
                            },
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () {
                                  _pickDateTime(context,
                                      controller: _startTimeController,
                                      isStartTime: true);
                                },
                              ),
                            ),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () {
                                  _pickDateTime(context,
                                      controller: _endTimeController,
                                      isStartTime: false);
                                },
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Submit Button
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: _submitEventUpdate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.02,
                                ),
                              ),
                              child: Text(
                              'Update Event',
                               style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
