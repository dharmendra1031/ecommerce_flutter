import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';

/// Main shell screen with bottom navigation
/// Uses StatefulNavigationShell from GoRouter for state preservation
class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  void _onTap(int index, WidgetRef ref) {
    if (index == 2) {
      ref.invalidate(cartNotifierProvider);
    }
    if (index == 3) {
      ref.invalidate(unreadCountNotifierProvider);
    }
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartBadgeCount = ref.watch(cartBadgeCountProvider);
    final notificationBadgeCount =
        ref.watch(unreadCountNotifierProvider).valueOrNull ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(index, ref),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: _CartIcon(count: cartBadgeCount, isSelected: false),
            selectedIcon: _CartIcon(count: cartBadgeCount, isSelected: true),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: _NotificationIcon(
                count: notificationBadgeCount, isSelected: false),
            selectedIcon: _NotificationIcon(
                count: notificationBadgeCount, isSelected: true),
            label: 'Notifications',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _CartIcon({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final icon = isSelected
        ? const Icon(Icons.shopping_cart)
        : const Icon(Icons.shopping_cart_outlined);

    if (count <= 0) return icon;

    return Badge(
      isLabelVisible: true,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10),
      ),
      child: icon,
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _NotificationIcon({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final icon = isSelected
        ? const Icon(Icons.notifications)
        : const Icon(Icons.notifications_outlined);

    if (count <= 0) return icon;

    return Badge(
      isLabelVisible: true,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10),
      ),
      child: icon,
    );
  }
}
