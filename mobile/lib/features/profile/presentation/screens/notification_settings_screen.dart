import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool orderUpdates;
  final bool promotions;
  final bool newProducts;
  final bool priceDrops;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.orderUpdates = true,
    this.promotions = false,
    this.newProducts = false,
    this.priceDrops = true,
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? orderUpdates,
    bool? promotions,
    bool? newProducts,
    bool? priceDrops,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newProducts: newProducts ?? this.newProducts,
      priceDrops: priceDrops ?? this.priceDrops,
    );
  }

  Map<String, dynamic> toJson() => {
        'pushNotifications': pushNotifications,
        'emailNotifications': emailNotifications,
        'orderUpdates': orderUpdates,
        'promotions': promotions,
        'newProducts': newProducts,
        'priceDrops': priceDrops,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      orderUpdates: json['orderUpdates'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      newProducts: json['newProducts'] as bool? ?? false,
      priceDrops: json['priceDrops'] as bool? ?? true,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  static const String _prefsKey = 'notification_settings';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        // Simple parsing since we can't use dart:convert here directly
        final map = _parseJson(jsonString);
        state = NotificationSettings.fromJson(map);
      }
    } catch (e) {
      // Use defaults on error
    }
  }

  Map<String, dynamic> _parseJson(String json) {
    final map = <String, dynamic>{};
    final cleaned = json.replaceAll('{', '').replaceAll('}', '').trim();
    final pairs = cleaned.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim().replaceAll("'", '').replaceAll('"', '');
        final value = parts[1].trim().toLowerCase() == 'true';
        map[key] = value;
      }
    }
    return map;
  }

  String _toJsonString(Map<String, dynamic> map) {
    final pairs = map.entries.map((e) => "'${e.key}': ${e.value}").join(', ');
    return '{$pairs}';
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _toJsonString(state.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  void setPushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
    _saveSettings();
  }

  void setEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
    _saveSettings();
  }

  void setOrderUpdates(bool value) {
    state = state.copyWith(orderUpdates: value);
    _saveSettings();
  }

  void setPromotions(bool value) {
    state = state.copyWith(promotions: value);
    _saveSettings();
  }

  void setNewProducts(bool value) {
    state = state.copyWith(newProducts: value);
    _saveSettings();
  }

  void setPriceDrops(bool value) {
    state = state.copyWith(priceDrops: value);
    _saveSettings();
  }

  void resetToDefaults() {
    state = const NotificationSettings();
    _saveSettings();
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: () {
              notifier.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // General Section
          const _SectionHeader(title: 'General'),
          _SwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on your device',
            value: settings.pushNotifications,
            onChanged: (value) => notifier.setPushNotifications(value),
          ),
          _SwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            value: settings.emailNotifications,
            onChanged: (value) => notifier.setEmailNotifications(value),
          ),

          const Divider(),

          // Order Section
          const _SectionHeader(title: 'Orders'),
          _SwitchTile(
            icon: Icons.local_shipping_outlined,
            title: 'Order Updates',
            subtitle: 'Updates about your order status and shipping',
            value: settings.orderUpdates,
            onChanged: settings.pushNotifications
                ? (value) => notifier.setOrderUpdates(value)
                : null,
          ),

          const Divider(),

          // Marketing Section
          const _SectionHeader(title: 'Marketing'),
          _SwitchTile(
            icon: Icons.campaign_outlined,
            title: 'Promotions & Offers',
            subtitle: 'Special deals, discounts and promotions',
            value: settings.promotions,
            onChanged: settings.pushNotifications
                ? (value) => notifier.setPromotions(value)
                : null,
          ),
          _SwitchTile(
            icon: Icons.new_releases_outlined,
            title: 'New Products',
            subtitle: 'Be the first to know about new arrivals',
            value: settings.newProducts,
            onChanged: settings.pushNotifications
                ? (value) => notifier.setNewProducts(value)
                : null,
          ),
          _SwitchTile(
            icon: Icons.trending_down_outlined,
            title: 'Price Drops',
            subtitle: 'Get notified when items in your wishlist drop in price',
            value: settings.priceDrops,
            onChanged: settings.pushNotifications
                ? (value) => notifier.setPriceDrops(value)
                : null,
          ),

          const Divider(),

          // Info Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'You can manage your notification preferences here. Some notifications like security alerts cannot be disabled.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = onChanged == null;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDisabled
                ? colorScheme.surfaceContainerHighest
                : colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isDisabled ? colorScheme.onSurfaceVariant : colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
