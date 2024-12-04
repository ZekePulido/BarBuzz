import 'package:barbuzz/pages/bar/bar_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  final String locationId;
  final String userId;

  const EditEventPage({
    super.key,
    required this.eventId,
    required this.locationId,
    required this.userId,
  });

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
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
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('location')
          .doc(widget.locationId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        Map<String, dynamic>? data = eventDoc.data() as Map<String, dynamic>?;
        setState(() {
          titleController.text = data?['title'] ?? '';
          descriptionController.text = data?['description'] ?? '';
          _startDateTime = (data?['startTime'] as Timestamp).toDate();
          _endDateTime = (data?['endTime'] as Timestamp).toDate();
          _startTimeController.text = getFormattedStartTime();
          _endTimeController.text = getFormattedEndTime();
          _originalStartTime = _startDateTime;
          _originalEndTime = _endDateTime;
          selectedTag = data?['tag'];
          isLoading = false;
        });
      } else {
        throw Exception('Event not found');
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
      final updatedEventData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'startTime': _startDateTime ?? _originalStartTime,
        'endTime': _endDateTime ?? _originalEndTime,
        'tag': selectedTag,
        'userId':  widget.userId,
        'locationId': widget.locationId
      };

      try {
        // Update the event in the user's specific location subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('location')
            .doc(widget.locationId)
            .collection('events')
            .doc(widget.eventId)
            .update(updatedEventData);

        // Update the event in the top-level 'locations' collection
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(widget.locationId)
            .collection('events')
            .doc(widget.eventId)
            .update(updatedEventData);

        // Also update the event in the top-level 'events' collection
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          ...updatedEventData,
          'userId': widget.userId,
          'locationId': widget.locationId,
        });

        // Navigate back to the BarProfilePage upon successful update
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BarProfilePage(),
          ),
        );
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
      initialDate: _startDateTime ?? DateTime.now(),
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
