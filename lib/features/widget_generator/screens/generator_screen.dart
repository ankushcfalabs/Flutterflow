import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../services/image_to_code_service.dart';
import '../../../shared/app_theme.dart';
import 'code_preview_screen.dart';

class WidgetGeneratorScreen extends StatefulWidget {
  const WidgetGeneratorScreen({super.key});

  @override
  State<WidgetGeneratorScreen> createState() => _WidgetGeneratorScreenState();
}

class _WidgetGeneratorScreenState extends State<WidgetGeneratorScreen> {
  File? _image;
  String? _code;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) setState(() => _image = File(xfile.path));
  }

  Future<void> _generate() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
      _code = null;
    });
    try {
      final code = await ImageToCodeService().generateWidget(_image!);
      setState(() => _code = code);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _copy() {
    if (_code == null) return;
    Clipboard.setData(ClipboardData(text: _code!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Code copied to clipboard!'),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Generator'),
        actions: [
          if (_code != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Code',
              onPressed: _copy,
            ),
        ],
      ),
      body: Column(
        children: [
          _ImagePickerArea(image: _image, onTap: _pickImage),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_image == null || _loading) ? null : _generate,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? 'Generating...' : 'Generate Flutter Code'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_code != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Open Full Preview'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CodePreviewScreen(code: _code!)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondary,
                    side: const BorderSide(color: AppTheme.secondary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _CodeView(code: _code!, onCopy: _copy)),
          ],
        ],
      ),
    );
  }
}

class _ImagePickerArea extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _ImagePickerArea({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? AppTheme.primary : Colors.white24,
            width: 2,
          ),
        ),
        child: image == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 56, color: AppTheme.primary),
                  SizedBox(height: 12),
                  Text('Tap to select UI screenshot',
                      style: TextStyle(color: Colors.white54, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Supports PNG, JPG',
                      style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Tap to change',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CodeView extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;

  const _CodeView({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.codeBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.code, color: AppTheme.secondary, size: 18),
                const SizedBox(width: 8),
                const Text('Generated Code',
                    style: TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: onCopy,
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
