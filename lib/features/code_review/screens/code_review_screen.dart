import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/openai_service.dart';
import '../../../shared/app_theme.dart';

class CodeReviewScreen extends StatefulWidget {
  const CodeReviewScreen({super.key});

  @override
  State<CodeReviewScreen> createState() => _CodeReviewScreenState();
}

class _CodeReviewScreenState extends State<CodeReviewScreen> {
  final _controller = TextEditingController();
  String? _review;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reviewCode() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _review = null;
    });
    try {
      final result = await OpenAIService().chatCompletion(_buildPrompt(code));
      setState(() => _review = result);
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  String _buildPrompt(String code) => '''
You are an expert Flutter/Dart code reviewer. Analyze the following code and provide a structured review.

CODE TO REVIEW:
$code

Respond in exactly this format:

✅ STRENGTHS:
• [strength 1]
• [strength 2]

⚠️ ISSUES FOUND:
1. [issue description]
   → [explanation]

💡 SUGGESTIONS:
• [suggestion 1]
• [suggestion 2]

📊 SUMMARY:
[1-2 sentence overall assessment]

Be specific, concise, and actionable. Focus on Flutter/Dart best practices.
''';

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : AppTheme.accent,
    ));
  }

  void _copyReview() {
    if (_review == null) return;
    Clipboard.setData(ClipboardData(text: _review!));
    _snack('✅ Review copied!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Review'),
        actions: [
          if (_review != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Review',
              onPressed: _copyReview,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  hintText:
                      'Paste your Flutter/Dart code or PR diff here...',
                  contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_controller.text.isEmpty || _loading)
                    ? null
                    : _reviewCode,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.rate_review),
                label: Text(_loading ? 'Reviewing...' : 'Review Code'),
              ),
            ),
          ),
          if (_review != null) ...[
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.rate_review,
                              color: AppTheme.secondary, size: 18),
                          const SizedBox(width: 8),
                          const Text('AI Review',
                              style: TextStyle(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _copyReview,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accent),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          _review!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, height: 1.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
