import '../../../shared/openai_service.dart';
import '../models/standup_update.dart';
import 'activity_service.dart';

class StandupService {
  final _ai = OpenAIService();
  final _activity = ActivityService();

  Future<StandupUpdate> generateUpdate() async {
    final tasks = await _activity.getTasks();
    final blockers = await _activity.getBlockers();

    final taskList = tasks.isEmpty
        ? 'No tasks logged yet'
        : tasks.map((t) => '- $t').join('\n');

    final prompt = '''
You are a developer assistant. Generate a concise daily standup update.

LOGGED TASKS / ACTIVITIES:
$taskList

BLOCKERS:
$blockers

Generate a standup with exactly 3 sections. Be concise, use bullet points.
Format your response as JSON with keys: "yesterday", "today", "blockers"
Each value is a string with bullet points using "•" character.
Example:
{
  "yesterday": "• Completed login screen UI\\n• Fixed profile image upload bug",
  "today": "• Working on payment integration\\n• Will review team PRs",
  "blockers": "• Waiting on API keys from backend"
}

If no blockers, set blockers to "• None".
Return ONLY valid JSON, no extra text.
''';

    final raw = await _ai.chatCompletion(prompt);
    return _parse(raw, tasks.length);
  }

  StandupUpdate _parse(String raw, int commitCount) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Simple JSON parsing without dart:convert for safety
      final yesterday = _extract(cleaned, 'yesterday');
      final today = _extract(cleaned, 'today');
      final blockers = _extract(cleaned, 'blockers');

      return StandupUpdate(
        yesterday: yesterday,
        today: today,
        blockers: blockers,
        timestamp: DateTime.now(),
        commitCount: commitCount,
      );
    } catch (_) {
      return StandupUpdate(
        yesterday: raw,
        today: '• Continue current tasks',
        blockers: '• None',
        timestamp: DateTime.now(),
        commitCount: commitCount,
      );
    }
  }

  String _extract(String json, String key) {
    final pattern = RegExp('"$key"\\s*:\\s*"((?:[^"\\\\]|\\\\.)*)"');
    final match = pattern.firstMatch(json);
    if (match == null) return '• Not available';
    return match.group(1)!.replaceAll('\\n', '\n');
  }
}
