import 'package:flutter/material.dart';

class AIPostureScreen extends StatefulWidget {
  const AIPostureScreen({super.key});

  @override
  State<AIPostureScreen> createState() => _AIPostureScreenState();
}

class _AIPostureScreenState extends State<AIPostureScreen> {
  final List<String> _exercises = [
    'Squats',
    'Push-ups',
    'Pull-ups',
    'Jumping Jacks',
    'Russian Twists',
  ];
  String? _selectedExercise;
  bool _isDetecting = false;
  String _feedbackMessage = 'Ready to detect. Press Start.';
  double _formScore = 0.0;

  void _startMockDetection() {
    setState(() {
      _isDetecting = true;
      _feedbackMessage = 'Analyzing posture...';
      _formScore = 0.0;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (_isDetecting) {
        setState(() {
          _feedbackMessage = 'Good form! Keep your back straight.';
          _formScore = 85;
        });
      }
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (_isDetecting) {
        setState(() {
          _feedbackMessage = 'Excellent! Depth is perfect.';
          _formScore = 92;
        });
      }
    });
  }

  void _stopDetection() {
    setState(() {
      _isDetecting = false;
      _feedbackMessage = 'Detection stopped. Press Start again.';
      _formScore = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Motion & Posture Detection'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Exercise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: _exercises.map((exercise) {
                  return RadioListTile<String>(
                    title: Text(exercise),
                    value: exercise,
                    groupValue: _selectedExercise,
                    onChanged: _isDetecting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedExercise = value;
                              _feedbackMessage = 'Ready to detect. Press Start.';
                              _formScore = 0.0;
                            });
                          },
                    activeColor: Colors.deepPurple,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off, size: 60, color: Colors.white70),
                            SizedBox(height: 12),
                            Text(
                              'Camera Preview',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Real-time posture detection will appear here',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isDetecting)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: _formScore / 100,
                                backgroundColor: Colors.grey,
                                color: Colors.green,
                                minHeight: 6,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _feedbackMessage,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Make sure your whole body is visible in the camera.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_selectedExercise == null || _isDetecting)
                        ? null
                        : _startMockDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Detection',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDetecting ? _stopDetection : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Stop / Finish',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isDetecting && _formScore > 0)
              Card(
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Last session result:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$_selectedExercise – Form score: ${_formScore.toStringAsFixed(0)}%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}