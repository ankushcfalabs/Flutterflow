class StandupUpdate {
  final String yesterday;
  final String today;
  final String blockers;
  final DateTime timestamp;
  final int commitCount;

  StandupUpdate({
    required this.yesterday,
    required this.today,
    required this.blockers,
    required this.timestamp,
    required this.commitCount,
  });

  String get fullText => '''✅ YESTERDAY:
$yesterday

🎯 TODAY:
$today

⚠️ BLOCKERS:
$blockers''';
}
