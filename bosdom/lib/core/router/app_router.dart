import 'package:go_router/go_router.dart';

import '../../features/co_buying/screens/co_buy_create_screen.dart';
import '../../features/co_buying/screens/co_buy_detail_screen.dart';
import '../../features/co_buying/screens/co_buy_seller_deals_screen.dart';
import '../../features/co_buying/screens/co_buying_screen.dart';
import '../../features/auth/models/merchant_role.dart';
import '../config/supabase_config.dart';
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
import '../../features/profile/screens/add_listing_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/faq_detail_screen.dart';
import '../../features/profile/screens/add_store_address_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/language_screen.dart';
import '../../features/profile/screens/my_inventory_screen.dart';
import '../../features/profile/screens/payment_currency_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/report_issue_screen.dart';
import '../../features/profile/screens/seller_dashboard_screen.dart';
import '../../features/profile/screens/seller_earnings_screen.dart';
import '../../features/profile/screens/seller_order_detail_screen.dart';
import '../../features/profile/screens/seller_orders_screen.dart';
import '../../features/profile/screens/shop_profile_screen.dart';
import '../../features/profile/screens/store_address_book_screen.dart';
import '../../features/profile/screens/terms_conditions_screen.dart';
import '../../features/sample_gate/screens/sample_gate_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/wishlist/screens/wishlist_screen.dart';
import 'app_shell.dart';

abstract final class AppRouter {
  // Google sign-in's redirect lands here as a platform deep link, which
  // go_router also receives as a navigation target. It carries no route of
  // its own — supabase_flutter's separate deep-link listener is what
  // exchanges the code for a session — so send it to splash instead of
  // letting go_router 404 on it.
  static final _oauthCallbackScheme = Uri.parse(
    SupabaseConfig.googleAuthRedirectUri,
  ).scheme;

  // Custom-scheme fallback for share links (e.g. "bosdom://co-buying/rice-50kg")
  // used until Universal/App Links (applinks:bosdom.app, see
  // ios/Runner/Runner.entitlements and the AndroidManifest App Links
  // intent-filter) are verifiable via hosted apple-app-site-association /
  // assetlinks.json files. A custom scheme has no path of its own to match
  // against the route table — everything after "scheme://" is parsed as the
  // authority (host) rather than the path — so this rebuilds the in-app path
  // from the host + path segments before handing it to go_router.
  static const _shareLinkScheme = 'bosdom';

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (state.uri.scheme == _oauthCallbackScheme) return '/splash';
      if (state.uri.scheme == _shareLinkScheme) {
        final segments = [
          if (state.uri.host.isNotEmpty) state.uri.host,
          ...state.uri.pathSegments,
        ];
        if (segments.isEmpty) return '/marketplace';
        final query = state.uri.hasQuery ? '?${state.uri.query}' : '';
        return '/${segments.join('/')}$query';
      }
      return null;
    },
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
        path: '/co-buying/create',
        name: 'coBuyCreate',
        builder: (context, state) =>
            CoBuyCreateScreen(editSessionId: state.extra as String?),
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
        builder: (context, state) => ChatPolicyGate(
          child: ChatScreen(
            sellerMode: state.uri.queryParameters['seller'] == 'true',
          ),
        ),
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
        path: '/profile/co-buy-deals',
        name: 'coBuyDeals',
        builder: (context, state) => const CoBuySellerDealsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/seller-dashboard',
        name: 'sellerDashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/profile/shop-profile',
        name: 'shopProfile',
        builder: (context, state) => const ShopProfileScreen(),
      ),
      GoRoute(
        path: '/profile/add-listing',
        name: 'addListing',
        builder: (context, state) => const AddListingScreen(),
      ),
      GoRoute(
        path: '/profile/my-inventory',
        name: 'myInventory',
        builder: (context, state) => const MyInventoryScreen(),
      ),
      GoRoute(
        path: '/profile/seller-orders',
        name: 'sellerOrders',
        builder: (context, state) => const SellerOrdersScreen(),
      ),
      GoRoute(
        path: '/profile/seller-orders/:id',
        name: 'sellerOrderDetail',
        builder: (context, state) =>
            SellerOrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/seller-earnings',
        name: 'sellerEarnings',
        builder: (context, state) => const SellerEarningsScreen(),
      ),
      GoRoute(
        path: '/profile/address-book',
        name: 'addressBook',
        builder: (context, state) =>
            AddressBookScreen(selectionMode: state.extra as bool? ?? false),
      ),
      GoRoute(
        path: '/profile/store-addresses',
        name: 'storeAddressBook',
        builder: (context, state) => const StoreAddressBookScreen(),
      ),
      GoRoute(
        path: '/profile/store-addresses/add',
        name: 'addStoreAddress',
        builder: (context, state) => const AddStoreAddressScreen(),
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
              shippingName: extra['shippingName'] as String? ?? '',
              shippingAddress: extra['shippingAddress'] as String? ?? '',
              shippingPhone: extra['shippingPhone'] as String? ?? '',
              coBuyPoolId: extra['coBuyPoolId'] as String?,
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
