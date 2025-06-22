import 'package:codemaster/views/Start/create_acc_view.dart';
import 'package:codemaster/widgets/bott_nav.dart';
import 'package:codemaster/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (authResponse.user == null) {
        throw 'Failed to sign in.';
      }

      final userId = authResponse.user!.id;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      final userData = response;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget buildShadowedTextField({
    required TextEditingController controller,
    required String hintText,
    required Icon prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBE8EC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/LogoCodMaster 4.png',
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Let’s Sign In.!!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2575),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Login to Your Account to Continue your Courses',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            buildShadowedTextField(
              controller: _emailController,
              hintText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            buildShadowedTextField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
               child:CustomActionButton(
                  text: 'Sign In',
                onPressed: _isLoading ? null : _signIn,), 
               ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an Account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateAccView()),
                    );
                  },
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(color: Color(0xFF2A2575)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
