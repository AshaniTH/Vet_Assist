import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _endpoint =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  Future<String> getVetHealthResponse(String userMessage) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not found. Please check your .env file.');
    }

    final uri = Uri.parse(_endpoint).replace(queryParameters: {'key': _apiKey});

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "You are a veterinary health assistant. Only answer questions related to animal health. $userMessage",
            },
          ],
        },
      ],
    });

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
}
