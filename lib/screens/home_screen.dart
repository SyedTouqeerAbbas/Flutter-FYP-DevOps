import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';          // Profile screens
import 'fitness_log_screen.dart';      // Fitness Log screen
import 'ai_posture_screen.dart';       // AI Posture Detection screen (NEW)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ModulesPage(),
    const ProgressPage(),
    const StorePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ============= HOME TAB: 7 MODULES GRID =============
class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _navigateTo(BuildContext context, String module) {
    if (module == 'Fitness Log') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FitnessLogScreen()),
      );
    } else if (module == 'AI Posture Detection') {   // NEW condition
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIPostureScreen()),
      );
    } else {
      // Other modules - show coming soon dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(module),
          content: Text('$module screen will be implemented soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Fitness-Wellness-Companion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)],
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $userName! 🎉', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Ready to crush your goals today?', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.deepPurpleAccent]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keep Going!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Every Workout Counts.', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('Modules', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _ModuleCard(
                    imagePath: 'assets/images/profile.png',
                    title: 'Profile',
                    onTap: () => _openProfile(context),
                  ),
                  _ModuleCard(
                    imagePath: 'assets/images/fitness_log.png',
                    title: 'Fitness Log',
                    onTap: () => _navigateTo(context, 'Fitness Log'),
                  ),
                  _ModuleCard(
                    imagePath: 'assets/images/posture1.jpg',
                    title: 'AI Posture Detection',
                    onTap: () => _navigateTo(context, 'AI Posture Detection'),
                  ),
                  _ModuleCard(
                    imagePath: 'assets/images/store.png',
                    title: 'Supplement Store',
                    onTap: () => _navigateTo(context, 'Supplement Store'),
                  ),
                  _ModuleCard(
                    imagePath: 'assets/images/wellness.jpg',
                    title: 'Wellness Recommendations',
                    onTap: () => _navigateTo(context, 'Wellness Recommendations'),
                  ),
                  _ModuleCard(
                    imagePath: 'assets/images/wellness1.jpg',
                    title: 'Community (Anonymous)',
                    onTap: () => _navigateTo(context, 'Community'),
                  ),
                  _ModuleCard(
                    imagePath: 'assets/images/reward.png',
                    title: 'Rewards',
                    onTap: () => _navigateTo(context, 'Rewards'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  const _ModuleCard({required this.imagePath, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  width: 80,
                  color: Colors.deepPurple.shade50,
                  child: const Icon(Icons.image_not_supported, size: 40, color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ============= PROGRESS TAB =============
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracker'), backgroundColor: Colors.deepPurple),
      body: const Center(child: Text('Workout & diet progress charts will be shown here.')),
    );
  }
}

// ============= STORE TAB =============
class StorePage extends StatelessWidget {
  const StorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supplement Store'), backgroundColor: Colors.deepPurple),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.shopping_bag, color: Colors.deepPurple), title: Text('Whey Protein'), trailing: Text('\$49.99')),
          ListTile(leading: Icon(Icons.shopping_bag, color: Colors.deepPurple), title: Text('Creatine'), trailing: Text('\$29.99')),
          ListTile(leading: Icon(Icons.shopping_bag, color: Colors.deepPurple), title: Text('BCAA'), trailing: Text('\$34.99')),
          ListTile(leading: Icon(Icons.shopping_bag, color: Colors.deepPurple), title: Text('Multivitamin'), trailing: Text('\$19.99')),
        ],
      ),
    );
  }
}