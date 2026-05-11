import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/standup_update.dart';
import '../services/standup_service.dart';
import '../services/slack_service.dart';
import '../services/activity_service.dart';
import '../../../shared/app_theme.dart';

class StandupScreen extends StatefulWidget {
  const StandupScreen({super.key});

  @override
  State<StandupScreen> createState() => _StandupScreenState();
}

class _StandupScreenState extends State<StandupScreen> {
  final _standupService = StandupService();
  final _slackService = SlackService();
  final _activityService = ActivityService();

  StandupUpdate? _update;
  bool _generating = false;
  bool _posting = false;
  bool _editing = false;
  final _taskController = TextEditingController();
  final _blockersController = TextEditingController();
  final _editController = TextEditingController();
  List<String> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _blockersController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _loadActivity() async {
    final tasks = await _activityService.getTasks();
    final blockers = await _activityService.getBlockers();
    setState(() {
      _tasks = tasks;
      _blockersController.text = blockers;
    });
  }

  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    await _activityService.addTask(text);
    _taskController.clear();
    await _loadActivity();
  }

  Future<void> _removeTask(int index) async {
    await _activityService.removeTask(index);
    await _loadActivity();
  }

  Future<void> _saveBlockers() async {
    await _activityService.saveBlockers(_blockersController.text.trim());
    _snack('✅ Blockers saved!');
  }

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _update = null;
      _editing = false;
    });
    try {
      final update = await _standupService.generateUpdate();
      setState(() {
        _update = update;
        _editController.text = update.fullText;
      });
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _postToSlack() async {
    if (_update == null) return;
    setState(() => _posting = true);
    try {
      final date = _formatDate(_update!.timestamp);
      final text = _editing ? _editController.text : _update!.fullText;
      final message = '📱 *Standup Update - $date*\n\n$text';
      final success = await _slackService.postMessage(message);
      if (success) _showSnack('✅ Posted to Slack!');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => _posting = false);
    }
  }

  void _copyUpdate() {
    if (_update == null) return;
    final text = _editing ? _editController.text : _update!.fullText;
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('✅ Copied to clipboard!');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.accent,
    ));
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : AppTheme.accent,
    ));
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Standup'),
        actions: [
          if (_update != null)
            IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy',
                onPressed: _copyUpdate),
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Regenerate',
              onPressed: _generating ? null : _generate),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ActivityInputCard(
              taskController: _taskController,
              blockersController: _blockersController,
              tasks: _tasks,
              onAddTask: _addTask,
              onRemoveTask: _removeTask,
              onSaveBlockers: _saveBlockers,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_generating ? 'Generating...' : 'Generate Standup'),
            ),
            if (_update != null) ...[
              const SizedBox(height: 20),
              if (_editing)
                _EditCard(
                  controller: _editController,
                  onDone: () => setState(() => _editing = false),
                )
              else
                _StandupCard(update: _update!),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(_editing ? Icons.check : Icons.edit, size: 18),
                      label: Text(_editing ? 'Done' : 'Edit'),
                      onPressed: () => setState(() => _editing = !_editing),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send, size: 18),
                      label: Text(_posting ? 'Posting...' : 'Post to Slack'),
                      onPressed: _posting ? null : _postToSlack,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A154B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Based on ${_update!.commitCount} logged tasks',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityInputCard extends StatelessWidget {
  final TextEditingController taskController;
  final TextEditingController blockersController;
  final List<String> tasks;
  final VoidCallback onAddTask;
  final void Function(int) onRemoveTask;
  final VoidCallback onSaveBlockers;

  const _ActivityInputCard({
    required this.taskController,
    required this.blockersController,
    required this.tasks,
    required this.onAddTask,
    required this.onRemoveTask,
    required this.onSaveBlockers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 Log Your Activities',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add task or activity...',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => onAddTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAddTask,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12)),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...tasks.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppTheme.accent),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13))),
                        GestureDetector(
                          onTap: () => onRemoveTask(e.key),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white38),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 12),
            const Text('⚠️ Blockers',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white70)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: blockersController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Any blockers? (or leave as None)',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onSaveBlockers,
                  child: const Text('Save',
                      style: TextStyle(color: AppTheme.accent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDone;

  const _EditCard({required this.controller, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Edit Standup',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 10,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.6),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StandupCard extends StatelessWidget {
  final StandupUpdate update;

  const _StandupCard({required this.update});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Standup - ${update.timestamp.day}/${update.timestamp.month}/${update.timestamp.year}',
                  style: const TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),
            _Section(emoji: '✅', title: 'YESTERDAY', content: update.yesterday),
            const SizedBox(height: 12),
            _Section(emoji: '🎯', title: 'TODAY', content: update.today),
            const SizedBox(height: 12),
            _Section(emoji: '⚠️', title: 'BLOCKERS', content: update.blockers),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final String content;

  const _Section(
      {required this.emoji, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$emoji $title',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white60,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(content,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.6)),
      ],
    );
  }
}
