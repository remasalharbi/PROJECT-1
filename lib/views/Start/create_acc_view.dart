import 'package:codemaster/views/Start/signin_view.dart';
import 'package:codemaster/views/Start/verifyOTP.dart';
import 'package:codemaster/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CreateAccView extends StatefulWidget {
  const CreateAccView({super.key});

  @override
  State<CreateAccView> createState() => _CreateAccViewState();
}

class _CreateAccViewState extends State<CreateAccView> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

 Future<void> signUp() async {
  setState(() => _isLoading = true);

  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text;

  try {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = res.user;

    if (user != null) {
      await supabase.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
      });
      await supabase.from('notifications').insert({
        'user_id': user.id,
        'title': 'Account Setup Successful.!',
        'body': 'Your Account has been Created.',
        'is_read': false,
      });
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VerifyOtp(email: email)),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();}

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/LogoCodMaster 4.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Getting Started.!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2575),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create an Account to Start your all Courses',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              buildShadowedTextField(
                controller: nameController,
                hintText: 'Name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              buildShadowedTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              buildShadowedTextField(
                controller: passwordController,
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                 child:CustomActionButton(
                  text: 'Sign Up',
                onPressed: _isLoading ? null : signUp,), 
               ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SigninView()),
                      );
                    },
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(color: Color(0xFF2A2575)),
                    ),
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
