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
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  DateTime? _originalStartTime;
  DateTime? _originalEndTime;
  bool isLoading = true;

  String? selectedTag;
  final List<String> tagOptions = ['Drinks', 'Food', 'Events'];

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
          _startDateTime = DateTime.parse(data['startTime']);
          _endDateTime = DateTime.parse(data['endTime']);
          _startTimeController.text =
              DateFormat('MMMM dd, yyyy, h:mm a').format(_startDateTime!);
          _endTimeController.text =
              DateFormat('MMMM dd, yyyy, h:mm a').format(_endDateTime!);
          _originalStartTime = _startDateTime;
          _originalEndTime = _endDateTime;
          selectedTag = data['tag'];
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
      // Subtract 5 hours from the updated times if they were modified, otherwise subtract 12 hours if the original times are used.
      final updatedStartTime = _startDateTime != _originalStartTime
          ? _startDateTime!
              .subtract(const Duration(hours: 5))
              .toUtc()
              .toIso8601String()
          : _startDateTime!.toUtc().toIso8601String();

      final updatedEndTime = _endDateTime != _originalEndTime
          ? _endDateTime!.subtract(const Duration(hours: 5)).toUtc().toIso8601String()
          : _endDateTime!.toUtc().toIso8601String();

      try {
        final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/events/${widget.eventId}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'title': titleController.text,
            'description': descriptionController.text,
            'startTime': updatedStartTime,
            'endTime': updatedEndTime,
            'tag': selectedTag,
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
                                onPressed: () => _selectDateTime(
                                    context, _startTimeController, true),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: screenHeight * 0.02),
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
                                onPressed: () => _selectDateTime(
                                    context, _endTimeController, false),
                              ),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: _submitEventUpdate,
                              style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.02,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Update Event',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
