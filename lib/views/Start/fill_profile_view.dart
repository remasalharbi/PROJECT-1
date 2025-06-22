import 'dart:io';
import 'package:codemaster/widgets/bott_nav.dart';
import 'package:codemaster/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codemaster/widgets/custom_text_field.dart';
import 'package:codemaster/widgets/gender_dropdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FillProfileView extends StatefulWidget {
  const FillProfileView({super.key, required Map userData});

  @override
  State<FillProfileView> createState() => _FillProfileViewState();
}

class _FillProfileViewState extends State<FillProfileView> {
  String? selectedGender;
  final Color primaryColor = const Color(0xFF2A2575);
  final Color backgroundColor = const Color(0xFFF5F9FF);
  File? _profileImageFile;
  bool _showSuccessPopup = false;
  final nameController = TextEditingController();
  final nickNameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'name': nameController.text,
        'nickname': nickNameController.text,
        'dob': dobController.text,
        'email': emailController.text,
        'gender': selectedGender,
      });

      _showSuccessCard();
    } catch (e) {
    }
  }

  void _showSuccessCard() {
    setState(() => _showSuccessPopup = true);
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text('Fill Your Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: primaryColor,
                          backgroundImage: _profileImageFile != null ? FileImage(_profileImageFile!) : null,
                          child: _profileImageFile == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(hint: 'Full Name', controller: nameController),
                  CustomTextField(hint: 'Nick Name', controller: nickNameController),
                  CustomTextField(hint: 'Date of Birth', icon: Icons.calendar_today, controller: dobController),
                  CustomTextField(hint: 'Email', icon: Icons.email_outlined, controller: emailController),
                  GenderDropdown(
                    value: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                  ),
                  const SizedBox(height: 10),
                  CustomActionButton(
                    text: 'Continue',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccessPopup)
            Center(
              child: Container(
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              child: SingleChildScrollView(
    child: Center(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF2A2575),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Congratulations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2575),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Account is Ready to Use.\nYou will be redirected to the Home Page in a Few Seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          const CircularProgressIndicator(),
            ],
            ),
          ),
        ),
      ),
    ),
  ),
  ],
      ),
    );
  }
}
