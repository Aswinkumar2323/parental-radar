import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendModuleData({
  required String module,
  required dynamic data, // Can be a String or Map
  required String userId,
}) async {
  final String apiUrl =
      'https://us-central1-parentcontrol-9a079.cloudfunctions.net/api/$module?user=$userId';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'data': data}),
    );

    if (response.statusCode == 200) {
      print('✅ Data sent successfully: ${response.body}');
    } else {
      print('❌ Failed to send data: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('🔥 Error sending data: $e');
  }
}
