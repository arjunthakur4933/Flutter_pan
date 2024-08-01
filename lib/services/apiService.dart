import 'package:http/http.dart' as http;
import 'dart:convert';
// here we will write services/apis for the app
//since both the api's that were provided have a same base url let
//create a variable to store the base url
class APIService {
  static const String baseUrl = 'https://lab.pixel6.co/api';

  static Future<Map<String, dynamic>> verifyPAN(String panNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-pan.php'),
      body: json.encode({'panNumber': panNumber}),
      headers: {'Content-Type': 'application/json'},
    );
//according to the documentation if response code is true
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify PAN');
    }
  }
// to get the post code
  static Future<Map<String, dynamic>> getPostcodeDetails(String postcode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get-postcode-details.php'),
      body: json.encode({'postcode': postcode}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get postcode details');
    }
  }
}