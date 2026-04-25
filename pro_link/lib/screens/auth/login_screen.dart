import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref.read(authProvider).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;

      final role = ref.read(authProvider).role;
      if (role == null) return;
      context.go('/${role.name}');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Sign in to continue to your dashboard.'),
                          const SizedBox(height: 24),
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
                            controller: _passwordController,
                            obscureText: true,
                            validator: Validators.password,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Sign In'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Create an account'),
                          ),
                          const SizedBox(height: 8),
                          if (!AppConstants.backendEnabled)
                            const Text(
                              'Running in mock mode. Add SUPABASE_URL and SUPABASE_ANON_KEY to enable backend.',
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
