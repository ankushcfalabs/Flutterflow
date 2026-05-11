import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/openai_service.dart';
import '../../../shared/app_theme.dart';

class ErrorDebuggerScreen extends StatefulWidget {
  const ErrorDebuggerScreen({super.key});

  @override
  State<ErrorDebuggerScreen> createState() => _ErrorDebuggerScreenState();
}

class _ErrorDebuggerScreenState extends State<ErrorDebuggerScreen> {
  final _controller = TextEditingController();
  String? _analysis;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final error = _controller.text.trim();
    if (error.isEmpty) return;
    setState(() {
      _loading = true;
      _analysis = null;
    });
    try {
      final result = await OpenAIService().chatCompletion(_buildPrompt(error));
      setState(() => _analysis = result);
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  String _buildPrompt(String error) => '''
You are an expert Flutter developer. A developer has encountered this Flutter/Dart error:

ERROR:
$error

Explain this error and provide fixes in exactly this format:

🔍 PROBLEM:
[Plain English explanation of what went wrong, 2-3 sentences]

🎯 COMMON CAUSE:
[Most likely reason this happens, with specific Flutter widget/pattern examples]

🛠️ YOUR FIX:

Option 1: [Fix name]
[Code snippet]

Option 2: [Fix name]  
[Code snippet]

💡 PRO TIP:
[One actionable tip to avoid this error in future]

Be specific to Flutter. Show real Dart code in fixes.
''';

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : AppTheme.accent,
    ));
  }

  void _copyFix() {
    if (_analysis == null) return;
    Clipboard.setData(ClipboardData(text: _analysis!));
    _snack('✅ Fix copied!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Debugger'),
        actions: [
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Fix',
              onPressed: _copyFix,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.codeBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 7,
                style: const TextStyle(
                    color: Color(0xFFFF7675),
                    fontFamily: 'monospace',
                    fontSize: 12.5),
                decoration: const InputDecoration(
                  hintText:
                      'Paste your Flutter error message here...\n\nExample:\n══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══\nRenderBox was not laid out...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
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
                    : _analyze,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.bug_report),
                label: Text(_loading ? 'Analyzing...' : 'Debug Error'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD63031)),
              ),
            ),
          ),
          if (_analysis != null) ...[
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
                          const Icon(Icons.auto_fix_high,
                              color: AppTheme.accent, size: 18),
                          const SizedBox(width: 8),
                          const Text('Error Analysis & Fix',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _copyFix,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Fix'),
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
                          _analysis!,
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
