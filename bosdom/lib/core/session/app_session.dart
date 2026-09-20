import 'package:flutter/foundation.dart';

/// Bumped after sign-out to force the root `ProviderScope` to rebuild with a
/// fresh key, discarding every provider's cached state. Without this, a
/// different account signing in after logout would keep showing the
/// previous account's cart/orders/chat/etc. data until a manual
/// pull-to-refresh on every screen.
final appSessionEpoch = ValueNotifier<int>(0);
