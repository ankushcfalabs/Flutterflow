import 'package:shared_preferences/shared_preferences.dart';

class ActivityService {
  static const _tasksKey = 'manual_tasks';
  static const _blockersKey = 'manual_blockers';

  Future<List<String>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_tasksKey) ?? [];
  }

  Future<void> addTask(String task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getStringList(_tasksKey) ?? [];
    tasks.add(task);
    await prefs.setStringList(_tasksKey, tasks);
  }

  Future<void> removeTask(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getStringList(_tasksKey) ?? [];
    if (index < tasks.length) {
      tasks.removeAt(index);
      await prefs.setStringList(_tasksKey, tasks);
    }
  }

  Future<String> getBlockers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_blockersKey) ?? 'None';
  }

  Future<void> saveBlockers(String blockers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_blockersKey, blockers);
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
