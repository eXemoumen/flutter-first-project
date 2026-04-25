import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/responsive_page.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = ref.read(notificationServiceProvider);
      await service.initialize();
      final token = await service.getToken();

      final role = ref.read(authProvider).role;
      if (role != null) {
        await service.subscribeToRoleTopic(appRoleToString(role));
      }

      if (!mounted) return;
      setState(() => _token = token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ResponsivePage(
        maxWidth: 900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _NotificationTile(
              title: 'New timetable uploaded',
              subtitle: 'Engineering weekly schedule is now available.',
            ),
            const _NotificationTile(
              title: 'Evaluation reminder',
              subtitle: 'Submit skill marks before Friday 5:00 PM.',
            ),
            const _NotificationTile(
              title: 'Policy update',
              subtitle: 'Company safety handbook has been revised.',
            ),
            if (_token != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'FCM token: $_token',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.notifications_active_outlined),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

