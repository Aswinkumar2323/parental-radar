import 'dart:convert';
import 'package:http/http.dart' as http;


Future<dynamic> fetchModuleData({
  required String module,
  required String userId,
}) async {
  final String apiUrl = 'https://us-central1-parentcontrol-9a079.cloudfunctions.net/api/$module?user=$userId';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📥 Data received: $data');
      return data; // Could be Map or List depending on module
    } else if (response.statusCode == 404) {
      print('⚠️ No data found for $module');
      return null;
    } else {
      print('❌ Failed to fetch data: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('🔥 Error fetching data: $e');
    return null;
  }
}
