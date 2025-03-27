import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reel1/ConfirmationScreen.dart';
import 'package:reel1/services/api_controller.dart';
import 'package:reel1/utils/custom_textfield.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InquiryFormProvider extends ChangeNotifier {
  String campusName = "NXT Campus";
  String nextClass = "Class 4A";
  String previousClass = "Class 3";
  DateTime? dob;

  void setCampusName(String name) {
    campusName = name;
    notifyListeners();
  }

  void setDOB(DateTime date) {
    dob = date;
    notifyListeners();
  }

  void setNextClass(String value) {
    nextClass = value;
    notifyListeners();
  }

  void setPreviousClass(String value) {
    previousClass = value;
    notifyListeners();
  }
}

class AdmissionForm extends StatefulWidget {
  @override
  _AdmissionFormState createState() => _AdmissionFormState();
}

class _AdmissionFormState extends State<AdmissionForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  final List<String> campuses = [
    "NXT Campus",
    "Global Academy",
    "Sunrise School",
    "Bright Future Academy",
    "Elite International",
    "Green Valley Institute"
  ];

  InputDecoration customInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  Future<void> _selectDOB(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final provider = Provider.of<InquiryFormProvider>(context, listen: false);
      provider.setDOB(pickedDate); // Store in Provider

      setState(() {
        dobController.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
    }
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectCampus(BuildContext context) async {
    final provider = Provider.of<InquiryFormProvider>(context, listen: false);

    String? selectedCampus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Campus"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: campuses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(campuses[index]),
                  onTap: () => Navigator.pop(context, campuses[index]),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCampus != null) {
      provider.setCampusName(selectedCampus);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<InquiryFormProvider>(context, listen: false);
    final ApiController apiController = ApiController(); // API instance

    Map<String, dynamic> requestBody = {
      "campus_id": 67,
      "campus_name": provider.campusName,
      "student_name": studentNameController.text,
      "parent_name": parentNameController.text,
      "next_class": provider.nextClass,
      "previous_class": provider.previousClass,
      "dob": provider.dob != null
          ? "${provider.dob!.day}-${provider.dob!.month}-${provider.dob!.year}"
          : "",
      "contact_no": contactController.text,
      "address": addressController.text,
      "email": emailController.text
    };

    try {
      final response = await apiController.submitForm(requestBody);

      if (response["status"] == "OK") {
        _showNotification();
        _saveSubmissionData(requestBody);
        print(requestBody);

        bool shouldClear = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(data: requestBody),
          ),
        );

        if (shouldClear == true) {
          parentNameController.clear();
          studentNameController.clear();
          contactController.clear();
          emailController.clear();
          addressController.clear();
          dobController.clear();
        }
      } else {
        _showErrorDialog("Submission failed. ${response['message']}");
      }
    } catch (error) {
      _showErrorDialog("Network error. Please check your connection.");
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_ID',
      'Channel Name',
      channelDescription: 'This channel is used for local notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      "Admission Inquiry Submitted",
      "Your admission inquiry form has been successfully submitted.",
      platformChannelSpecifics,
    );
  }

  Future<void> _saveSubmissionData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("submissionData", jsonEncode(data));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InquiryFormProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Admission Enquiry Form",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () => _selectCampus(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Campus Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon:
                            Icon(Icons.arrow_drop_down, color: Colors.blue),
                      ),
                      controller:
                          TextEditingController(text: provider.campusName),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                CustomTextFormField(
                  controller: parentNameController,
                  label: "Parent Name",
                  hint: "Enter parent's full name",
                  validator: (value) =>
                      value!.isEmpty ? "Required field" : null,
                ),
                SizedBox(height: 2.h),
                CustomTextFormField(
                  controller: studentNameController,
                  label: "Student Name",
                  hint: "Enter student's full name",
                  validator: (value) =>
                      value!.isEmpty ? "Required field" : null,
                ),
                SizedBox(height: 2.h),
                DropdownButtonFormField<String>(
                  value: provider.nextClass,
                  items: ["Class 4A", "Class 5B", "Class 6C"]
                      .map((e) => DropdownMenuItem(child: Text(e), value: e))
                      .toList(),
                  onChanged: (val) => provider.setNextClass(val!),
                  decoration:
                      customInputDecoration("Next Class", "Select next class"),
                ),
                SizedBox(height: 2.h),
                DropdownButtonFormField<String>(
                  value: provider.previousClass,
                  items: ["Class 3", "Class 4", "Class 5"]
                      .map((e) => DropdownMenuItem(child: Text(e), value: e))
                      .toList(),
                  onChanged: (val) => provider.setPreviousClass(val!),
                  decoration: customInputDecoration(
                      "Previous Class", "Select previous class"),
                ),
                SizedBox(height: 2.h),
                CustomTextFormField(
                  controller: contactController,
                  label: "Contact Number",
                  hint: "Enter mobile number",
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.length == 10
                      ? null
                      : "Enter valid 10-digit number",
                ),
                SizedBox(height: 2.h),
                CustomTextFormField(
                  controller: dobController,
                  label: "Date of Birth",
                  hint: "Select date of birth",
                  readOnly: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: () => _selectDOB(context),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Date of Birth is required" : null,
                ),
                SizedBox(height: 2.h),
                CustomTextFormField(
                  controller: emailController,
                  label: "Email",
                  hint: "Enter a valid email",
                  validator: (value) =>
                      value!.contains("@") ? null : "Enter a valid email",
                ),
                SizedBox(height: 2.h),
                CustomTextFormField(
                  controller: addressController,
                  label: "Address",
                  hint: "Enter full address",
                  validator: (value) =>
                      value!.isEmpty ? "Please Enter your address" : null,
                ),
                SizedBox(height: 4.h),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
