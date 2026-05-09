import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ===== Google Sign In Logic (updated with navigation) =====
  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        // Navigate to home screen after successful Google login
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ===== Email/Password Submit (updated with navigation) =====
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await userCredential.user?.updateDisplayName(_nameController.text.trim());
      }
      if (mounted) {
        // Navigate to home screen after successful email login/signup
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Auth failed'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== Circular Gym Icon =====
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/gym_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Fitness Wellness Companion",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 35),

              // Tabs
              Row(
                children: [
                  _buildTab("Login", true),
                  _buildTab("Sign Up", false),
                ],
              ),
              const SizedBox(height: 25),

              // Form Fields
              if (!isLogin) ...[
                _buildTextField(_nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 15),
              ],
              _buildTextField(_emailController, "Email Address",
                  Icons.email_outlined, isEmail: true),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, "Password", Icons.lock_outline,
                  isPass: true),

              if (!isLogin) ...[
                const SizedBox(height: 15),
                _buildTextField(_confirmPasswordController, "Confirm Password",
                    Icons.lock_reset, isConfirm: true),
              ],

              const SizedBox(height: 25),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin ? "Login" : "Sign Up",
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Log in",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 35),
              const Text("or continue with", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialIconTile(FontAwesomeIcons.google, Colors.red,
                      _handleGoogleSignIn),
                  _socialIconTile(FontAwesomeIcons.apple, Colors.black, () {}),
                  _socialIconTile(FontAwesomeIcons.facebook, Colors.blue, () {}),
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selectedTab) {
    bool active = isLogin == selectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = selectedTab),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.deepPurple : Colors.grey),
            ),
            if (active)
              Container(
                  margin: const EdgeInsets.only(top: 5),
                  height: 3,
                  width: 60,
                  color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPass = false,
    bool isEmail = false,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPass || isConfirm,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Required";
        }
        if (!isConfirm && value.trim().length < 3) {
          return "Must be at least 3 characters";
        }
        if (isEmail) {
          final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            return "Invalid email format (e.g., name@example.com)";
          }
        }
        if (isPass && value.length < 6) {
          return "Min 6 characters required";
        }
        if (isConfirm && value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  Widget _socialIconTile(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: FaIcon(icon, color: color, size: 28),
      ),
    );
  }
}