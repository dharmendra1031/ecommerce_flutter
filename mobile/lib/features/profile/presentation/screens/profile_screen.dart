import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(profileStatsNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authNotifierProvider.notifier).refreshUser();
          await ref.read(profileStatsNotifierProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            _ProfileHeader(user: user),
            const SizedBox(height: 24),

            // Stats
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (stats) => Row(
                children: [
                  _StatCard(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Orders',
                    value: '${stats.ordersCount}',
                    onTap: () => context.push('/profile/orders'),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.favorite_outline,
                    label: 'Wishlist',
                    value: '${stats.wishlistCount}',
                    onTap: () => context.push('/profile/wishlist'),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.star_outline,
                    label: 'Reviews',
                    value: '${stats.reviewsCount}',
                    onTap: () => context.push('/profile/reviews'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Section
            const _SectionTitle(title: 'Account'),
            _MenuTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => context.push('/profile/edit'),
            ),
            _MenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () => context.push('/profile/orders'),
            ),
            _MenuTile(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              onTap: () => context.push('/profile/addresses'),
            ),
            _MenuTile(
              icon: Icons.credit_card_outlined,
              title: 'Card',
              onTap: () => context.push('/profile/card'),
            ),
            const SizedBox(height: 16),

            // Activity Section
            const _SectionTitle(title: 'Activity'),
            _MenuTile(
              icon: Icons.favorite_outline,
              title: 'Wishlist',
              onTap: () => context.push('/profile/wishlist'),
            ),
            _MenuTile(
              icon: Icons.star_outline,
              title: 'My Reviews',
              onTap: () => context.push('/profile/reviews'),
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push('/profile/notifications'),
            ),
            const SizedBox(height: 16),

            // Preferences Section
            const _SectionTitle(title: 'Preferences'),
            _MenuTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => context.push('/profile/password'),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push('/profile/settings'),
            ),
            _MenuTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => context.push('/profile/help'),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  Future<void> _pickImage(BuildContext scaffoldContext, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      final failure = await ref
          .read(profileStatsNotifierProvider.notifier)
          .uploadAvatar(File(image.path));

      if (failure != null) {
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
            ),
          );
        }
      } else {
        await ref.read(authNotifierProvider.notifier).refreshUser();
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully')),
          );
        }
      }
    }
  }

  Future<void> _showAvatarOptions(BuildContext context, WidgetRef ref) async {
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldContext = context;

    await showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: colorScheme.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickImage(scaffoldContext, ref);
              },
            ),
            if (user?.avatar?.url != null)
              ListTile(
                leading: Icon(Icons.delete, color: colorScheme.error),
                title: const Text('Remove Avatar'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  final failure = await ref
                      .read(profileStatsNotifierProvider.notifier)
                      .deleteAvatar();

                  if (failure != null) {
                    if (scaffoldContext.mounted) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(failure.message),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                    }
                  } else {
                    await ref.read(authNotifierProvider.notifier).refreshUser();
                    if (scaffoldContext.mounted) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(content: Text('Avatar removed')),
                      );
                    }
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(bottomSheetContext),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showAvatarOptions(context, ref),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: user?.avatar?.url != null
                      ? CachedNetworkImageProvider(user!.avatar!.url)
                      : null,
                  child: user?.avatar?.url == null
                      ? Icon(Icons.person, size: 50, color: colorScheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary,
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Guest User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(title),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
