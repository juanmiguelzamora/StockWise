import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/widgets/button/basic_app_button.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/domain/auth/usecases/get_user.dart';
import 'package:mobile/service_locator.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  XFile? _selectedImage;
  String? _savedImageUrl;

  String _profileImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/media/')) {
      final serverUrl = mediaBaseUrl.substring(0, mediaBaseUrl.length - 7);
      return '$serverUrl${path.substring(1)}';
    }
    return '$mediaBaseUrl$path';
  }

  Future<void> _pickProfilePicture() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image != null && mounted) setState(() => _selectedImage = image);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await sl<GetUserUseCase>().call();
    if (!mounted) return;
    result.fold(
      (_) => _showError(
        'We could not load your profile. Please try again.',
        title: 'Unable to load profile',
      ),
      (user) {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _savedImageUrl = user.profilePicture == null
          ? null
          : _profileImageUrl(user.profilePicture!);
      },
    );
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final result = await sl<AuthRepository>().updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      profilePicturePath: _selectedImage?.path,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (error) => _showError(error.toString()),
      (_) {
        Navigator.pop(context, true);
      },
    );
  }

  void _showError(String message, {String title = 'Unable to update profile'}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.blue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.blue.shade100,
                            backgroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : _savedImageUrl == null
                                ? null
                                : NetworkImage(_savedImageUrl!),
                            child: _selectedImage == null && _savedImageUrl == null
                              ? const Icon(Icons.person, size: 58, color: Colors.blue)
                              : null,
                        ),
                        IconButton(
                          onPressed: _pickProfilePicture,
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field('First name', _firstNameController),
                  const SizedBox(height: 16),
                  _field('Last name', _lastNameController),
                  const SizedBox(height: 16),
                  _field('Email', _emailController, email: true),
                  const SizedBox(height: 28),
                  BasicAppButton(
                    title: _saving ? 'Saving...' : 'Save Changes',
                    textColor: Colors.white,
                    onPressed: _saving ? () {} : _saveProfile,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController controller, {bool email = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: email ? TextInputType.emailAddress : TextInputType.name,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Enter your $label';
        if (email && !value.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }
}
