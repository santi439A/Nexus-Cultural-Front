import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/screens/welcome_screen.dart';
import '../../features/authentication/presentation/screens/role_selection_screen.dart';
import '../../features/authentication/presentation/screens/registration_screen.dart';
import '../../features/authentication/presentation/screens/artisan_registration_flow.dart';
import '../../features/authentication/presentation/screens/buyer_registration_flow.dart';
import '../../features/authentication/presentation/screens/sms_otp_screen.dart';
import '../../features/authentication/presentation/screens/profile_setup_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/admin_registration_screen.dart';
import '../../features/discovery/presentation/screens/home_screen.dart';

import '../../features/discovery/presentation/screens/home_screen_artisan.dart';
import '../../features/discovery/presentation/screens/home_screen_admin.dart';
import '../../features/discovery/presentation/screens/filters_screen.dart';
import '../../features/discovery/presentation/screens/product_detail_screen.dart';
import '../../features/discovery/presentation/screens/artisan_profile_screen.dart';
import '../../features/discovery/presentation/screens/cultural_story_screen.dart';
import '../../features/discovery/presentation/screens/favorites_screen.dart';
import '../../features/payments/presentation/screens/cart_screen.dart';
import '../../features/payments/presentation/screens/shipping_screen.dart';
import '../../features/payments/presentation/screens/checkout_summary_screen.dart';
import '../../features/payments/presentation/screens/payment_method_screen.dart';
import '../../features/payments/presentation/screens/payment_success_screen.dart';
import '../../features/payments/presentation/screens/invoice_screen.dart';
import '../../features/payments/presentation/screens/order_tracking_screen.dart';
import '../../features/payments/presentation/screens/refund_request_screen.dart';
import '../../features/catalog/presentation/screens/artisan_dashboard_screen.dart';
import '../../features/catalog/presentation/screens/create_product_flow.dart';
import '../../features/catalog/presentation/screens/sales_metrics_screen.dart';
import '../../models/articulo_model.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // CORE PROCESS 1: User Registration & Identity Management
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/registration',
      name: 'registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/register-artisan',
      name: 'register-artisan',
      builder: (context, state) => const ArtisanRegistrationFlow(),
    ),
    GoRoute(
      path: '/register-buyer',
      name: 'register-buyer',
      builder: (context, state) => const BuyerRegistrationFlow(),
    ),
    GoRoute(
      path: '/sms-otp',
      name: 'sms-otp',
      builder: (context, state) {
        final email = state.extra as String?;
        return SmsOtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/profile-setup',
      name: 'profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register-admin',
      name: 'register-admin',
      builder: (context, state) => const AdminRegistrationScreen(),
    ),


    // CORE PROCESS 2: Cultural Discovery and Product Exploration
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/filters',
      name: 'filters',
      builder: (context, state) => const FiltersScreen(),
    ),
    GoRoute(
      path: '/product-detail',
      name: 'product-detail',
      builder: (context, state) {
        final articulo = state.extra as ArticuloModel?;
        return ProductDetailScreen(articulo: articulo);
      },
    ),
    GoRoute(
      path: '/artisan-profile',
      name: 'artisan-profile',
      builder: (context, state) => const ArtisanProfileScreen(),
    ),
    GoRoute(
      path: '/cultural-story',
      name: 'cultural-story',
      builder: (context, state) => const CulturalStoryScreen(),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),

    // CORE PROCESS 3: Payment and Billing Management
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/shipping',
      name: 'shipping',
      builder: (context, state) => const ShippingScreen(),
    ),
    GoRoute(
      path: '/checkout-summary',
      name: 'checkout-summary',
      builder: (context, state) => const CheckoutSummaryScreen(),
    ),
    GoRoute(
      path: '/payment-method',
      name: 'payment-method',
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    GoRoute(
      path: '/payment-success',
      name: 'payment-success',
      builder: (context, state) => const PaymentSuccessScreen(),
    ),
    GoRoute(
      path: '/invoice',
      name: 'invoice',
      builder: (context, state) => const InvoiceScreen(),
    ),
    GoRoute(
      path: '/order-tracking',
      name: 'order-tracking',
      builder: (context, state) => const OrderTrackingScreen(),
    ),
    GoRoute(
      path: '/refund-request',
      name: 'refund-request',
      builder: (context, state) => const RefundRequestScreen(),
    ),

    // SUPPORT PROCESS: Craft Catalog Management
    GoRoute(
      path: '/home-artisan',
      name: 'home-artisan',
      builder: (context, state) => const HomeScreenArtisan(),
    ),
    GoRoute(
      path: '/artisan-dashboard',
      name: 'artisan-dashboard',
      builder: (context, state) => const ArtisanDashboardScreen(),
    ),
    GoRoute(
      path: '/create-product',
      name: 'create-product',
      builder: (context, state) => CreateProductFlowScreen(itemToEdit: state.extra),
    ),
    GoRoute(
      path: '/sales-metrics',
      name: 'sales-metrics',
      builder: (context, state) => const SalesMetricsScreen(),
    ),
    // CORE PROCESS: Administration & Management
    GoRoute(
      path: '/home-admin',
      name: 'home-admin',
      builder: (context, state) => const HomeScreenAdmin(),
    ),
  ],
);

