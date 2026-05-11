import 'package:flutter/material.dart';
import '../shared/openai_service.dart';
import '../features/standup_generator/services/slack_service.dart';
import '../shared/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _openAIController = TextEditingController(text: '');
  final _slackController = TextEditingController();
  final _openAI = OpenAIService();
  final _slack = SlackService();
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _openAIController.dispose();
    _slackController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final key = await _openAI.getApiKey();
    final webhook = await _slack.getWebhookUrl();
    setState(() {
      _openAIController.text = key ?? '';
      _slackController.text = webhook ?? '';
    });
  }

  Future<void> _save() async {
    // await _openAI.saveApiKey(_openAIController.text.trim());
    await _openAI.saveApiKey(_openAIController.text.trim());
    await _slack.saveWebhookUrl(_slackController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings saved!'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsCard(
              title: '🤖 OpenAI API Key',
              subtitle: 'Required for Widget Generator & Standup AI',
              child: TextField(
                controller: _openAIController,
                obscureText: _obscureKey,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureKey ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white38),
                    onPressed: () =>
                        setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: '💬 Slack Webhook URL',
              subtitle: 'For posting standup updates to your Slack channel',
              child: TextField(
                controller: _slackController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'https://hooks.slack.com/services/...',
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
            ),
            const SizedBox(height: 24),
            const _InfoCard(),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ℹ️ How to get API Keys',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white)),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'OpenAI API Key',
              value: 'platform.openai.com → API Keys',
            ),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Slack Webhook',
              value: 'api.slack.com → Incoming Webhooks',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.secondary)),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                TextSpan(
                    text: value,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
