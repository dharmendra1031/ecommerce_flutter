import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _showDeleteAccountStep1() async {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: colorScheme.error, size: 48),
        title: const Text('Delete Account?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. You will lose:'),
            SizedBox(height: 12),
            _ConsequenceItem(
                icon: Icons.shopping_bag_outlined, text: 'All order history'),
            _ConsequenceItem(
                icon: Icons.favorite_outline, text: 'Your wishlist items'),
            _ConsequenceItem(
                icon: Icons.location_on_outlined, text: 'Saved addresses'),
            _ConsequenceItem(
                icon: Icons.payment_outlined, text: 'Saved payment methods'),
            _ConsequenceItem(
                icon: Icons.star_outline, text: 'Your reviews and ratings'),
            SizedBox(height: 12),
            Text(
              'Your account will be permanently deleted.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldContinue == true && mounted) {
      _showDeleteAccountStep2();
    }
  }

  Future<void> _showDeleteAccountStep2() async {
    final colorScheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DeleteAccountDialog(
        colorScheme: colorScheme,
        onSuccess: () async {
          // Account deleted successfully - logout and navigate
          await ref.read(authNotifierProvider.notifier).logout();
          if (mounted) {
            context.go(RouteNames.login);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your account has been deleted'),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: Text(_getThemeModeLabel(themeMode)),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ),
          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('WeStore v1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),

          // Terms of Service
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),

          const Divider(),

          // Delete Account
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text(
              'Delete Account',
              style: TextStyle(color: colorScheme.error),
            ),
            subtitle: const Text('Permanently delete your account and data'),
            onTap: _showDeleteAccountStep1,
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WeStore',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.store,
            size: 40, color: Theme.of(context).colorScheme.onPrimary),
      ),
      applicationLegalese: '© 2024 WeStore. All rights reserved.',
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsequenceItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  final ColorScheme colorScheme;
  final VoidCallback onSuccess;

  const _DeleteAccountDialog({
    required this.colorScheme,
    required this.onSuccess,
  });

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndDelete() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final password = _passwordController.text;

    // First verify password by using the repository directly (not the notifier)
    // This avoids triggering auth state changes that cause rebuild loops
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final authRepository = ref.read(authRepositoryProvider);
      final loginResult = await authRepository.login(
        email: user.email,
        password: password,
        verifyOnly: true,
      );

      if (loginResult.isLeft()) {
        // Password verification failed
        final failure = loginResult.fold((l) => l, (r) => null);
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _errorMessage = failure?.message ?? 'Invalid password';
          });
        }
        return;
      }
    }

    // Password verified, proceed with deletion
    final failure =
        await ref.read(profileStatsNotifierProvider.notifier).deleteAccount();

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _isVerifying = false;
        _errorMessage = failure.message;
      });
    } else {
      // Success - close dialog and call onSuccess
      Navigator.pop(context);
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Enter your password to permanently delete your account:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscured,
              enabled: !_isVerifying,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: _isVerifying
                      ? null
                      : () => setState(() => _isObscured = !_isObscured),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: widget.colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: widget.colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isVerifying ? null : _verifyAndDelete,
          style: FilledButton.styleFrom(
            backgroundColor: widget.colorScheme.error,
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Permanently Delete'),
        ),
      ],
    );
  }
}
