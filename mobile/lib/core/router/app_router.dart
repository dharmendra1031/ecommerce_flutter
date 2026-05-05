import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/categories_list_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/product_list_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/cart/presentation/providers/cart_providers.dart';
import '../../features/order/presentation/screens/order_list_screen.dart';
import '../../features/order/presentation/providers/order_providers.dart';
import '../../features/order/presentation/screens/order_detail_screen.dart';
import '../../features/order/presentation/screens/track_order_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/address_list_screen.dart';
import '../../features/profile/presentation/screens/add_edit_address_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart';
import '../../features/profile/presentation/screens/card_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/review/presentation/screens/my_reviews_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'route_names.dart';

/// ChangeNotifier wrapper for auth state - triggers GoRouter refresh
/// without rebuilding the entire GoRouter instance.
class AuthChangeListener extends ChangeNotifier {
  final Ref ref;
  AuthChangeListener(this.ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}

final authChangeListenerProvider = Provider<AuthChangeListener>((ref) {
  return AuthChangeListener(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeListener = ref.watch(authChangeListenerProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeListener,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final user = authState.valueOrNull;
      final isLoading = authState.isLoading;
      final isAuthenticated = user != null;
      final isEmailVerified = user?.isEmailVerified ?? false;

      final location = state.matchedLocation;

      final isAuthRoute = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
      ].any((route) => location.startsWith(route));

      final isVerificationRoute = location == RouteNames.verifyEmail;

      final isPublicRoute = [
        RouteNames.splash,
        RouteNames.onboarding,
      ].contains(location);

      if (location == RouteNames.splash || location == RouteNames.onboarding) {
        return null;
      }

      if (isLoading) {
        return null;
      }

      if (!isAuthenticated && !isAuthRoute && !isPublicRoute) {
        return RouteNames.login;
      }

      if (isAuthenticated &&
          !isEmailVerified &&
          !isVerificationRoute &&
          !isAuthRoute) {
        return RouteNames.verifyEmail;
      }

      if (isAuthenticated && isAuthRoute) {
        return RouteNames.home;
      }

      if (isVerificationRoute && isEmailVerified) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '${RouteNames.resetPassword}/:token',
        name: 'resetPassword',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/checkout/success',
        name: 'checkoutSuccess',
        builder: (context, state) {
          final extra = state.extra;
          String? orderId;
          String? orderNumber;
          if (extra is Map<String, dynamic>) {
            orderId = extra['orderId'] as String?;
            orderNumber = extra['orderNumber'] as String?;
          } else if (extra is String) {
            orderNumber = extra;
          }
          return CheckoutSuccessScreen(
            orderId: orderId,
            orderNumber: orderNumber,
          );
        },
      ),
      GoRoute(
        path: '/track-order/:orderId',
        name: 'trackOrder',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return TrackOrderScreen(orderId: orderId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'products/:id',
                    name: 'productDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ProductDetailScreen(productId: id);
                    },
                  ),
                  GoRoute(
                    path: 'categories',
                    name: 'categoriesList',
                    builder: (context, state) => const CategoriesListScreen(),
                  ),
                  GoRoute(
                    path: 'category/:categoryId',
                    name: 'categoryProducts',
                    builder: (context, state) {
                      final categoryId = state.pathParameters['categoryId']!;
                      final categoryName = state.extra as String?;
                      return ProductListScreen(
                        categoryId: categoryId,
                        categoryName: categoryName,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'flash-sale',
                    name: 'flashSale',
                    builder: (context, state) => const ProductListScreen(
                      isFlashSale: true,
                    ),
                  ),
                  GoRoute(
                    path: 'featured',
                    name: 'featured',
                    builder: (context, state) => const ProductListScreen(
                      isFeatured: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.search,
                name: 'search',
                builder: (context, state) => const ProductListScreen(),
                routes: [
                  GoRoute(
                    path: 'products/:id',
                    name: 'searchProductDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ProductDetailScreen(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.cart,
                name: 'cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    name: 'checkout',
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.notifications,
                name: 'notifications',
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editProfile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'addresses',
                    name: 'addresses',
                    builder: (context, state) => const AddressListScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: 'addAddress',
                        builder: (context, state) =>
                            const AddEditAddressScreen(),
                      ),
                      GoRoute(
                        path: 'edit/:id',
                        name: 'editAddress',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AddEditAddressScreen(addressId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'orders',
                    name: 'orders',
                    builder: (context, state) => const OrderListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'orderDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return OrderDetailScreen(orderId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'wishlist',
                    name: 'wishlist',
                    builder: (context, state) => const WishlistScreen(),
                    routes: [
                      GoRoute(
                        path: 'products/:id',
                        name: 'wishlistProductDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ProductDetailScreen(productId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'reviews',
                    name: 'myReviews',
                    builder: (context, state) => const MyReviewsScreen(),
                  ),
                  GoRoute(
                    path: 'card',
                    name: 'card',
                    builder: (context, state) => const CardScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: 'notificationSettings',
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'password',
                    name: 'changePassword',
                    builder: (context, state) => const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    name: 'helpSupport',
                    builder: (context, state) => const HelpSupportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  final String? orderId;
  final String? orderNumber;

  const CheckoutSuccessScreen({
    super.key,
    this.orderId,
    this.orderNumber,
  });

  @override
  ConsumerState<CheckoutSuccessScreen> createState() =>
      _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends ConsumerState<CheckoutSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(ordersNotifierProvider);
    });
  }

  Future<void> _goToOrderTracking() async {
    await ref.read(cartNotifierProvider.notifier).clearCart();
    if (widget.orderId != null) {
      if (mounted) {
        final router = GoRouter.of(context);
        router.go('/track-order/${widget.orderId}');
      }
    } else {
      if (mounted) {
        final router = GoRouter.of(context);
        router.go('/home');
      }
    }
  }

  Future<void> _continueShopping() async {
    await ref.read(cartNotifierProvider.notifier).clearCart();
    if (mounted) {
      final router = GoRouter.of(context);
      router.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Order Placed!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                if (widget.orderNumber != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Order Number',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.orderNumber!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Thank you for your purchase. We have received your order and will process it shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _goToOrderTracking,
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Track Order'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _continueShopping,
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Continue Shopping'),
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
