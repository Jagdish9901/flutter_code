import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiController {
  static const String _baseUrl =
      "https://api.nxtschools.com/api/v1/parent/submit-enquiry";

  Future<Map<String, dynamic>> submitForm(Map<String, dynamic> formData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to submit form. Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
