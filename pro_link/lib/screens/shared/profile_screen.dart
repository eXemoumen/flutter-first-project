import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/responsive_page.dart';
import '../../widgets/role_badge.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).currentUser;
      _nameController.text = user?.fullName ?? '';
      _phoneController.text = user?.phone ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = ref.read(authProvider);
    final user = auth.currentUser;
    if (user == null) return;

    try {
      await ref.read(databaseServiceProvider).upsertUser(
            user.copyWith(
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            ),
          );

      await auth.refreshUser();
      if (!mounted) return;
      AppFeedback.success(context, 'Profile updated.');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Update failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsivePage(
        maxWidth: 860,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.person_outline_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'User',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(user?.email ?? 'email@example.com'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (user != null) RoleBadge(role: user.role),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Profile'),
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

