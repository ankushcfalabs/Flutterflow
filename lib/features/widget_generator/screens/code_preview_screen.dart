import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../shared/app_theme.dart';

class CodePreviewScreen extends StatelessWidget {
  final String code;

  const CodePreviewScreen({super.key, required this.code});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Code copied!'),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Code',
            onPressed: () => _copy(context),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                Expanded(child: _CodePanel(code: code)),
                const VerticalDivider(color: Colors.white12, width: 1),
                Expanded(child: _PreviewPanel()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _CodePanel(code: code)),
                const Divider(color: Colors.white12, height: 1),
                Expanded(child: _PreviewPanel()),
              ],
            ),
    );
  }
}

class _CodePanel extends StatelessWidget {
  final String code;

  const _CodePanel({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.codeBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Icon(Icons.code, color: AppTheme.secondary, size: 16),
                SizedBox(width: 6),
                Text('Generated Dart Code',
                    style: TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: HighlightView(
                code,
                language: 'dart',
                theme: atomOneDarkTheme,
                textStyle: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12.5, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 48, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Live Preview',
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Copy the code and run it\nin your Flutter project',
              style: TextStyle(color: Colors.black26, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
