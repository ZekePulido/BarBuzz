import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class IncomingUserPage extends StatefulWidget {
  const IncomingUserPage({super.key});

  @override
  _IncomingUserPageState createState() => _IncomingUserPageState();
}

class _IncomingUserPageState extends State<IncomingUserPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<dynamic> _applicants = [];

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }
  
  Future<void> _fetchApplicants() async {
    final url = Uri.parse('http://10.0.2.2:3000/applicants');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _applicants = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load applicants');
    }
  }

  Future<void> _acceptApplicant(String applicantId) async {
    final url = Uri.parse('http://10.0.2.2:3000/applicants/accept/$applicantId');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      _fetchApplicants(); // Refresh the list
    } else {
      print('Failed to accept applicant');
    }
  }

  Future<void> _denyApplicant(String applicantId) async {
    final url = Uri.parse('http://10.0.2.2:3000/applicants/deny/$applicantId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      _fetchApplicants(); // Refresh the list
    } else {
      print('Failed to deny applicant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Incoming Bar Applicants',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _applicants.length,
              itemBuilder: (context, index) {
                final applicant = _applicants[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      applicant['username'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptApplicant(applicant['_id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _denyApplicant(applicant['_id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
