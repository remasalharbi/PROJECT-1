import 'package:codemaster/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:codemaster/widgets/custom_text_field.dart';
import 'package:codemaster/widgets/gender_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  String? selectedGender;
  final fullNameController = TextEditingController();
  final nickNameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  File? _profileImageFile;
  final Color primaryColor = const Color(0xFF2A2575);
  final Color backgroundColor = const Color(0xFFF5F9FF);

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _profileImageFile = File(pickedImage.path);
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    dobController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    try {
      await Supabase.instance.client
          .from('users')
          .update({
            'name': fullNameController.text,
            'nickname': nickNameController.text,
            'dob': dobController.text,
            'email': emailController.text,
            'gender': selectedGender,
          })
          .eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF2A2575)),
        title: const Text('Edit Profile', style: TextStyle(color: Color(0xFF2A2575))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: primaryColor,
                backgroundImage: _profileImageFile != null ? FileImage(_profileImageFile!) : null,
                child: _profileImageFile == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),

            CustomTextField(hint: 'Full Name', controller: fullNameController),
            CustomTextField(hint: 'Nick Name', controller: nickNameController),
            CustomTextField(hint: 'Date of Birth', icon: Icons.calendar_today, controller: dobController),
            CustomTextField(hint: 'Email', icon: Icons.email_outlined, controller: emailController),
            GenderDropdown(
              value: selectedGender,
              onChanged: (val) => setState(() => selectedGender = val),
            ),
            const SizedBox(height: 32),
            CustomActionButton(
              text: 'Update',
              onPressed: _handleUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
