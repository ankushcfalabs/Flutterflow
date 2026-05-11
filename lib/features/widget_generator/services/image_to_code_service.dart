import 'dart:io';
import '../../../shared/openai_service.dart';

class ImageToCodeService {
  final _ai = OpenAIService();

  Future<String> generateWidget(File imageFile) async {
    const prompt = '''
Analyze this UI screenshot and generate complete Flutter code.

Requirements:
- Use StatelessWidget or StatefulWidget as appropriate
- Include all visible UI elements
- Match colors, spacing, fonts, and layout as closely as possible
- Use Material Design widgets
- Make it production-ready with proper styling
- Include necessary imports

Return ONLY the Dart/Flutter code, no explanations, no markdown code blocks.
''';

    final code = await _ai.visionCompletion(imageFile, prompt);
    return _clean(code);
  }

  String _clean(String code) {
    return code
        .replaceAll('```dart', '')
        .replaceAll('```', '')
        .trim();
  }
}
