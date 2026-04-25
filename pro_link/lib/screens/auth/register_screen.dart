import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_feedback.dart';
import '../../utils/file_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _matriculeController = TextEditingController();

  AppRole _selectedRole = AppRole.intern;
  String? _pickedImagePath;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final path = await FileHelper.pickImagePath(source: source);
    if (!mounted) return;
    setState(() => _pickedImagePath = path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref.read(authProvider).register(
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            matricule: _selectedRole == AppRole.intern
                ? _matriculeController.text.trim()
                : null,
          );

      final user = ref.read(authProvider).currentUser;
      if (user != null && _pickedImagePath != null) {
        final storage = ref.read(storageServiceProvider);
        final db = ref.read(databaseServiceProvider);
        final url = await storage.uploadAvatar(
          userId: user.id,
          localPath: _pickedImagePath!,
        );
        await db.upsertUser(user.copyWith(photoUrl: url));
        await ref.read(authProvider).refreshUser();
      }

      if (!mounted) return;
      if (_selectedRole == AppRole.intern) {
        context.go('/pending');
      } else {
        context.go('/${appRoleToString(_selectedRole)}');
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        validator: (v) => Validators.requiredField(v, fieldName: 'Full name'),
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          prefixIcon: Icon(Icons.call_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: Validators.password,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AppRole>(
                        value: _selectedRole,
                        items: AppRole.values
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(AppConstants.roleLabel(role)),
                              ),
                            )
                            .toList(),
                        onChanged: (role) {
                          if (role == null) return;
                          setState(() => _selectedRole = role);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      if (_selectedRole == AppRole.intern) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _matriculeController,
                          validator: (v) => Validators.requiredField(v, fieldName: 'Matricule'),
                          decoration: const InputDecoration(
                            labelText: 'Matricule',
                            prefixIcon: Icon(Icons.credit_card_rounded),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.photo_camera_back_outlined),
                        label: Text(
                          _pickedImagePath == null
                              ? 'Pick profile photo (camera or gallery)'
                              : 'Photo selected',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Create Account'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Back to login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
