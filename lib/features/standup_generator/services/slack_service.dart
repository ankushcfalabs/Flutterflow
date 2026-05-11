import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SlackService {
  static const _webhookKey = 'slack_webhook_url';

  Future<String?> getWebhookUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_webhookKey);
  }

  Future<void> saveWebhookUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webhookKey, url);
  }

  Future<bool> postMessage(String message) async {
    final url = await getWebhookUrl();
    if (url == null || url.isEmpty) throw Exception('Slack webhook URL not set');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': message,
        'username': 'FlutterFlow AI Bot',
        'icon_emoji': ':robot_face:',
      }),
    );

    return response.statusCode == 200;
  }
}
