import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/notification/presentation/providers/notification_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WeStoreApp(),
    ),
  );
}

class WeStoreApp extends ConsumerWidget {
  const WeStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'WeStore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return _AuthRedirectHandler(child: child!);
      },
    );
  }
}

class _AuthRedirectHandler extends ConsumerStatefulWidget {
  final Widget child;

  const _AuthRedirectHandler({required this.child});

  @override
  ConsumerState<_AuthRedirectHandler> createState() =>
      _AuthRedirectHandlerState();
}

class _AuthRedirectHandlerState extends ConsumerState<_AuthRedirectHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotifications();
    }
  }

  void _refreshNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(unreadCountNotifierProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
