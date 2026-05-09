import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FitnessLogScreen extends StatefulWidget {
  const FitnessLogScreen({super.key});

  @override
  State<FitnessLogScreen> createState() => _FitnessLogScreenState();
}

class _FitnessLogScreenState extends State<FitnessLogScreen> {
  Map<String, List<Map<String, dynamic>>> _logsByDate = {};
  DateTime _selectedDate = DateTime.now();

  final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _headerDateFormat = DateFormat('dd MMMM');
  final DateFormat _displayDateFormat = DateFormat('EEEE, dd MMMM yyyy');

  final int _workoutGoal = 2;
  final int _dietGoal = 2;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString('fitness_logs_v2');
    if (logsJson != null) {
      final Map<String, dynamic> decoded = json.decode(logsJson);
      setState(() {
        _logsByDate = decoded.map((key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)));
      });
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String logsJson = json.encode(_logsByDate);
    await prefs.setString('fitness_logs_v2', logsJson);
  }

  List<Map<String, dynamic>> get _currentDayLogs {
    final dateKey = _dateKeyFormat.format(_selectedDate);
    return _logsByDate[dateKey] ?? [];
  }

  List<Map<String, dynamic>> get _workoutLogs {
    return _currentDayLogs.where((log) => log['type'] == 'Workout').toList();
  }

  List<Map<String, dynamic>> get _dietLogs {
    return _currentDayLogs.where((log) => log['type'] == 'Diet').toList();
  }

  void _addEntry(String type) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add ${type == 'Workout' ? 'Workout' : 'Meal'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: type == 'Workout' ? 'Exercise Name' : 'Food/Meal Name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (type == 'Workout')
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
              final details = detailsController.text.trim();

              final newEntry = {
                'type': type,
                'name': name,
                'calories': calories,
                'details': details,
                'timestamp': DateTime.now().toIso8601String(),
              };

              final dateKey = _dateKeyFormat.format(_selectedDate);
              setState(() {
                _logsByDate.putIfAbsent(dateKey, () => []);
                _logsByDate[dateKey]!.add(newEntry);
              });
              _saveLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$type added!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(String type, int index) {
    final dateKey = _dateKeyFormat.format(_selectedDate);
    final list = type == 'Workout' ? _workoutLogs : _dietLogs;
    final entryToDelete = list[index];
    final allEntries = _logsByDate[dateKey]!;
    final allIndex = allEntries.indexWhere((e) => e['timestamp'] == entryToDelete['timestamp']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete ${type == 'Workout' ? 'Workout' : 'Meal'}'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _logsByDate[dateKey]!.removeAt(allIndex);
                if (_logsByDate[dateKey]!.isEmpty) {
                  _logsByDate.remove(dateKey);
                }
              });
              _saveLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entry deleted'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getProgressText() {
    final workoutCount = _workoutLogs.length;
    final dietCount = _dietLogs.length;
    final totalCompleted = workoutCount + dietCount;
    final totalTarget = _workoutGoal + _dietGoal;
    final percentage = totalTarget == 0 ? 0 : (totalCompleted / totalTarget * 100).round();
    return '$percentage% Completed';
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _dateKeyFormat.format(_selectedDate) == _dateKeyFormat.format(DateTime.now());
    final dateHeader = isToday ? 'Today, ${_headerDateFormat.format(_selectedDate)}' : _displayDateFormat.format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Fitness Log'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SingleChildScrollView(  // <-- FIX: make the whole body scrollable
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Text(
              dateHeader,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Workout Section
            _buildSection(
              title: 'Workout',
              color: Colors.orange,
              items: _workoutLogs,
              onAdd: () => _addEntry('Workout'),
              onDelete: (index) => _deleteEntry('Workout', index),
              emptyMessage: 'No workout added',
              displayDetails: true,
            ),
            const SizedBox(height: 20),
            // Diet Section
            _buildSection(
              title: 'Diet',
              color: Colors.green,
              items: _dietLogs,
              onAdd: () => _addEntry('Diet'),
              onDelete: (index) => _deleteEntry('Diet', index),
              emptyMessage: 'No diet added',
              displayDetails: false,
            ),
            const SizedBox(height: 20),
            // Today's Progress Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Progress",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressItem('Workout', _workoutLogs.length, _workoutGoal, Colors.orange),
                        _buildProgressItem('Diet', _dietLogs.length, _dietGoal, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_workoutLogs.length + _dietLogs.length) / (_workoutGoal + _dietGoal),
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.deepPurple,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _getProgressText(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required List<Map<String, dynamic>> items,
    required VoidCallback onAdd,
    required Function(int) onDelete,
    required String emptyMessage,
    required bool displayDetails,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with add button
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 24),
                  onPressed: onAdd,
                  color: color,
                ),
              ],
            ),
            const Divider(),
            // List of items
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    emptyMessage,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            if (displayDetails && item['details'].isNotEmpty)
                              Text(
                                item['details'],
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${item['calories']} kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => onDelete(index),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, int current, int target, Color color) {
    return Column(
      children: [
        Text(
          '$current/$target',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label),
      ],
    );
  }
}