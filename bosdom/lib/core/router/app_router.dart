import 'package:go_router/go_router.dart';

import '../../features/auth/models/merchant_role.dart';
import '../../features/auth/screens/business_info_screen.dart';
import '../../features/auth/screens/delivery_address_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/personal_details_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/upload_documents_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';
import '../../features/chat/screens/chat_policy_gate.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/live_chat_screen.dart';
import '../../features/checkout/screens/add_address_screen.dart';
import '../../features/checkout/screens/address_book_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/co_buying/screens/co_buy_detail_screen.dart';
import '../../features/co_buying/screens/co_buying_screen.dart';
import '../../features/escrow/screens/escrow_screen.dart';
import '../../features/marketplace/models/category.dart';
import '../../features/marketplace/screens/category_results_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/marketplace/screens/product_detail_screen.dart';
import '../../features/marketplace/screens/store_profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/orders/screens/delivery_tracking_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/payment/screens/payment_screen.dart';
import '../../features/profile/models/faq_category.dart';
import '../../features/profile/screens/about_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/faq_detail_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/language_screen.dart';
import '../../features/profile/screens/payment_currency_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/report_issue_screen.dart';
import '../../features/profile/screens/terms_conditions_screen.dart';
import '../../features/sample_gate/screens/sample_gate_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/wishlist/screens/wishlist_screen.dart';
import 'app_shell.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/signup/personal-details',
        name: 'personalDetails',
        builder: (context, state) => PersonalDetailsScreen(
          role: state.extra as MerchantRole? ?? MerchantRole.retailer,
        ),
      ),
      GoRoute(
        path: '/signup/business-info',
        name: 'businessInfo',
        builder: (context, state) => BusinessInfoScreen(
          role: state.extra as MerchantRole? ?? MerchantRole.supplier,
        ),
      ),
      GoRoute(
        path: '/signup/upload-documents',
        name: 'uploadDocuments',
        builder: (context, state) => UploadDocumentsScreen(
          role: state.extra as MerchantRole? ?? MerchantRole.supplier,
        ),
      ),
      GoRoute(
        path: '/signup/delivery-address',
        name: 'deliveryAddress',
        builder: (context, state) => DeliveryAddressScreen(
          role: state.extra as MerchantRole? ?? MerchantRole.retailer,
        ),
      ),
      GoRoute(
        path: '/profile/become-seller',
        name: 'becomeSeller',
        builder: (context, state) => const UploadDocumentsScreen(
          role: MerchantRole.supplier,
          standalone: true,
        ),
      ),
      GoRoute(
        path: '/profile/become-seller/business-info',
        name: 'becomeSellerBusinessInfo',
        builder: (context, state) => const BusinessInfoScreen(
          role: MerchantRole.supplier,
          standalone: true,
        ),
      ),
      GoRoute(
        path: '/sample-gate',
        name: 'sampleGate',
        builder: (context, state) => const SampleGateScreen(),
      ),
      GoRoute(
        path: '/co-buying',
        name: 'coBuying',
        builder: (context, state) => const CoBuyingScreen(),
      ),
      GoRoute(
        path: '/co-buying/:id',
        name: 'coBuyDetail',
        builder: (context, state) =>
            CoBuyDetailScreen(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat',
        name: 'chatList',
        builder: (context, state) => const ChatPolicyGate(child: ChatScreen()),
      ),
      GoRoute(
        path: '/live-chat',
        name: 'liveChat',
        builder: (context, state) =>
            const ChatPolicyGate(child: LiveChatScreen()),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chatDetail',

        builder: (context, state) => ChatPolicyGate(
          child: ChatDetailScreen(conversationId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/escrow',
        name: 'escrow',
        builder: (context, state) => const EscrowScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetail',
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        name: 'deliveryTracking',
        builder: (context, state) =>
            DeliveryTrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/store',
        name: 'storeProfile',
        builder: (context, state) =>
            StoreProfileScreen(sellerName: state.extra as String),
      ),
      GoRoute(
        path: '/checkout/add-address',
        name: 'addAddress',
        builder: (context, state) =>
            AddAddressScreen(selectionMode: state.extra as bool? ?? false),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/address-book',
        name: 'addressBook',
        builder: (context, state) =>
            AddressBookScreen(selectionMode: state.extra as bool? ?? false),
      ),
      GoRoute(
        path: '/profile/payment-currency',
        name: 'paymentCurrency',
        builder: (context, state) => const PaymentCurrencyScreen(),
      ),
      GoRoute(
        path: '/profile/language',
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/profile/help-support',
        name: 'helpSupport',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/profile/help-support/faq',
        name: 'faqCategory',
        builder: (context, state) {
          final extra = state.extra as Map;
          return FaqDetailScreen(
            categoryId: extra['id'] as FaqCategoryId,
            title: extra['title'] as String,
          );
        },
      ),
      GoRoute(
        path: '/profile/report-issue',
        name: 'reportIssue',
        builder: (context, state) => const ReportIssueScreen(),
      ),
      GoRoute(
        path: '/profile/terms-conditions',
        name: 'termsConditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/profile/privacy-policy',
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return CheckoutScreen(
              items: (extra['items'] as List?)?.cast<CheckoutLineItem>(),
            );
          }
          return const CheckoutScreen();
        },
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return PaymentScreen(
              amount: extra['amount'] as double,
              itemCount: extra['itemCount'] as int,
              items:
                  (extra['items'] as List?)?.cast<OrderLineSummary>() ??
                  const [],
            );
          }
          return PaymentScreen(amount: extra as double);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace',
                name: 'marketplace',
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'category',
                    name: 'categoryResults',
                    builder: (context, state) => CategoryResultsScreen(
                      category: state.extra as Category? ?? kCategories.first,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                name: 'wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
