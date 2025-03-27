import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  ConfirmationScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Confirmation"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              bool exit = await _showExitDialog(context);
              if (exit) {
                Navigator.pop(context,
                    true); 
              }
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Submission Successful!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  _buildTableRow("Campus Name", data['campus_name'] ?? 'N/A'),
                  _buildTableRow("Parent Name", data['parent_name']),
                  _buildTableRow("Student Name", data['student_name']),
                  _buildTableRow("Next Class", data['next_class']),
                  _buildTableRow("Previous Class", data['previous_class']),
                  _buildTableRow(
                      "DOB", data['dob'].isNotEmpty ? data['dob'] : 'N/A'),
                  _buildTableRow("Email", data['email']),
                  _buildTableRow("Contact No", data['contact_no']),
                  _buildTableRow("Address", data['address']),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    bool exit = await _showExitDialog(context);
                    if (exit) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text("Back"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit Confirmation"),
            content: Text("Are you sure you want to go back?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), 
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
