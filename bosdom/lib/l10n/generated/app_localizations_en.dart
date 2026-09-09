// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BosDom';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaveChanges => 'Save Changes';

  @override
  String get commonSaved => 'Saved';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDone => 'Done';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSeeAll => 'See All';

  @override
  String commonComingSoon(String label) {
    return '$label coming soon';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navCart => 'Cart';

  @override
  String get navAccount => 'Account';

  @override
  String get languageScreenTitle => 'Language';

  @override
  String get languageScreenIntro =>
      'Choose your preferred language for the Bosdom app.';

  @override
  String get languageSectionLabel => 'SELECT LANGUAGE';

  @override
  String get languageEnglishLabel => 'English';

  @override
  String get languageEnglishSublabel => 'Default language';

  @override
  String get languageKhmerLabel => 'ភាសាខ្មែរ (Khmer)';

  @override
  String get languageKhmerSublabel => 'Cambodian language';

  @override
  String get languageNoteTitle => 'Please Note';

  @override
  String get languageNoteBody =>
      'Changing the language will restart the app interface. Some supplier content may remain in its original language.';

  @override
  String languageSavedSnackbar(String language) {
    return 'Language set to $language';
  }

  @override
  String get authLoginEmailLabel => 'EMAIL';

  @override
  String get authLoginEmailHint => 'you@example.com';

  @override
  String get authLoginPasswordLabel => 'PASSWORD';

  @override
  String get authLoginPasswordHint => 'Enter password';

  @override
  String get authLoginForgotPassword => 'Forgot Password?';

  @override
  String get authLoginPasswordResetComingSoon => 'Password reset coming soon';

  @override
  String get authLoginSignInButton => 'Sign In';

  @override
  String get authLoginOrSignUpWith => 'Or Sign Up with';

  @override
  String get authLoginGoogleButton => 'Google';

  @override
  String get authLoginNewMerchantPrompt => 'New merchant? ';

  @override
  String get authLoginCreateAccount => 'Create Account';

  @override
  String get authLoginWelcomeTitle => 'Welcome back\nMerchant';

  @override
  String get authLoginSubtitle => 'Sign in to your wholesale account';

  @override
  String get authSignupJoiningPrompt => 'I am joining BosDom as a...';

  @override
  String get authSignupChooseRoleTitle => 'Choose Your Role';

  @override
  String authSignupStepLabel(String total) {
    return 'Step 1 of $total';
  }

  @override
  String get authBusinessInfoTitle => 'Business Info';

  @override
  String authBusinessInfoStepLabel(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get authBusinessInfoShopNameLabel => 'SHOP / BUSINESS NAME';

  @override
  String get authBusinessInfoShopNameHint => 'e.g. Angkor Wholesale Co.';

  @override
  String get authBusinessInfoStoreTypeLabel => 'TYPE OF STORE';

  @override
  String get authBusinessInfoStoreTypeHint => 'Select a type';

  @override
  String get authBusinessInfoStoreTypePhysical => 'Physical Store';

  @override
  String get authBusinessInfoStoreTypeOnline => 'Online Store';

  @override
  String get authBusinessInfoStoreTypeBoth => 'Both Physical & Online';

  @override
  String get authBusinessInfoStorePhotosLabel => 'STORE PHOTOS';

  @override
  String get authBusinessInfoPhotosUploadTitle => 'Tap to upload store photos';

  @override
  String get authBusinessInfoPhotosUploadSubtitle =>
      '(Physical store or online store screenshots)';

  @override
  String get authBusinessInfoStoreUrlLabel => 'ONLINE STORE URL (OPTIONAL)';

  @override
  String get authBusinessInfoStoreUrlHint => 'e.g. facebook.com/yourshop';

  @override
  String get authBusinessInfoProvinceLabel => 'PROVINCE / CITY';

  @override
  String get authBusinessInfoProvinceHint => 'Select province...';

  @override
  String get authBusinessInfoProvincePhnomPenh => 'Phnom Penh';

  @override
  String get authBusinessInfoProvinceKandal => 'Kandal';

  @override
  String get authBusinessInfoProvinceSiemReap => 'Siem Reap';

  @override
  String get authBusinessInfoProvinceBattambang => 'Battambang';

  @override
  String get authBusinessInfoProvinceKampongCham => 'Kampong Cham';

  @override
  String get authBusinessInfoProvincePreahSihanouk => 'Preah Sihanouk';

  @override
  String get authBusinessInfoDistrictLabel => 'DISTRICT / SANGKAT';

  @override
  String get authBusinessInfoDistrictHint => 'Select district...';

  @override
  String get authBusinessInfoDistrictChamkarmon => 'Khan Chamkarmon';

  @override
  String get authBusinessInfoDistrictToulKork => 'Khan Toul Kork';

  @override
  String get authBusinessInfoDistrictSenSok => 'Khan Sen Sok';

  @override
  String get authBusinessInfoDistrictBoengKengKang => 'Khan Boeng Keng Kang';

  @override
  String get authBusinessInfoDistrictOther => 'Other';

  @override
  String get authBusinessInfoStreetAddressLabel => 'STREET ADDRESS';

  @override
  String get authBusinessInfoStreetAddressHint => 'e.g. Street 271, Phnom Penh';

  @override
  String get authBusinessInfoAgreementPrefix => 'I agree to BosDom\'s ';

  @override
  String get authBusinessInfoAgreementTermsLink => 'Terms of Service';

  @override
  String get authBusinessInfoAgreementSuffix =>
      ' and confirm I am a registered business merchant in Cambodia.';

  @override
  String get authBusinessInfoSellerBadgePrefix => 'Your ';

  @override
  String get authBusinessInfoSellerBadgeLink => 'Seller badge';

  @override
  String get authBusinessInfoSellerBadgeSuffix =>
      ' activates immediately. You can start listing products right away!';

  @override
  String get authBusinessInfoCreateAccountButton => 'Create my Account';

  @override
  String get authDeliveryAddressStepTitle => 'Personal Details';

  @override
  String authDeliveryAddressStepLabel(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get authDeliveryAddressIntroTitle => 'Your Delivery Address';

  @override
  String get authDeliveryAddressIntroBody =>
      'Enter your delivery address below.';

  @override
  String get authDeliveryAddressHouseLabel => 'HOUSE / STREET NUMBER';

  @override
  String get authDeliveryAddressHouseHint => 'e.g. #12, Street 271';

  @override
  String get authDeliveryAddressSangkatLabel => 'SANGKAT / DISTRICT';

  @override
  String get authDeliveryAddressSangkatHint => 'e.g. Sangkat Tomnob Tuek';

  @override
  String get authDeliveryAddressProvinceLabel => 'PROVINCE / CITY';

  @override
  String get authDeliveryAddressProvinceHint => 'Select province...';

  @override
  String get authDeliveryAddressProvincePhnomPenh => 'Phnom Penh';

  @override
  String get authDeliveryAddressProvinceKandal => 'Kandal';

  @override
  String get authDeliveryAddressProvinceSiemReap => 'Siem Reap';

  @override
  String get authDeliveryAddressProvinceBattambang => 'Battambang';

  @override
  String get authDeliveryAddressProvinceKampongCham => 'Kampong Cham';

  @override
  String get authDeliveryAddressProvincePreahSihanouk => 'Preah Sihanouk';

  @override
  String get authDeliveryAddressLandmarkLabel => 'NEAREST LANDMARK (OPTIONAL)';

  @override
  String get authDeliveryAddressLandmarkHint => 'e.g. Near Lucky Mall';

  @override
  String get authDeliveryAddressAgreementPrefix => 'I agree to BosDom\'s ';

  @override
  String get authDeliveryAddressAgreementTermsLink => 'Terms of Service';

  @override
  String get authDeliveryAddressAgreementSuffix =>
      ' and confirm I am a merchant in Cambodia.';

  @override
  String get authDeliveryAddressVerificationPrefix =>
      'You can start browsing and buying immediately. Optionally upload your business ID later in ';

  @override
  String get authDeliveryAddressVerificationProfileLink =>
      'Profile → Verification';

  @override
  String get authDeliveryAddressVerificationMiddle => ' to unlock the ';

  @override
  String get authDeliveryAddressVerificationBadgeLink => 'Verified Buyer';

  @override
  String get authDeliveryAddressVerificationSuffix => ' badge.';

  @override
  String get authDeliveryAddressCreateAccountButton => 'Create My Account';

  @override
  String get authPersonalDetailsTitle => 'Personal Details';

  @override
  String authPersonalDetailsStepLabel(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get authPersonalDetailsFullNameLabel => 'FULL NAME';

  @override
  String get authPersonalDetailsFullNameHint => 'Your full name';

  @override
  String get authPersonalDetailsPhoneLabel => 'PHONE NUMBER (+855)';

  @override
  String get authPersonalDetailsPhoneHint => '012 345 678';

  @override
  String get authPersonalDetailsEmailLabel => 'EMAIL (OPTIONAL)';

  @override
  String get authPersonalDetailsEmailHint => 'you@example.com';

  @override
  String get authPersonalDetailsPasswordLabel => 'PASSWORD';

  @override
  String get authPersonalDetailsPasswordHint => 'Create a password';

  @override
  String get authPersonalDetailsConfirmPasswordLabel => 'CONFIRM PASSWORD';

  @override
  String get authPersonalDetailsConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authUploadDocumentsTitle => 'Upload Documents';

  @override
  String authUploadDocumentsStepLabel(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get authUploadDocumentsIdentityBannerTitle => 'Identity Verification';

  @override
  String get authUploadDocumentsIdentityBannerBody =>
      'Upload your ID for identity on file. Your Seller badge activates immediately no admin confirmation needed.';

  @override
  String get authUploadDocumentsNationalIdTitle => 'National ID Card';

  @override
  String get authUploadDocumentsNationalIdSubtitle =>
      'Front and back of your Cambodian National ID';

  @override
  String get authUploadDocumentsPassportTitle => 'Passport';

  @override
  String get authUploadDocumentsPassportSubtitle =>
      'Alternative to National ID (optional)';

  @override
  String get authUploadDocumentsBusinessCertTitle => 'Business Certificate';

  @override
  String get authUploadDocumentsBusinessCertSubtitle =>
      'MOC registration certificate (optional but speeds up verification)';

  @override
  String get authUploadDocumentsRequiredMarker => ' *';

  @override
  String get authUploadDocumentsOptionalMarker => ' (optional)';

  @override
  String get authUploadDocumentsUploadedLabel => 'Uploaded';

  @override
  String get authUploadDocumentsTapToUploadLabel => 'Tap to Upload';

  @override
  String get splashTagline => 'Cambodia\'s Trusted\nWholesale Network';

  @override
  String get splashBadgeVerified => 'Verified';

  @override
  String get splashBadgeSecure => 'Secure';

  @override
  String get splashBadgeWholesale => 'Wholesale';

  @override
  String get splashGetStartedButton => 'Get Started';

  @override
  String get splashLoginPrompt => 'Already have an account? Log in';

  @override
  String get splashFooterNote => 'For registered Cambodian merchants only';

  @override
  String get sampleGateTitle => 'Buy sample';

  @override
  String get sampleGateBody =>
      '1-per-account sample purchase flow. UI comes in phase 4';

  @override
  String cartMovedToWishlistSnackbar(String productName) {
    return '$productName moved to wishlist';
  }

  @override
  String get cartProceedToCheckout => 'Proceed to Checkout';

  @override
  String get cartScreenTitle => 'My Cart';

  @override
  String get cartSelectAll => 'Select All';

  @override
  String cartItemsCount(int count) {
    return '$count items';
  }

  @override
  String get cartWishlistAction => 'Wishlist';

  @override
  String cartUnitPrice(String price) {
    return 'Unit: $price';
  }

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartEstimatedShipping => 'Estimated Shipping';

  @override
  String get cartEscrowFee => 'Escrow Fee (2%)';

  @override
  String get cartTotalAmount => 'Total Amount';

  @override
  String get cartEmptyState => 'Your cart is empty';

  @override
  String get checkoutDeliveryAddressLabel => 'Delivery Address';

  @override
  String get checkoutOrderItemsLabel => 'Order Items';

  @override
  String checkoutItemsCount(int count) {
    return '$count Items';
  }

  @override
  String get checkoutShippingMethodLabel => 'Shipping Method';

  @override
  String get checkoutShippingUnavailableLabel =>
      'Not available for this weight/address';

  @override
  String get checkoutEscrowNotice =>
      'Funds held in escrow until delivery confirmed.';

  @override
  String get checkoutContinueToPayment => 'Continue to Payment';

  @override
  String get checkoutScreenTitle => 'Checkout';

  @override
  String get checkoutNoAddressYet => 'No delivery address yet';

  @override
  String get checkoutChangeAddress => 'Change';

  @override
  String get checkoutOrderSummaryTitle => 'Order Summary';

  @override
  String get checkoutSubtotal => 'Subtotal';

  @override
  String get checkoutShippingLabel => 'Shipping';

  @override
  String get checkoutEscrowFeeLabel => 'Escrow Fee (2%)';

  @override
  String get checkoutTotalAmount => 'Total Amount';

  @override
  String get checkoutStepCart => 'Cart';

  @override
  String get checkoutStepCheckout => 'Checkout';

  @override
  String get checkoutStepPayment => 'Payment';

  @override
  String get addressLabelFieldLabel => 'ADDRESS LABEL';

  @override
  String get addressLabelFieldHint => 'e.g. Home, Warehouse, Shop';

  @override
  String get addressHouseFieldLabel => 'HOUSE / STREET NUMBER';

  @override
  String get addressHouseFieldHint =>
      'e.g. Building B, Zone 3, Veng Sreng Blvd';

  @override
  String get addressSangkatFieldLabel => 'SANGKAT / DISTRICT';

  @override
  String get addressSangkatFieldHint => 'e.g. Sangkat Choam Chao';

  @override
  String get addressLandmarkFieldLabel => 'NEAREST LANDMARK (OPTIONAL)';

  @override
  String get addressLandmarkFieldHint => 'e.g. Next to Veng Sreng Canopy';

  @override
  String get addressPhoneFieldLabel => 'CONTACT PHONE NUMBER';

  @override
  String get addressPhoneFieldHint => 'e.g. +855 76 227 5858';

  @override
  String get addressProvinceFieldLabel => 'PROVINCE / CITY';

  @override
  String get addressProvinceFieldHint => 'Select province...';

  @override
  String get addressFieldRequiredError => 'Required';

  @override
  String get addressSetDefaultTitle => 'Set as Default Address';

  @override
  String get addressSetDefaultSubtitle => 'Deliver all primary orders here';

  @override
  String get addressSaveButton => 'Save Address';

  @override
  String get addressAddScreenTitle => 'Add Address';

  @override
  String get addressBookSelectionSubtitle => 'Tap an address to deliver here';

  @override
  String get addressAddNewButton => 'Add New Address';

  @override
  String get addressBookScreenTitle => 'Address Book';

  @override
  String get addressDefaultBadge => 'Default';

  @override
  String get storeAddressBookScreenTitle => 'Store Addresses';

  @override
  String get storeAddressAddNewButton => 'Add New Store Address';

  @override
  String get storeAddressAddScreenTitle => 'Add Store Address';

  @override
  String get storeAddressLabelFieldLabel => 'ADDRESS LABEL';

  @override
  String get storeAddressLabelFieldHint => 'e.g. Phnom Penh Headquarters';

  @override
  String get storeAddressNameFieldLabel => 'STORE / BUSINESS NAME';

  @override
  String get storeAddressNameFieldHint => 'e.g. Angkor Artisans Store';

  @override
  String get storeAddressBusinessTypeFieldLabel => 'BUSINESS TYPE';

  @override
  String get storeAddressBusinessTypeFieldHint =>
      'e.g. Wholesale & Manufacturer';

  @override
  String get storeAddressFullAddressFieldLabel => 'FULL ADDRESS';

  @override
  String get storeAddressFullAddressFieldHint =>
      'e.g. No. 124, Street 271, Sangkat Boeung Salang';

  @override
  String get storeAddressDistrictFieldLabel => 'SANGKAT / DISTRICT';

  @override
  String get storeAddressDistrictFieldHint => 'e.g. Sangkat Teuk Thla';

  @override
  String get storeAddressProvinceFieldLabel => 'PROVINCE / CITY';

  @override
  String get storeAddressProvinceFieldHint => 'e.g. Phnom Penh';

  @override
  String get storeAddressPhoneFieldLabel => 'CONTACT PHONE NUMBER';

  @override
  String get storeAddressPhoneFieldHint => 'e.g. +855 76 227 5858';

  @override
  String get storeAddressEmailFieldLabel => 'CONTACT EMAIL';

  @override
  String get storeAddressEmailFieldHint => 'e.g. orders@angkorartisans.com';

  @override
  String get storeAddressHoursFieldLabel => 'OPERATING HOURS';

  @override
  String get storeAddressHoursFieldHint => 'e.g. Mon - Fri: 8:00 AM - 5:30 PM';

  @override
  String get storeAddressFieldRequiredError => 'Required';

  @override
  String get storeAddressEmailInvalidError => 'Enter a valid email';

  @override
  String get storeAddressSetDefaultTitle => 'Set as Default Store Address';

  @override
  String get storeAddressSetDefaultSubtitle =>
      'Ship and dispatch all primary orders from here';

  @override
  String get storeAddressSaveButton => 'Save Store Address';

  @override
  String get storeAddressDefaultBadge => 'Default';

  @override
  String get storeAddressEmptyState =>
      'No store addresses yet. Add one to start shipping from a fixed location.';

  @override
  String get chatScreenTitle => 'Chat';

  @override
  String get chatSearchHint => 'Search conversations...';

  @override
  String get chatEmptyTitle => 'No conversations yet';

  @override
  String chatEmptyQuery(String query) {
    return 'No conversations match \"$query\"';
  }

  @override
  String get chatLoadError => 'Couldn\'t load conversations';

  @override
  String get chatDetailLoadError => 'Couldn\'t load this conversation';

  @override
  String get chatMessageSending => 'Sending...';

  @override
  String get chatSendError => 'Couldn\'t send message. Try again.';

  @override
  String get chatStartConversationError =>
      'Couldn\'t start the conversation. Try again.';

  @override
  String chatRestrictedError(String until) {
    return 'You\'re temporarily restricted from sending messages until $until.';
  }

  @override
  String get chatPolicySecurePayTitle => 'Pay only through Bosdom Secure Pay';

  @override
  String get chatPolicyBannerBody =>
      'Direct payments to the seller outside the app aren\'t covered by Bosdom\'s buyer protection. Keep transactions in Secure Pay to stay protected.';

  @override
  String get chatFlaggedBadge => 'Off-platform contact flagged';

  @override
  String get chatOffPlatformWarning =>
      'This message may share contact info or arrange a deal outside Bosdom: you won\'t be covered by buyer protection.';

  @override
  String get chatPhotoAttachmentComingSoon => 'Photo attachment coming soon';

  @override
  String get chatComposerHint => 'Type a message...';

  @override
  String get chatAttachPhotoCamera => 'Take a photo';

  @override
  String get chatAttachPhotoGallery => 'Choose from gallery';

  @override
  String get liveChatTitle => 'Live Chat';

  @override
  String get liveChatStatusOnline => 'Online • Usually replies instantly';

  @override
  String get liveChatStatusOffline =>
      'Offline • We\'ll reply as soon as we\'re back';

  @override
  String get liveChatSecurityNoticeTitle => 'Security Notice';

  @override
  String get liveChatSecurityNoticeBody =>
      'Only make payments via Bosdom\'s official secure portal. Support will never ask for direct bank transfers in chat.';

  @override
  String get liveChatSuggestedTopicsLabel => 'Suggested topics';

  @override
  String get liveChatTopicOrderStatus => 'Order Status';

  @override
  String get liveChatTopicOrderStatusMessage =>
      'Hi, I\'d like an update on my order status.';

  @override
  String get liveChatTopicPaymentIssue => 'Payment Issue';

  @override
  String get liveChatTopicPaymentIssueMessage =>
      'Hi, I\'m having an issue with a payment.';

  @override
  String get liveChatTopicRefundReturn => 'Refund / Return';

  @override
  String get liveChatTopicRefundReturnMessage =>
      'Hi, I\'d like to request a refund or return.';

  @override
  String get liveChatTopicShippingRates => 'Shipping Rates';

  @override
  String get liveChatTopicShippingRatesMessage =>
      'Hi, can you tell me more about your shipping rates?';

  @override
  String chatPolicyLoadError(String error) {
    return 'Couldn\'t load chat settings: $error';
  }

  @override
  String get chatPolicyIntro =>
      'Before you start chatting with buyers and sellers on Bosdom, please read and accept the terms below.';

  @override
  String get chatPolicySecurePayBody =>
      'Payments made outside the app are not covered by Bosdom\'s buyer protection or dispute resolution.';

  @override
  String get chatPolicyFlaggedTitle => 'Off-platform deals are flagged';

  @override
  String get chatPolicyFlaggedBody =>
      'Messages sharing phone numbers or third-party contact apps are automatically flagged for review.';

  @override
  String get chatPolicyLiableTitle => 'You are liable for what you send';

  @override
  String get chatPolicyLiableBody =>
      'Bosdom is not responsible for losses from deals arranged outside the platform or against these terms.';

  @override
  String get chatPolicyHeaderTitle => 'Chat & Trading Policy';

  @override
  String get chatPolicyAgreementText =>
      'I have read and agree to the Bosdom Chat Policy and Terms of Service.';

  @override
  String get chatPolicyContinueButton => 'Continue to Chat';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsScreenTitle => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'You\'re all caught up';

  @override
  String get notificationsLoadError => 'Couldn\'t load notifications';

  @override
  String get notificationsPushTitle => 'Push notification';

  @override
  String get notificationsPushBody =>
      'Be the first to hear about: weekly sales, exclusive offers, hot promotions and more';

  @override
  String get dataPrivacyContactBanner => 'Get in touch to manage your data';

  @override
  String get dataPrivacyBody =>
      'Request access, correction, or deletion of your personal data. Contact our privacy team for any data-related inquiries.';

  @override
  String get dataPrivacyContactButton => 'Contact Privacy Team';

  @override
  String dataPrivacyLaunchError(String email) {
    return 'Couldn\'t open your email app; copied $email to your clipboard instead';
  }

  @override
  String get marketingEmailsToggleTitle => 'Receive marketing emails';

  @override
  String get marketingEmailsBody =>
      'I give Bosdom consent to send marketing emails including promotions, new supplier announcements, co-buy deals, and product recommendations tailored to my business needs.';

  @override
  String get marketingEmailsFinePrint =>
      'You can withdraw your consent at anytime. If you withdraw your consent, it will not affect the legality of data processed before. We process your data in line with our Privacy Policy.';

  @override
  String get marketingEmailsSaveError =>
      'Couldn\'t save your marketing email preference. Please try again.';

  @override
  String get personalizedAdsAllowTitle => 'Allow personalized ads';

  @override
  String get personalizedAdsBody =>
      'We use your browsing data and purchase history to show you relevant product recommendations and ads. You can opt out anytime; you will still see ads, but they won\'t be tailored to your interests.';

  @override
  String get personalizedAdsBrowsingTitle => 'Browsing data';

  @override
  String get personalizedAdsBrowsingBody =>
      'Pages and products you view in the app';

  @override
  String get personalizedAdsPurchaseTitle => 'Purchase history';

  @override
  String get personalizedAdsPurchaseBody =>
      'Items you have bought or added to cart';

  @override
  String get personalizedAdsAcceptAll => 'Accept All';

  @override
  String get personalizedAdsAdjustPreferences => 'Adjust Preferences';

  @override
  String get personalizedAdsHidePreferences => 'Hide Preferences';

  @override
  String get personalizedAdsSavePreferences => 'Save Preferences';

  @override
  String get personalizedAdsSaveError =>
      'Couldn\'t save your ad preferences. Please try again.';

  @override
  String get coBuyingScreenTitle => 'Co-Buy';

  @override
  String get coBuyingInfoBanner =>
      'Pool orders with nearby retailers to unlock bulk wholesale discounts. Share invite links to grow your group!';

  @override
  String get coBuyingSectionTitle => 'Active Co-Buy Sessions';

  @override
  String get coBuyingMomentumReady => 'Target reached, ready for checkout';

  @override
  String get coBuyingMomentumAlmost => 'Almost unlocked, grab it soon';

  @override
  String get coBuyingMomentumFilling => 'Filling up fast';

  @override
  String get coBuyingMomentumNew => 'Newly opened, be an early buyer';

  @override
  String coBuyingPooledProgress(
    int currentQty,
    int targetQty,
    String unitLabel,
  ) {
    return '$currentQty/$targetQty $unitLabel pooled';
  }

  @override
  String coBuyingRemainingToUnlock(int remainingQty, String unitLabel) {
    return 'Just $remainingQty $unitLabel left to unlock the group price';
  }

  @override
  String get coBuyingGroupPriceLabel => 'GROUP PRICE';

  @override
  String coBuyingYouSave(String amount) {
    return 'You save $amount';
  }

  @override
  String get coBuyingJoinedPillLabel =>
      'You\'re in this group buy · tap to leave';

  @override
  String get coBuyingCheckoutReadyLabel => 'Ready for checkout';

  @override
  String get coBuyingFullLabel => 'Co-Buy Full';

  @override
  String get coBuyingJoinButtonLabel => 'Join This Co-Buy';

  @override
  String coBuyingShareText(
    String productName,
    String price,
    String savingsPct,
    String url,
  ) {
    return 'Join me on this Co-Buy for $productName on BosDom! Get it for $price ($savingsPct% off).\n\n$url';
  }

  @override
  String coBuyingShareSubject(String productName) {
    return 'Co-Buy: $productName';
  }

  @override
  String get coBuyingLoadError => 'Couldn\'t load co-buy deals. Tap to retry.';

  @override
  String get coBuyingEmptyMessage => 'No co-buy deals yet. Check back soon!';

  @override
  String get coBuyDealsLoadError =>
      'Couldn\'t load your co-buy deals. Tap to retry.';

  @override
  String get coBuyCreateScreenTitle => 'Start a Co-Buy';

  @override
  String get coBuyCreateEditScreenTitle => 'Edit Co-Buy Deal';

  @override
  String get coBuyCreateProductNameLabel => 'Product Name';

  @override
  String get coBuyCreateProductNameHint => 'e.g. Jasmine Rice Premium 50kg';

  @override
  String get coBuyCreateProductNameRequired => 'Product name is required';

  @override
  String get coBuyCreatePriceLabel => 'Co-Buy Price (USD)';

  @override
  String get coBuyCreatePriceRequired => 'Co-buy price is required';

  @override
  String get coBuyCreatePriceInvalid => 'Enter a valid price';

  @override
  String get coBuyCreateOriginalPriceLabel => 'Original Price (USD)';

  @override
  String get coBuyCreateOriginalPriceRequired => 'Original price is required';

  @override
  String get coBuyCreateOriginalPriceInvalid =>
      'Original price must be higher than the co-buy price';

  @override
  String get coBuyCreateTargetQtyLabel => 'Target Retailers';

  @override
  String get coBuyCreateTargetQtyHint => 'e.g. 20';

  @override
  String get coBuyCreateTargetQtyRequired => 'Target retailers is required';

  @override
  String get coBuyCreateTargetQtyInvalid => 'Enter a valid number';

  @override
  String get coBuyCreateUnitLabelLabel => 'Unit';

  @override
  String get coBuyCreateUnitLabelHint => 'e.g. kg, packs, units';

  @override
  String get coBuyCreateUnitLabelRequired => 'Unit is required';

  @override
  String get coBuyCreateMinOrderQtyLabel => 'Minimum Order';

  @override
  String get coBuyCreateMinOrderQtyHint => 'e.g. 500 kg';

  @override
  String get coBuyCreateMinOrderQtyRequired => 'Minimum order is required';

  @override
  String get coBuyCreateMinOrderQtyInvalid => 'Enter a valid quantity';

  @override
  String get coBuyCreateDurationLabel => 'Deal Duration';

  @override
  String get coBuyCreateDuration1Day => '1 day';

  @override
  String get coBuyCreateDuration2Days => '2 days';

  @override
  String get coBuyCreateDuration3Days => '3 days';

  @override
  String get coBuyCreateDuration5Days => '5 days';

  @override
  String get coBuyCreateDuration1Week => '1 week';

  @override
  String get coBuyCreateButton => 'Launch Co-Buy';

  @override
  String get coBuyCreateCreatedSnackbar =>
      'Co-Buy created! Invite others to join.';

  @override
  String get coBuyCreateUpdatedSnackbar => 'Co-buy deal updated';

  @override
  String get coBuyCreateSaveError =>
      'Couldn\'t save this co-buy deal. Please try again.';

  @override
  String get coBuyCreateProductInfoSectionTitle => 'Product Information';

  @override
  String get coBuyCreatePricingSectionTitle => 'Pricing & Quantity';

  @override
  String get coBuyCreateDealSettingsSectionTitle => 'Deal Settings';

  @override
  String get coBuyCreatePhotosLabel => 'Product Photos';

  @override
  String get coBuyCreatePhotoLabel => 'Tap to add cover photo';

  @override
  String get coBuyCreatePhotoHint => 'Recommended 512×512px JPG or PNG';

  @override
  String get coBuyCreatePhotosHelper =>
      'Add up to 4 photos. The first photo is the cover.';

  @override
  String get coBuyCreateDescriptionLabel => 'Product Description';

  @override
  String get coBuyCreateDescriptionHint => 'Describe the product for retailers';

  @override
  String get coBuyCreateAutoRenewLabel => 'Auto-renew when expired';

  @override
  String get coBuyDealsWelcomeMessage =>
      'Welcome back! Here is your co-buy performance summary today.';

  @override
  String get coBuyDealsShopNamePlaceholder => 'My Shop';

  @override
  String get coBuyDealsAutoRenewBadge => 'Auto-renews';

  @override
  String get coBuyDealsActiveDealsLabel => 'Active Deals';

  @override
  String get coBuyDealsJoinedLabel => 'Joined';

  @override
  String get coBuyDealsRevenueLabel => 'Revenue';

  @override
  String get coBuyDealsCreateButtonLabel => 'Create New Co-Buy Deal';

  @override
  String get coBuyDealsListingsSectionTitle => 'Your Co-Buy Listings';

  @override
  String coBuyDealsMinTargetLabel(int targetQty, String unitLabel) {
    return 'Min wholesale target: $targetQty $unitLabel';
  }

  @override
  String get coBuyDealsStatusActive => 'Active';

  @override
  String get coBuyDealsStatusCompleted => 'Completed';

  @override
  String get coBuyDealsStatusExpired => 'Expired';

  @override
  String get coBuyDealsProgressLabel => 'Progress';

  @override
  String coBuyDealsRetailersLabel(int count) {
    return '$count retailers';
  }

  @override
  String get coBuyDealsStatusEndedLabel => 'Ended';

  @override
  String get coBuyDealsEndsSoonLabel => 'Ends soon';

  @override
  String get coBuyDealsOriginalLabel => 'Original';

  @override
  String get coBuyDealsCoBuyPriceLabel => 'Co-buy price';

  @override
  String get coBuyDealsDeleteConfirmTitle => 'Delete Co-Buy Deal?';

  @override
  String coBuyDealsDeleteConfirmBody(String productName) {
    return '$productName and its retailer progress will be permanently removed.';
  }

  @override
  String get coBuyDealsDeletedSnackbar => 'Co-buy deal deleted';

  @override
  String get coBuyDealsEmptyMessage =>
      'No co-buy deals yet. Create one so retailers can pool orders with you.';

  @override
  String get coBuyDetailActiveDealLabel => 'Active Deal';

  @override
  String get coBuyDetailVisitShopLabel => 'Visit Shop';

  @override
  String coBuyDetailJoinedSnackbar(String productName, String amount) {
    return 'Joined $productName Co-Buy · $amount';
  }

  @override
  String coBuyDetailLeftSnackbar(String productName) {
    return 'Left $productName Co-Buy';
  }

  @override
  String coBuyDetailQtyLabel(int quantity, String unitLabel) {
    return 'Qty: $quantity $unitLabel';
  }

  @override
  String get coBuyDetailProgressTitle => 'Co-Buy Progress';

  @override
  String coBuyDetailProgressLine(
    int currentQty,
    int targetQty,
    String unitLabel,
  ) {
    return 'Progress: $currentQty/$targetQty $unitLabel';
  }

  @override
  String coBuyDetailRetailersJoined(int count) {
    return '$count retailers joined';
  }

  @override
  String coBuyDetailYouSaveLine(int savingsPct, String perUnitLabel) {
    return 'You save $savingsPct% $perUnitLabel on this deal';
  }

  @override
  String get coBuyDetailYourOrderTitle => 'Your Order';

  @override
  String get coBuyDetailQuantityLabel => 'Quantity';

  @override
  String coBuyDetailMinOrderLabel(int minOrderQty, String unitLabel) {
    return 'Min order: $minOrderQty $unitLabel';
  }

  @override
  String get coBuyDetailSubtotalLabel => 'Subtotal';

  @override
  String coBuyDetailCheckoutLabel(String amount) {
    return 'Checkout · $amount';
  }

  @override
  String get coBuyDetailFullLabel => 'Co-Buy Full';

  @override
  String get coBuyDetailJoinedLabel => 'You\'re in · tap to leave';

  @override
  String coBuyDetailJoinLabel(String amount) {
    return 'Join Co-Buy · $amount';
  }

  @override
  String get wishlistScreenTitle => 'Wishlist';

  @override
  String get wishlistEmptyStateMessage => 'No items in your wishlist yet';

  @override
  String wishlistAddedToCartSnackbar(String productName) {
    return '$productName added to cart';
  }

  @override
  String get wishlistAddToCartButton => 'Add to Cart';

  @override
  String get marketplaceCategoriesTitle => 'Product Categories';

  @override
  String get marketplaceCoBuyDealsTitle => 'Co-Buy Deals';

  @override
  String get marketplacePopularProductsTitle => 'Popular wholesale products';

  @override
  String get marketplaceSearchHint => 'Search products...';

  @override
  String get marketplaceNoProductsYet =>
      'No products listed yet. Check back soon!';

  @override
  String get marketplaceProductsLoadError =>
      'Couldn\'t load products. Tap to retry.';

  @override
  String get marketplaceCoBuyJoinButton => 'Join Co-Buy';

  @override
  String marketplaceCoBuyProgressToTarget(String percent) {
    return '$percent% to target';
  }

  @override
  String marketplaceCoBuyRetailersJoined(String count) {
    return '$count joined';
  }

  @override
  String get productDetailPerUnit => 'per unit';

  @override
  String productDetailMoqLabel(String moq) {
    return 'Minimum Order Quantity: $moq Bags';
  }

  @override
  String get productDetailSpecsTitle => 'Wholesale Specifications';

  @override
  String get productDetailSpecWeight => 'Weight';

  @override
  String get productDetailSpecOrigin => 'Origin';

  @override
  String get productDetailSpecGrade => 'Grade';

  @override
  String get productDetailSpecPackaging => 'Packaging';

  @override
  String get productDetailModeWholesale => 'Wholesale';

  @override
  String get productDetailModeSample => 'Sample';

  @override
  String get productDetailVisitShop => 'Visit Shop';

  @override
  String get productDetailInStock => 'In Stock';

  @override
  String get productDetailOutOfStock => 'Out of Stock';

  @override
  String get productDetailWholesaleBuyTitle => 'Wholesale Buy';

  @override
  String get productDetailSampleBuyTitle => 'Sample Buy';

  @override
  String get productDetailUnitBag => '/ bag';

  @override
  String get productDetailUnitPiece => '/ unit';

  @override
  String get productDetailQuantityLabel => 'Quantity';

  @override
  String productDetailAddedToCartSnackbar(String price) {
    return 'Added to cart · $price';
  }

  @override
  String get productDetailSampleRequestedSnackbar => 'Sample requested';

  @override
  String productDetailAddToCartButton(String price) {
    return 'Add to Cart · $price';
  }

  @override
  String get productDetailSampleAlreadyRequested => 'Sample Already Requested';

  @override
  String get productDetailSampleCooldownActive => 'Cooldown Active';

  @override
  String get productDetailRequestSample => 'Request Sample';

  @override
  String productDetailSampleCooldownNote(String date) {
    return 'You can request another sample after $date.';
  }

  @override
  String get productDetailSampleLimitNote => 'Limited to 1 sample every 3 days';

  @override
  String get storeProfileStatProducts => 'Products';

  @override
  String get storeProfileStatOrders => 'Orders';

  @override
  String get storeProfileStatRating => 'Rating';

  @override
  String get storeProfileTabProducts => 'Products';

  @override
  String get storeProfileTabAbout => 'About';

  @override
  String get storeProfileTabReviews => 'Reviews';

  @override
  String get storeProfileNoProducts => 'No products yet';

  @override
  String get storeProfileAboutSectionTitle => 'About';

  @override
  String get storeProfileBusinessDetailsTitle => 'Business Details';

  @override
  String get storeProfileLabelBusinessType => 'Business Type';

  @override
  String get storeProfileLabelYearEstablished => 'Year Established';

  @override
  String get storeProfileLabelLocation => 'Location';

  @override
  String get storeProfileLabelMinimumOrder => 'Minimum Order';

  @override
  String get storeProfileLabelResponseTime => 'Response Time';

  @override
  String get storeProfileLabelShipping => 'Shipping';

  @override
  String get storeProfileCertificationsTitle => 'Certifications & Standards';

  @override
  String get storeProfileWhyChooseUsTitle => 'Why Choose Us';

  @override
  String get storeProfileContactSupplierButton => 'Contact Supplier';

  @override
  String get storeProfileNoReviewsTitle => 'No reviews yet';

  @override
  String storeProfileNoReviewsBody(String sellerName) {
    return 'Be the first to review $sellerName after your order.';
  }

  @override
  String storeProfileReviewsCount(String count) {
    return '$count reviews';
  }

  @override
  String storeProfileRecommendPercent(String percent) {
    return '$percent% Recommend';
  }

  @override
  String storeProfileResponseTimeChip(String time) {
    return '$time Response';
  }

  @override
  String get storeProfileTopSellerChip => 'Top Seller';

  @override
  String get storeProfileRatingBreakdownTitle => 'Rating breakdown';

  @override
  String get storeProfileRecentReviewsTitle => 'Recent Reviews';

  @override
  String get categoryResultsSearchHint => 'Search products...';

  @override
  String get categoryResultsFiltersButton => 'Filters';

  @override
  String categoryResultsItemsCount(String count) {
    return '$count Items';
  }

  @override
  String get categoryResultsNoProducts => 'No products found';

  @override
  String get categoryResultsFilterSheetTitle => 'Filter by Category';

  @override
  String get categoryResultsClearAll => 'Clear All';

  @override
  String get categoryResultsApplyFilters => 'Apply Filters';

  @override
  String get searchScreenTitle => 'Search';

  @override
  String get searchHint => 'Search products or sellers...';

  @override
  String get searchRecentSearchesTitle => 'Recent Searches';

  @override
  String get searchClearAll => 'Clear All';

  @override
  String get searchTrendingSearchesTitle => 'Trending Searches';

  @override
  String get searchSuggestedCategoriesTitle => 'Suggested Categories';

  @override
  String get searchRecommendedForYouTitle => 'Recommended For You';

  @override
  String searchNoResults(String query) {
    return 'No products found for \"$query\"';
  }

  @override
  String get ordersScreenTitle => 'View Orders';

  @override
  String get ordersEmptyStateMessage => 'No orders in this category';

  @override
  String ordersFilterAllLabel(int count) {
    return 'All ($count)';
  }

  @override
  String ordersItemCountLabel(int count) {
    return '$count items';
  }

  @override
  String ordersOrderNumberLabel(String orderId) {
    return 'Order #$orderId';
  }

  @override
  String get ordersRateReviewButton => 'Rate & Review';

  @override
  String get ordersReportButton => 'Report';

  @override
  String get ordersReportLabel => 'Report order';

  @override
  String get ordersReportSheetTitle => 'Report Order';

  @override
  String get ordersReportReasonLabel => 'What\'s the issue?';

  @override
  String get ordersReportReasonWrongItem => 'Wrong item received';

  @override
  String get ordersReportReasonDamaged => 'Item damaged';

  @override
  String get ordersReportReasonMissing => 'Item missing';

  @override
  String get ordersReportReasonLateDelivery => 'Late delivery';

  @override
  String get ordersReportReasonOther => 'Other';

  @override
  String get ordersReportNoteLabel => 'Additional details (optional)';

  @override
  String get ordersReportNoteHint => 'Tell us more about the issue...';

  @override
  String get ordersReportSubmitButton => 'Submit Report';

  @override
  String get ordersReportSubmittedSnackbar => 'Your report has been submitted';

  @override
  String ordersReportFailedSnackbar(String error) {
    return 'Failed to submit report: $error';
  }

  @override
  String get ordersViewDetailsButton => 'View Details';

  @override
  String get ordersTrackOrderButton => 'Track Order';

  @override
  String get orderDetailScreenTitle => 'Order Details';

  @override
  String get orderDetailItemsAddedSnackbar => 'Items added to your cart';

  @override
  String get orderDetailItemsOrderedSection => 'Items Ordered';

  @override
  String orderDetailOrderNumberLabel(String orderId) {
    return 'Order #$orderId';
  }

  @override
  String get orderDetailDeliveryMethodSection => 'Delivery Method';

  @override
  String get orderDetailCarrierLabel => 'Carrier';

  @override
  String get orderDetailPaymentSummarySection => 'Payment Summary';

  @override
  String orderDetailPhoneLabel(String phone) {
    return 'Phone: $phone';
  }

  @override
  String orderDetailPlacedOnLabel(String date) {
    return 'Placed on $date';
  }

  @override
  String orderDetailReceiptSaveFailedSnackbar(String error) {
    return 'Failed to save receipt: $error';
  }

  @override
  String get orderDetailReceiptSavedSnackbar => 'Receipt saved to your device';

  @override
  String get orderDetailReorderButton => 'Reorder Wholesale Items';

  @override
  String get orderDetailSaveReceiptButton => 'Save Receipt as PDF';

  @override
  String get orderDetailSavingLabel => 'Saving...';

  @override
  String get orderDetailShippingFeeLabel => 'Shipping Fee';

  @override
  String get orderDetailShippingSection => 'Shipping & Delivery';

  @override
  String get orderDetailSubtotalLabel => 'Subtotal';

  @override
  String get orderDetailTotalAmountLabel => 'Total Amount';

  @override
  String get orderDetailTrackDeliveryButton => 'Track Delivery';

  @override
  String get orderDetailWholesaleDiscountLabel => 'Wholesale Discount';

  @override
  String get deliveryScreenTitle => 'Delivery Tracking';

  @override
  String get deliveryCurrentStatusLabel => 'Current status';

  @override
  String get deliveryEscrowNoteText =>
      'Funds held securely in escrow until you confirm receipt.';

  @override
  String get deliveryInProgressLabel => 'In progress';

  @override
  String get deliveryPendingLabel => 'Pending';

  @override
  String deliveryPlacedOnLabel(String date) {
    return 'Placed on $date';
  }

  @override
  String get deliveryStatusSectionTitle => 'Delivery Status';

  @override
  String get deliveryStepDelivered => 'Delivered';

  @override
  String get deliveryStepOrderCancelled => 'Order cancelled';

  @override
  String get deliveryStepOrderPlaced => 'Order placed';

  @override
  String get deliveryStepOutForDelivery => 'Out for delivery';

  @override
  String get deliveryStepPackedAtWarehouse => 'Packed at warehouse';

  @override
  String get reviewSheetTitle => 'Rate & Review';

  @override
  String get reviewAddPhotosButton => 'Add Photos';

  @override
  String get reviewAddPhotosLabel => 'ADD PHOTOS OF RECEIVED ITEMS';

  @override
  String get reviewHintText => 'Share your experience with this order...';

  @override
  String reviewMaxPhotosSnackbar(int count) {
    return 'You can add up to $count photos';
  }

  @override
  String get reviewOfficialBadge => 'OFFICIAL';

  @override
  String reviewPhotoLibraryErrorSnackbar(String error) {
    return 'Could not open photo library: $error';
  }

  @override
  String get reviewRateProductLabel => 'RATE PRODUCT';

  @override
  String get reviewRateStoreLabel => 'RATE STORE';

  @override
  String get reviewSubmitButton => 'Submit Review';

  @override
  String get reviewSubmittedSnackbar =>
      'Thanks! Your review has been submitted.';

  @override
  String get reviewWriteReviewLabel => 'WRITE A REVIEW';

  @override
  String get paymentScreenTitle => 'Payment Method';

  @override
  String get paymentAbaMethodTitle => 'ABA Pay';

  @override
  String get paymentAbaNotAvailableSnackbar => 'ABA Pay is not available yet';

  @override
  String get paymentAmountToPayLabel => 'Amount to Pay';

  @override
  String get paymentCardDetailsSubtitle => 'Securely enter your card details';

  @override
  String get paymentCardMethodTitle => 'Credit/Debit Card';

  @override
  String get paymentCardNumberLabel => 'CARD NUMBER';

  @override
  String get paymentCardHolderLabel => 'CARD HOLDER';

  @override
  String get paymentCardValidThruLabel => 'VALID THRU';

  @override
  String get paymentConfirmedSubtitle => 'Your order has been placed and paid.';

  @override
  String get paymentConfirmedTitle => 'You\'re confirmed!';

  @override
  String get paymentConfirmingSubtitle => 'Confirming your order...';

  @override
  String get paymentConfirmingTitle => 'Just a moment';

  @override
  String get paymentContinueShoppingButton => 'Continue Shopping';

  @override
  String get paymentCvvLabel => 'CVV';

  @override
  String get paymentExpiryDateLabel => 'EXPIRY DATE';

  @override
  String paymentFailedSnackbar(String error) {
    return 'Payment failed: $error';
  }

  @override
  String paymentItemsPurchasedLabel(int count) {
    return '$count items purchased';
  }

  @override
  String get paymentMethodSubtitleVisaMastercard => 'Visa, Mastercard, etc.';

  @override
  String get paymentKhqrMethodTitle => 'KHQR / Bakong';

  @override
  String get paymentKhqrSubtitle => 'Bakong, ABA, ACLEDA & more';

  @override
  String get paymentKhqrSheetTitle => 'Scan to Pay';

  @override
  String get paymentKhqrInstructions =>
      'Open your banking app and scan this code to complete payment';

  @override
  String paymentKhqrExpiresLabel(String time) {
    return 'Expires in $time';
  }

  @override
  String get paymentKhqrExpiredLabel => 'QR code expired';

  @override
  String get paymentKhqrRefreshButton => 'Refresh Code';

  @override
  String get paymentKhqrConfirmButton => 'I\'ve Completed the Payment';

  @override
  String paymentPayAmountLabel(String amount) {
    return 'Pay $amount';
  }

  @override
  String get paymentPayNowButton => 'Pay Now';

  @override
  String get paymentSecureEncryptionNote =>
      'Your payment credentials are securely encrypted';

  @override
  String get paymentSelectMethodLabel => 'Select Payment Method';

  @override
  String get paymentTotalPaidLabel => 'Total Paid';

  @override
  String get paymentViewOrdersButton => 'View Orders';

  @override
  String get paymentWholesaleItemsFallbackLabel => 'Wholesale Items';

  @override
  String get escrowScreenTitle => 'Escrow & checkout';

  @override
  String get escrowPlaceholderText =>
      'Payment, QR confirm, dispute evidence. UI comes in phase 8';

  @override
  String get profileMenuMyOrders => 'My Orders';

  @override
  String get profileMenuCoBuyInvites => 'Co-Buy Invites';

  @override
  String get profileMenuAddressBook => 'Address Book';

  @override
  String get profileMenuAddressStore => 'Address Store';

  @override
  String get profileMenuBuyerChat => 'Chat with Buyers';

  @override
  String get profileMenuNotifications => 'Notifications';

  @override
  String get profileMenuPaymentCurrency => 'Payment Currency';

  @override
  String get profileMenuLanguage => 'Language';

  @override
  String get profileMenuDataPrivacy => 'Data Privacy';

  @override
  String get profileMenuMarketingEmails => 'Marketing Emails';

  @override
  String get profileMenuPersonalizedAds => 'Personalized Ads';

  @override
  String get profileMenuHelpSupport => 'Help & Support';

  @override
  String get profileMenuTermsConditions => 'Terms & Conditions';

  @override
  String get profileMenuPrivacyPolicy => 'Privacy Policy';

  @override
  String get profileMenuAbout => 'About';

  @override
  String get profileMenuSellerDashboard => 'Seller Dashboard';

  @override
  String get profileMenuMyInventory => 'My Inventory';

  @override
  String get profileMenuAddListing => 'Add Listing';

  @override
  String get profileMenuCoBuyDeals => 'Co-Buy Deals';

  @override
  String get profileMenuShopProfile => 'Shop Profile';

  @override
  String get profileSectionShopping => 'SHOPPING';

  @override
  String get profileSectionSelling => 'SELLING';

  @override
  String get profileSectionAccount => 'ACCOUNT';

  @override
  String get profileSectionSettings => 'SETTINGS';

  @override
  String get profileSectionSupport => 'SUPPORT';

  @override
  String get profileSectionAbout => 'ABOUT';

  @override
  String get profileStatTotalOrders => 'Total Orders';

  @override
  String get profileStatActiveOrders => 'Active Orders';

  @override
  String get profileStatSavedItems => 'Saved Items';

  @override
  String get profileStatTotalProducts => 'Total Products';

  @override
  String get profileStatRevenue => 'Revenue';

  @override
  String get profileSellerProgramBadge => 'SELLER PROGRAM';

  @override
  String get profileSellerTitle => 'Start Selling on Bosdom';

  @override
  String get profileSellerSubtitle =>
      'Join thousands of wholesalers and reach more retailers across Cambodia';

  @override
  String get profileSellerCta => 'Become a Seller';

  @override
  String get profileSellerOnboardingLabel => 'Seller Onboarding';

  @override
  String get profileSellerActiveBadge => 'ACTIVE SELLER';

  @override
  String get profileSellerActiveTitle => 'You\'re a Seller';

  @override
  String get profileSellerActiveSubtitle =>
      'Manage your listings and orders from the Marketplace tab';

  @override
  String get profileSellerActivatedSnackbar =>
      'You\'re now part of the Seller Program!';

  @override
  String get profileSellerGoToMarketplace => 'Go to Marketplace';

  @override
  String get profileEditProfileLabel => 'Edit Profile';

  @override
  String get sellerDashboardScreenTitle => 'Dashboard';

  @override
  String get sellerDashboardVerifiedBadge => 'Verified';

  @override
  String get sellerDashboardWelcomeMessage =>
      'Welcome back! Here\'s your wholesale store performance summary today.';

  @override
  String get sellerDashboardRevenueLabel => 'Revenue';

  @override
  String get sellerDashboardPendingLabel => 'Pending';

  @override
  String sellerDashboardPendingOrdersLabel(int count) {
    return '$count Orders';
  }

  @override
  String get sellerDashboardProductsLabel => 'Products';

  @override
  String sellerDashboardProductsCountLabel(int count) {
    return '$count Items';
  }

  @override
  String get sellerDashboardQuickActionsTitle => 'Quick Actions';

  @override
  String get sellerDashboardAddListingAction => 'Add Listing';

  @override
  String get sellerDashboardMyInventoryAction => 'My Inventory';

  @override
  String get sellerDashboardOrdersAction => 'Orders';

  @override
  String get sellerDashboardEarningsAction => 'Earnings';

  @override
  String get sellerDashboardBuyerToolsTitle => 'Shop as a Buyer';

  @override
  String get sellerDashboardMarketplaceAction => 'Marketplace';

  @override
  String get sellerDashboardWishlistAction => 'Wishlist';

  @override
  String get sellerDashboardCartAction => 'Cart';

  @override
  String get sellerDashboardCoBuyingAction => 'Co-Buying';

  @override
  String get sellerDashboardPerformanceTitle => 'Performance';

  @override
  String get sellerDashboardRatingLabel => 'Rating';

  @override
  String get sellerDashboardCompletionLabel => 'Completion';

  @override
  String get sellerDashboardAvgDeliveryLabel => 'Avg Delivery';

  @override
  String get sellerDashboardRecentOrdersTitle => 'Recent Active Orders';

  @override
  String get sellerDashboardViewAllLabel => 'View All';

  @override
  String get sellerEarningsScreenTitle => 'Earnings';

  @override
  String get sellerEarningsAvailableBalanceLabel => 'Available Balance';

  @override
  String sellerEarningsCompletedSalesPercentLabel(int percent) {
    return '$percent% of completed sales';
  }

  @override
  String get sellerEarningsWithdrawButton => 'Withdraw';

  @override
  String get sellerEarningsReleasedLabel => 'Released';

  @override
  String get sellerEarningsInEscrowLabel => 'In Escrow';

  @override
  String get sellerEarningsRefundedLabel => 'Refunded';

  @override
  String get sellerEarningsFilterAllLabel => 'All';

  @override
  String get sellerEarningsFilterReleasedLabel => 'Released';

  @override
  String get sellerEarningsFilterInEscrowLabel => 'In Escrow';

  @override
  String get sellerEarningsFilterDisputedLabel => 'Disputed';

  @override
  String sellerEarningsTransactionsCountLabel(int count) {
    return '$count transactions';
  }

  @override
  String sellerEarningsOrderBuyerLabel(String id, String buyer) {
    return '#$id • $buyer';
  }

  @override
  String get sellerEarningsSaleAmountLabel => 'Sale amount';

  @override
  String sellerEarningsPlatformFeeLabel(int rate) {
    return 'Platform fee ($rate%)';
  }

  @override
  String get sellerEarningsYourEarningsLabel => 'Your earnings';

  @override
  String get sellerEarningsWithdrawalLabel => 'Withdrawal';

  @override
  String get sellerEarningsStatusPending => 'Pending';

  @override
  String get sellerEarningsStatusInEscrow => 'In Escrow';

  @override
  String get sellerEarningsStatusReleased => 'Released';

  @override
  String get sellerEarningsStatusDisputed => 'Refunded';

  @override
  String get sellerEarningsStatusWithdrawn => 'Withdrawn';

  @override
  String get sellerEarningsEscrowNoticeText =>
      'Funds are held in escrow for 48 hours after purchase. Once released, tap Withdraw to transfer earnings to your bank account.';

  @override
  String get sellerEarningsEmptyStateMessage =>
      'No transactions in this category';

  @override
  String get sellerEarningsWithdrawSheetTitle => 'Withdraw Funds';

  @override
  String get sellerEarningsWithdrawPoweredByLabel => 'Powered by ABA Pay';

  @override
  String get sellerEarningsWithdrawAmountLabel => 'Withdrawal Amount (\$)';

  @override
  String get sellerEarningsAccountHolderNameLabel => 'Account Holder Name';

  @override
  String get sellerEarningsAccountHolderNameHint => 'Full name on account';

  @override
  String get sellerEarningsRoutingNumberLabel => 'Routing Number';

  @override
  String get sellerEarningsRoutingNumberHint =>
      'Enter ABA routing number (e.g., 020001)';

  @override
  String get sellerEarningsAccountNumberLabel => 'Account Number';

  @override
  String get sellerEarningsAccountNumberHint => 'Enter ABA account number';

  @override
  String get sellerEarningsWithdrawNoticeText =>
      'Funds will be instantly transferred to your designated ABA Pay account. Standard security holds may apply.';

  @override
  String get sellerEarningsWithdrawContinueButton => 'Continue';

  @override
  String get sellerEarningsWithdrawFieldRequiredError =>
      'This field is required';

  @override
  String get sellerEarningsWithdrawAmountInvalidError => 'Enter a valid amount';

  @override
  String get sellerEarningsWithdrawAmountExceedsError =>
      'Amount exceeds available balance';

  @override
  String get sellerEarningsWithdrawJustNowLabel => 'Just now';

  @override
  String sellerEarningsWithdrawSuccessSnackbar(String amount) {
    return 'Withdrawal of \$$amount submitted';
  }

  @override
  String get sellerEarningsWithdrawSuccessTitle => 'Success';

  @override
  String sellerEarningsWithdrawSuccessMessage(String amount) {
    return '\$$amount withdrawal initiated. Funds will arrive in 2-3 business days.';
  }

  @override
  String get sellerEarningsWithdrawSuccessOkButton => 'OK';

  @override
  String get sellerOrdersScreenTitle => 'Orders';

  @override
  String get sellerOrdersEmptyStateMessage => 'No orders in this category';

  @override
  String sellerOrdersFilterAllLabel(int count) {
    return 'All ($count)';
  }

  @override
  String sellerOrdersFilterPendingLabel(int count) {
    return 'Pending ($count)';
  }

  @override
  String sellerOrdersQuantityProductLabel(String quantity, String product) {
    return '$quantity • $product';
  }

  @override
  String get sellerOrdersCoBuyBadgeLabel => 'Co-Buy';

  @override
  String get sellerOrderDetailBuyerInfoSection => 'Buyer Information';

  @override
  String sellerOrderDetailPlatformFeeLabel(int rate) {
    return 'Platform Fee ($rate%)';
  }

  @override
  String get sellerOrderDetailYourEarningsLabel => 'Your Earnings';

  @override
  String get sellerOrderDetailAcceptButton => 'Accept Order';

  @override
  String get sellerOrderDetailDeclineButton => 'Decline Order';

  @override
  String get sellerOrderDetailOrderAcceptedSnackbar => 'Order accepted';

  @override
  String get sellerOrderDetailOrderDeclinedSnackbar => 'Order declined';

  @override
  String get sellerOrderDetailDeclineConfirmTitle => 'Decline this order?';

  @override
  String get sellerOrderDetailDeclineConfirmMessage =>
      'The buyer will be notified that you can\'t fulfill this order.';

  @override
  String get sellerOrderDetailDeclineConfirmCancel => 'Cancel';

  @override
  String get sellerOrderDetailDeclineConfirmConfirm => 'Decline';

  @override
  String get myInventoryScreenTitle => 'My Inventory';

  @override
  String get myInventorySearchHint => 'Search products...';

  @override
  String get myInventoryFilterAll => 'All';

  @override
  String get myInventoryFilterActive => 'Active';

  @override
  String get myInventoryFilterInactive => 'Inactive';

  @override
  String myInventoryStockLabel(String stock) {
    return 'Stock: $stock';
  }

  @override
  String get myInventoryEmptyStateMessage => 'No products found.';

  @override
  String myInventoryListingActivatedSnackbar(String product) {
    return '$product is now active';
  }

  @override
  String myInventoryListingDeactivatedSnackbar(String product) {
    return '$product is now inactive';
  }

  @override
  String get profileEditProfileRoleLabel => 'Role Profile';

  @override
  String get profileEditProfileRoleSheetTitle => 'Select Role Profile';

  @override
  String get profileEditProfileChangePhoto => 'Change photo';

  @override
  String get profileEditProfileNameLabel => 'Full Name';

  @override
  String get profileEditProfileNameHint => 'Enter your full name';

  @override
  String get profileEditProfileNameRequired => 'Please enter your name';

  @override
  String get profileEditProfilePhoneLabel => 'Phone Number';

  @override
  String get profileEditProfilePhoneHint => 'Enter your phone number';

  @override
  String get profileEditProfilePhoneRequired =>
      'Please enter your phone number';

  @override
  String get profileEditProfileEmailLabel => 'Email Address';

  @override
  String get profileEditProfileEmailHint => 'Enter your email address';

  @override
  String get profileEditProfileEmailRequired =>
      'Please enter your email address';

  @override
  String get profileEditProfileEmailInvalid =>
      'Please enter a valid email address';

  @override
  String get profileEditProfileSaveButton => 'Save Changes';

  @override
  String get profileEditProfileSavedSnackbar => 'Profile updated successfully';

  @override
  String get profileEditProfileSaveErrorSnackbar =>
      'Couldn\'t save your profile. Please try again.';

  @override
  String get profileEditProfileLoadErrorSnackbar =>
      'Couldn\'t load your profile. Please try again.';

  @override
  String get shopProfileScreenTitle => 'Shop Profile';

  @override
  String get shopProfileChangeLogo => 'Change Store Logo';

  @override
  String get shopProfileShopNameLabel => 'Shop Name';

  @override
  String get shopProfileShopNameHint => 'Enter your shop name';

  @override
  String get shopProfileShopNameRequired => 'Please enter your shop name';

  @override
  String get shopProfileBusinessTypeLabel => 'Business Type';

  @override
  String get shopProfileBusinessTypeHint => 'e.g. Manufacturer & Distributor';

  @override
  String get shopProfileBusinessTypeRequired =>
      'Please enter your business type';

  @override
  String get shopProfileYearEstablishedLabel => 'Year Established';

  @override
  String get shopProfileYearEstablishedHint => 'e.g. 2018';

  @override
  String get shopProfileLocationLabel => 'Location';

  @override
  String get shopProfileLocationHint => 'e.g. Phnom Penh';

  @override
  String get shopProfileLocationRequired => 'Please enter your location';

  @override
  String get shopProfilePhoneLabel => 'Phone Number';

  @override
  String get shopProfilePhoneHint => 'Enter your phone number';

  @override
  String get shopProfilePhoneRequired => 'Please enter your phone number';

  @override
  String get shopProfileEmailLabel => 'Email Address';

  @override
  String get shopProfileEmailHint => 'Enter your email address';

  @override
  String get shopProfileEmailRequired => 'Please enter your email address';

  @override
  String get shopProfileEmailInvalid => 'Please enter a valid email address';

  @override
  String get shopProfileDescriptionLabel => 'Business Description';

  @override
  String get shopProfileDescriptionHint => 'Tell buyers about your business';

  @override
  String get shopProfileSaveButton => 'Save Changes';

  @override
  String get shopProfileSavedSnackbar => 'Shop profile updated successfully';

  @override
  String get shopProfileSaveErrorSnackbar =>
      'Couldn\'t save your shop profile. Please try again.';

  @override
  String get addListingScreenTitle => 'Add Listing';

  @override
  String get addListingProductNameLabel => 'Product Name';

  @override
  String get addListingProductNameHint => 'e.g. Premium Cashew Nuts';

  @override
  String get addListingProductNameRequired => 'Please enter a product name';

  @override
  String get addListingCategoryLabel => 'Category';

  @override
  String get addListingCategoryHint => 'Select category';

  @override
  String get addListingCategoryRequired => 'Please select a category';

  @override
  String get addListingPriceLabel => 'Price USD';

  @override
  String get addListingPriceRequired => 'Please enter a price';

  @override
  String get addListingPriceInvalid => 'Please enter a valid price';

  @override
  String get addListingMoqLabel => 'Minimum Order Qty';

  @override
  String get addListingMoqHint => 'e.g. 100 bags';

  @override
  String get addListingMoqRequired => 'Please enter a minimum order quantity';

  @override
  String get addListingMoqInvalid => 'Please enter a valid quantity';

  @override
  String get addListingStockLabel => 'Stock Quantity';

  @override
  String get addListingStockHint => 'e.g. 500';

  @override
  String get addListingStockRequired => 'Please enter a stock quantity';

  @override
  String get addListingStockInvalid => 'Please enter a valid quantity';

  @override
  String get addListingPhotosLabel => 'Product Photos';

  @override
  String get addListingCoverPhotoCta => 'Tap to add cover photo';

  @override
  String get addListingPhotosFormatHint => 'JPG, PNG up to 5MB';

  @override
  String get addListingPhotosHelper =>
      'Upload up to 5 photos. First photo is the cover.';

  @override
  String get addListingCoverPhotoRequired => 'Please add a cover photo';

  @override
  String get addListingDescriptionLabel => 'Description';

  @override
  String get addListingDescriptionHint =>
      'e.g. 100% cotton crew-neck t-shirts, Grade A quality, sold in bulk from 50pcs, ships within 3-5 business days.';

  @override
  String get addListingSampleTestingLabel => 'Sample Testing';

  @override
  String get addListingSampleTestingToggleTitle => 'Enable Sample Testing';

  @override
  String get addListingSampleTestingToggleSubtitle => 'Limit 1 item per buyer';

  @override
  String get addListingSamplePriceLabel => 'Sample Price USD';

  @override
  String get addListingSamplePriceRequired => 'Please enter a sample price';

  @override
  String get addListingSamplePriceInvalid =>
      'Please enter a valid sample price';

  @override
  String get addListingVariantsLabel => 'Sizes & Colors';

  @override
  String get addListingVariantsHelper =>
      'Let buyers pick from the options you offer';

  @override
  String get addListingAddSizeChip => 'Add size';

  @override
  String get addListingAddSizeDialogTitle => 'Add a size';

  @override
  String get addListingAddSizeDialogHint => 'e.g. Kids, 42, Free Size';

  @override
  String get addListingAddSizeConfirm => 'Add';

  @override
  String get addListingAddColorDialogTitle => 'Choose a color';

  @override
  String get addListingCreateButton => 'Create Listing';

  @override
  String get addListingCreatedSnackbar => 'Listing created successfully';

  @override
  String get addListingCreateErrorSnackbar =>
      'Couldn\'t create your listing. Please try again.';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileRefreshFailedSnackbar =>
      'Couldn\'t refresh your profile. Check your connection and try again.';

  @override
  String get currencyScreenTitle => 'Payment Currency';

  @override
  String get currencyScreenIntro =>
      'Choose your preferred currency for all transactions on Bosdom. Prices will be displayed in your selected currency.';

  @override
  String get currencySectionSelect => 'SELECT CURRENCY';

  @override
  String get currencySectionDisplaySettings => 'CURRENCY DISPLAY SETTINGS';

  @override
  String get currencyUsdName => 'US Dollar (USD)';

  @override
  String get currencyKhrName => 'Khmer Riel (KHR)';

  @override
  String get currencyExchangeRateLabel => 'Exchange Rate';

  @override
  String get currencyRateDisclaimer =>
      'Exchange rates are updated daily. Final conversion rates are applied at the time of payment.';

  @override
  String currencyLastUpdatedLabel(String date) {
    return 'Last updated: $date';
  }

  @override
  String get currencyActiveStatus => 'Active';

  @override
  String get currencyDailyUpdateChip => 'Daily Update';

  @override
  String get currencyShowBothToggleLabel => 'Show prices in both currencies';

  @override
  String get currencySavedSnackbar => 'Currency preferences saved';

  @override
  String get helpSupportScreenTitle => 'Help & Support';

  @override
  String get helpSupportSearchHint => 'Search FAQs or articles...';

  @override
  String get helpSupportCategoriesLabel => 'FAQ Categories';

  @override
  String get helpSupportCategoryGettingStarted => 'Getting Started';

  @override
  String get helpSupportCategoryOrdersPayments => 'Orders & Payments';

  @override
  String get helpSupportCategoryShippingDelivery => 'Shipping & Delivery';

  @override
  String get helpSupportCategoryAccountVerification => 'Account & Verification';

  @override
  String get helpSupportCategoryReturnsDisputes => 'Returns & Disputes';

  @override
  String get helpSupportAssistanceTitle => 'Need Personal Assistance?';

  @override
  String get helpSupportAssistanceBody =>
      'Our B2B support team is available Mon-Fri, 8 AM - 6 PM (Cambodia Time) to resolve order disputes or platform inquiries.';

  @override
  String get helpSupportLiveChat => 'Live Chat';

  @override
  String get helpSupportCallUs => 'Call Us';

  @override
  String get helpSupportReportIssue => 'Report an Issue / Bug';

  @override
  String get reportIssueScreenTitle => 'Report an Issue';

  @override
  String get reportIssueTypeLabel => 'Issue Type';

  @override
  String get reportIssueTypeOrderProblem => 'Order Problem';

  @override
  String get reportIssueTypePaymentIssue => 'Payment Issue';

  @override
  String get reportIssueTypeAppBug => 'App Bug';

  @override
  String get reportIssueTypeDeliveryIssue => 'Delivery Issue';

  @override
  String get reportIssueTypeAccountProblem => 'Account Problem';

  @override
  String get reportIssueTypeOther => 'Other';

  @override
  String get reportIssueSubjectLabel => 'Subject';

  @override
  String get reportIssueSubjectHint => 'Briefly describe the issue';

  @override
  String get reportIssueSubjectRequired => 'Please enter a subject';

  @override
  String get reportIssueDescriptionLabel => 'Description';

  @override
  String get reportIssueDescriptionHint => 'Describe the issue in detail...';

  @override
  String get reportIssueDescriptionRequired => 'Please describe the issue';

  @override
  String get reportIssueAttachLabel => 'Attach Screenshots';

  @override
  String get reportIssueAttachTapToUpload => 'Tap to upload images';

  @override
  String reportIssueAttachSupports(int max) {
    return 'Supports PNG, JPG up to 5MB (Max $max files)';
  }

  @override
  String reportIssueMaxFilesSnackbar(int max) {
    return 'You can attach up to $max files';
  }

  @override
  String reportIssuePhotoLibraryErrorSnackbar(String error) {
    return 'Could not open photo library: $error';
  }

  @override
  String get reportIssueOrderRefLabel => 'Order Reference';

  @override
  String get reportIssueOrderRefOptional => '(Optional)';

  @override
  String get reportIssueOrderRefHint => 'e.g., #B2B-98741';

  @override
  String get reportIssueResponseNote =>
      'Our wholesale support team typically responds to app bugs and order technical inquiries within 2 hours.';

  @override
  String get reportIssueSubmitButton => 'Submit Report';

  @override
  String get reportIssueSubmittedSnackbar =>
      'Your report has been submitted. We\'ll get back to you soon.';

  @override
  String get callUsPopupBody =>
      'Our specialized B2B customer assistance hotline is available for order resolutions, disputes, and urgent support.';

  @override
  String get callUsPopupHours => 'Mon-Fri, 8 AM - 6 PM (Cambodia Time)';

  @override
  String get callUsPopupSupportLabel => 'B2B Wholesale Support';

  @override
  String get callUsPopupPhoneNumber => '+855 23 456 789';

  @override
  String get callUsPopupCallNow => 'Call Now';

  @override
  String get callUsPopupLaunchError => 'Couldn\'t open the phone dialer';

  @override
  String get termsConditionsScreenTitle => 'Terms & Conditions';

  @override
  String get termsConditionsLastUpdated => 'Last updated: August 2026';

  @override
  String get termsConditionsSection1Title =>
      '1. Platform Overview & Acceptance';

  @override
  String get termsConditionsSection1Point1 =>
      'Bosdom is a localized B2B wholesale marketplace built for verified Cambodian retailers and suppliers. The Platform connects independent retail merchants with trusted wholesalers through a secure escrow payment system, featuring sample verification, group co-buying, and automated escrow protections.';

  @override
  String get termsConditionsSection1Point2 =>
      'By creating an account, you confirm that:';

  @override
  String get termsConditionsSection1Point3 =>
      'You are at least 18 years of age.';

  @override
  String get termsConditionsSection1Point4 =>
      'You are operating a legitimate business in Cambodia.';

  @override
  String get termsConditionsSection1Point5 =>
      'All information provided during registration is accurate, current, and complete.';

  @override
  String get termsConditionsSection1Point6 =>
      'You agree to comply with these Terms and all applicable local laws and regulations.';

  @override
  String get termsConditionsSection2Title =>
      '2. Account Registration & Verification';

  @override
  String get termsConditionsSection2Point1 =>
      'All users must register with valid business and identity information before completing any transaction on the Platform.';

  @override
  String get termsConditionsSection2Point2 =>
      'Bosdom reserves the right to reject or suspend account registrations that fail identity verification or contain false information.';

  @override
  String get termsConditionsSection2Point3 =>
      'Each user is limited to one verified merchant profile per business.';

  @override
  String get termsConditionsSection2Point4 =>
      'Suppliers are required to provide accurate product listings, pricing, and inventory information at all times.';

  @override
  String get termsConditionsSection2Point5 =>
      'Buyers are responsible for keeping their account and business information up to date.';

  @override
  String get termsConditionsSection3Title =>
      '3. Try-Before-You-Bulk Sample Gate';

  @override
  String get termsConditionsSection3Point1 =>
      'Bosdom\'s Sample Gate lets buyers order a single unit of a product at consumer price before committing to a bulk wholesale purchase.';

  @override
  String get termsConditionsSection3Point2 =>
      'Each buyer is limited to one sample order per product to prevent misuse of the feature.';

  @override
  String get termsConditionsSection3Point3 =>
      'Sample orders do not carry wholesale pricing and are subject to standard shipping and handling fees.';

  @override
  String get termsConditionsSection3Point4 =>
      'Suppliers must fulfill sample orders with the same product quality advertised in the listing. Misrepresenting sample quality is a violation of these Terms.';

  @override
  String get termsConditionsSection4Title =>
      '4. Collaborative Social Co-Buying';

  @override
  String get termsConditionsSection4Point1 =>
      'Bosdom\'s Co-Buy feature lets buyers combine orders with other merchants to unlock wholesale bulk pricing.';

  @override
  String get termsConditionsSection4Point2 =>
      'Any registered buyer may start a co-buy pool by selecting \"Invite to Co-Buy\" on an eligible product and sharing the generated invite link.';

  @override
  String get termsConditionsSection4Point3 =>
      'Once a pool reaches its target quantity, the supplier fulfills the order under the applicable bulk pricing tier.';

  @override
  String get termsConditionsSection4Point4 =>
      'Participants share shipping costs proportionally to their share of the order.';

  @override
  String get termsConditionsSection4Point5 =>
      'If a co-buy pool does not reach its required threshold within the specified timeframe, all funds are automatically refunded to participants.';

  @override
  String get termsConditionsSection5Title =>
      '5. Escrow Payment & QR Verification System';

  @override
  String get termsConditionsSection5Point1 =>
      'All financial transactions on Bosdom are processed through the Platform\'s escrow system.';

  @override
  String get termsConditionsSection5Point2 =>
      'Supported payment methods include Bakong (National Bank of Cambodia) and other approved payment gateways.';

  @override
  String get termsConditionsSection5Point3 =>
      'Funds are held in escrow until delivery is confirmed.';

  @override
  String get termsConditionsSection5Point4 =>
      'Upon delivery, the receiving party must scan the QR code presented by the supplier or courier to confirm receipt.';

  @override
  String get termsConditionsSection5Point5 =>
      'Once delivery is confirmed via QR scan, escrow funds are released to the supplier. Delivery issues may be escalated through the dispute resolution process described in Section 8.';

  @override
  String get termsConditionsSection6Title =>
      '6. Chat Policy & Communication Rules';

  @override
  String get termsConditionsSection6Point1 =>
      'Bosdom provides in-app chat for direct communication between buyers and suppliers.';

  @override
  String get termsConditionsSection6Point2 =>
      'Before accessing chat, users must review and accept the Chat & Trading Policy and Liability Disclosure.';

  @override
  String get termsConditionsSection6Point3 =>
      'The following are prohibited in Platform communications:';

  @override
  String get termsConditionsSection6Point4 =>
      'Arranging payments outside the Platform.';

  @override
  String get termsConditionsSection6Point5 =>
      'Sharing personal bank details for off-platform payment.';

  @override
  String get termsConditionsSection6Point6 =>
      'Sending abusive, fraudulent, or otherwise inappropriate content.';

  @override
  String get termsConditionsSection6Point7 =>
      'Bosdom holds no liability for losses arising from off-platform payments or trades arranged in violation of this policy. Violations may result in a warning, account suspension, or permanent ban, depending on severity, at Bosdom\'s sole discretion.';

  @override
  String get termsConditionsSection7Title => '7. Pricing & Volume Tiers';

  @override
  String get termsConditionsSection7Point1 =>
      'Suppliers set their own pricing for both sample and bulk purchase tiers.';

  @override
  String get termsConditionsSection7Point2 =>
      'Bulk pricing is structured in volume tiers that unlock as a co-buy pool or bulk order grows.';

  @override
  String get termsConditionsSection7Point3 =>
      'Applicable pricing tiers are shown on each product listing and update automatically as order volume changes.';

  @override
  String get termsConditionsSection7Point4 =>
      'Bosdom does not own, store, or handle physical inventory. Suppliers are solely responsible for product quality, packaging, and inventory accuracy. Prices may be listed in Khmer Riel (KHR) or US Dollars (USD).';

  @override
  String get termsConditionsSection8Title => '8. Dispute Resolution';

  @override
  String get termsConditionsSection8Point1 =>
      'In the event of a dispute, such as damaged goods, non-delivery, or a quality mismatch, Bosdom provides a structured dispute resolution process.';

  @override
  String get termsConditionsSection8Point2 =>
      'Escrow funds related to a disputed order remain locked until the dispute is resolved.';

  @override
  String get termsConditionsSection8Point3 =>
      'Buyers have a 5-day window after delivery confirmation to file a dispute and submit supporting evidence.';

  @override
  String get termsConditionsSection8Point4 =>
      'Bosdom reserves the right to review evidence and adjust escrow disbursement in cases of fraud, non-delivery, or breach of these Terms.';

  @override
  String get termsConditionsSection9Title => '9. Prohibited Activities';

  @override
  String get termsConditionsSection9Point1 => 'Users of the Platform must not:';

  @override
  String get termsConditionsSection9Point2 =>
      'Sell counterfeit, illegal, or hazardous goods.';

  @override
  String get termsConditionsSection9Point3 =>
      'Create multiple accounts to bypass sample-gate limits.';

  @override
  String get termsConditionsSection9Point4 =>
      'Manipulate co-buy pools through fake participants or false pricing.';

  @override
  String get termsConditionsSection9Point5 =>
      'Engage in price fixing, deceptive advertising, or false product listings.';

  @override
  String get termsConditionsSection9Point6 =>
      'Use automated bots or scripts to interact with the Platform.';

  @override
  String get termsConditionsSection9Point7 =>
      'Violating any of the above may result in immediate account suspension, forfeiture of pending escrow funds, and, where applicable, referral to relevant authorities.';

  @override
  String get termsConditionsSection10Title => '10. Limitation of Liability';

  @override
  String get termsConditionsSection10Point1 =>
      'Bosdom acts solely as a marketplace facilitator connecting buyers and suppliers. To the maximum extent permitted by law, Bosdom is not liable for:';

  @override
  String get termsConditionsSection10Point2 =>
      'Product quality, accuracy of descriptions, or supplier claims.';

  @override
  String get termsConditionsSection10Point3 =>
      'Delivery timelines or courier performance beyond the Platform\'s control.';

  @override
  String get termsConditionsSection10Point4 =>
      'Losses resulting from a user\'s violation of these Terms or applicable Cambodian law.';

  @override
  String get termsConditionsSection10Point5 =>
      'Bosdom is not liable for indirect, incidental, or consequential damages arising from use of the Platform.';

  @override
  String get termsConditionsSection11Title => '11. Privacy & Data Protection';

  @override
  String get termsConditionsSection11Point1 =>
      'Bosdom collects and processes personal data in accordance with our Privacy Policy and applicable Cambodian data protection laws.';

  @override
  String get termsConditionsSection11Point2 =>
      'This includes business registration details, name, phone number, and email address, collected solely for identity verification and Platform operation.';

  @override
  String get termsConditionsSection12Title => '12. Modifications to Terms';

  @override
  String get termsConditionsSection12Point1 =>
      'Bosdom reserves the right to update or modify these Terms at any time. Continued use of the Platform after changes take effect constitutes acceptance of the updated Terms.';

  @override
  String get termsConditionsSection12Point2 =>
      'Users who do not agree with updated Terms should discontinue use of the Platform.';

  @override
  String get termsConditionsContactTitle => 'Contact Us';

  @override
  String get termsConditionsContactIntro =>
      'If you have questions about these Terms & Conditions, please contact us:';

  @override
  String get termsConditionsContactEmail => 'support@bosdom.com';

  @override
  String get termsConditionsContactInApp => 'In-app: Help & Support';

  @override
  String get privacyPolicyScreenTitle => 'Privacy Policy';

  @override
  String get privacyPolicyEffectiveDate => 'Effective Date: August 2026';

  @override
  String get privacyPolicySection1Title => '1. Information We Collect';

  @override
  String get privacyPolicySection1Point1 => 'a) Account Information';

  @override
  String get privacyPolicySection1Point2 =>
      'Full name, phone number, and email';

  @override
  String get privacyPolicySection1Point3 =>
      'Business name, type, and registration number';

  @override
  String get privacyPolicySection1Point4 =>
      'Business location and delivery address';

  @override
  String get privacyPolicySection1Point5 => 'Profile photo (optional)';

  @override
  String get privacyPolicySection1Point6 => 'b) Identity Verification Info';

  @override
  String get privacyPolicySection1Point7 =>
      'Government-issued ID (for buyer verification)';

  @override
  String get privacyPolicySection1Point8 =>
      'Business registration certificate (for supplier verification)';

  @override
  String get privacyPolicySection1Point9 =>
      'Bank account/e-wallet details (Bakong QR) for payments';

  @override
  String get privacyPolicySection1Point10 => 'c) Transaction Data';

  @override
  String get privacyPolicySection1Point11 =>
      'Order history, purchase amounts, and payment methods';

  @override
  String get privacyPolicySection1Point12 =>
      'Sample order and co-buy pool participation';

  @override
  String get privacyPolicySection1Point13 => 'd) Communication Data';

  @override
  String get privacyPolicySection1Point14 =>
      'In-app chat messages and conversation history';

  @override
  String get privacyPolicySection1Point15 =>
      'Chat attachments shared between participants';

  @override
  String get privacyPolicySection1Point16 =>
      'e) Verification & Fraud Detection';

  @override
  String get privacyPolicySection1Point17 =>
      'QR code scans used for delivery confirmation';

  @override
  String get privacyPolicySection1Point18 =>
      'Video evidence submitted with dispute resolution';

  @override
  String get privacyPolicySection1Point19 => 'f) Device & Usage Data';

  @override
  String get privacyPolicySection1Point20 =>
      'Device type, operating system, and app version';

  @override
  String get privacyPolicySection1Point21 =>
      'Location data used for delivery and courier matching';

  @override
  String get privacyPolicySection1Point22 =>
      'IP address and general session/log information';

  @override
  String get privacyPolicySection1Point23 => 'g) Co-Buy & Social Data';

  @override
  String get privacyPolicySection1Point24 =>
      'Co-buy invitation creation and participation';

  @override
  String get privacyPolicySection1Point25 =>
      'Invite link clicks and pool-joining activity';

  @override
  String get privacyPolicySection2Title => '2. How We Use Your Information';

  @override
  String get privacyPolicySection2Point1 =>
      'We use your personal data for the following purposes:';

  @override
  String get privacyPolicySection2Point2 => 'a) Platform Operations';

  @override
  String get privacyPolicySection2Point3 =>
      'To create and manage your buyer or seller account';

  @override
  String get privacyPolicySection2Point4 =>
      'To process orders, payments, and shipment tracking';

  @override
  String get privacyPolicySection2Point5 =>
      'To facilitate the Try-Before-You-Bulk sample gate feature';

  @override
  String get privacyPolicySection2Point6 =>
      'To enable Co-Buy session creation and order pooling';

  @override
  String get privacyPolicySection2Point7 => 'b) Trust & Safety';

  @override
  String get privacyPolicySection2Point8 =>
      'To verify identity for suppliers and buyers';

  @override
  String get privacyPolicySection2Point9 =>
      'To confirm order delivery via QR code scan';

  @override
  String get privacyPolicySection2Point10 =>
      'To detect and prevent off-platform payment or contact violations';

  @override
  String get privacyPolicySection2Point11 =>
      'To process disputes, evidence submissions, and refund requests';

  @override
  String get privacyPolicySection2Point12 =>
      'c) Payment Processing & Analytics';

  @override
  String get privacyPolicySection2Point13 =>
      'To securely process payments through Bakong and other integrated payment providers';

  @override
  String get privacyPolicySection2Point14 =>
      'To hold funds in escrow until delivery is confirmed';

  @override
  String get privacyPolicySection2Point15 =>
      'To analyze usage patterns and improve app features and performance';

  @override
  String get privacyPolicySection2Point16 =>
      'To personalize product recommendations and search suggestions';

  @override
  String get privacyPolicySection2Point17 => 'd) Push Notifications';

  @override
  String get privacyPolicySection2Point18 =>
      'To notify you about order status updates, chat messages, co-buy progress, and important account activity';

  @override
  String get privacyPolicySection2Point19 => 'e) Legal Compliance';

  @override
  String get privacyPolicySection2Point20 =>
      'To comply with applicable legal requirements';

  @override
  String get privacyPolicySection2Point21 =>
      'To respond to lawful requests from authorities';

  @override
  String get privacyPolicySection2Point22 => 'f) Business Transfers';

  @override
  String get privacyPolicySection2Point23 =>
      'In the event of a merger, acquisition, or asset sale, information may be transferred as part of the business assets, subject to equivalent privacy protection';

  @override
  String get privacyPolicySection3Title => '3. How We Share Your Information';

  @override
  String get privacyPolicySection3Point1 =>
      'We do not sell your personal data. We only share information in the following circumstances:';

  @override
  String get privacyPolicySection3Point2 => 'a) Between Buyers & Sellers';

  @override
  String get privacyPolicySection3Point3 =>
      'Business name, rating, and product listings shared to enable trading';

  @override
  String get privacyPolicySection3Point4 =>
      'Chat messages shared strictly between chat participants';

  @override
  String get privacyPolicySection3Point5 => 'b) Payment Providers';

  @override
  String get privacyPolicySection3Point6 =>
      'Transaction data shared with Bakong and other approved gateways to complete payments';

  @override
  String get privacyPolicySection3Point7 => 'c) Service Providers';

  @override
  String get privacyPolicySection3Point8 =>
      'Cloud hosting and data storage (Supabase infrastructure)';

  @override
  String get privacyPolicySection3Point9 =>
      'Analytics services to improve app performance and user experience';

  @override
  String get privacyPolicySection3Point10 => 'd) Legal Requirements';

  @override
  String get privacyPolicySection3Point11 =>
      'When required by applicable legal requirements';

  @override
  String get privacyPolicySection3Point12 =>
      'To protect Bosdom\'s legal rights or investigate fraud';

  @override
  String get privacyPolicySection3Point13 => 'e) Business Transfers';

  @override
  String get privacyPolicySection3Point14 =>
      'In the event of a merger, acquisition, or reorganization of Bosdom, user data may be transferred with equivalent privacy protection commitments';

  @override
  String get privacyPolicySection4Title => '4. Data Storage & Security';

  @override
  String get privacyPolicySection4Point1 =>
      'Your data is stored securely using Supabase infrastructure, which provides:';

  @override
  String get privacyPolicySection4Point2 =>
      'Encryption of data in transit (TLS/SSL) and at rest';

  @override
  String get privacyPolicySection4Point3 =>
      'Secure authentication and session management';

  @override
  String get privacyPolicySection4Point4 =>
      'Access controls and regular security audits with vulnerability assessments';

  @override
  String get privacyPolicySection4Point5 =>
      'Escrow payment information is protected using PCI-compliant payment gateway standards.';

  @override
  String get privacyPolicySection4Point6 =>
      'Chat conversations and dispute evidence are encrypted and access-restricted to relevant parties.';

  @override
  String get privacyPolicySection4Point7 =>
      'While we implement industry-standard security measures, no method of electronic transmission or storage is 100% secure.';

  @override
  String get privacyPolicySection5Title => '5. Data Retention';

  @override
  String get privacyPolicySection5Point1 =>
      'We retain your personal data only for as long as necessary to fulfill the purposes outlined in this policy:';

  @override
  String get privacyPolicySection5Point2 =>
      'Account Data: retained while your account is active and for up to 12 months after deletion';

  @override
  String get privacyPolicySection5Point3 =>
      'Transaction Records: retained for 5 years for accounting and legal compliance';

  @override
  String get privacyPolicySection5Point4 =>
      'Chat Messages: retained for 12 months';

  @override
  String get privacyPolicySection5Point5 =>
      'Dispute Evidence: retained for 12 months after resolution';

  @override
  String get privacyPolicySection5Point6 =>
      'You may request account deletion at any time by contacting support or using the in-app support feature.';

  @override
  String get privacyPolicySection6Title => '6. Your Privacy Rights';

  @override
  String get privacyPolicySection6Point1 =>
      'As a Bosdom user, you have the right to:';

  @override
  String get privacyPolicySection6Point2 =>
      'Access: request a copy of the personal data we hold about you';

  @override
  String get privacyPolicySection6Point3 =>
      'Correction: update inaccurate or outdated information';

  @override
  String get privacyPolicySection6Point4 =>
      'Deletion: request deletion of your personal data, subject to legal retention requirements';

  @override
  String get privacyPolicySection6Point5 =>
      'Data Portability: request your data in a machine-readable format';

  @override
  String get privacyPolicySection6Point6 =>
      'Notification Preferences: manage notification settings within the app';

  @override
  String get privacyPolicySection6Point7 =>
      'Opt-Out: opt out of marketing communications at any time';

  @override
  String get privacyPolicySection6Point8 =>
      'To exercise these rights, contact us at privacy@bosdom.com or via the in-app Support section.';

  @override
  String get privacyPolicySection7Title => '7. Chat & Communication Privacy';

  @override
  String get privacyPolicySection7Point1 =>
      'All in-app chat messages are stored securely and only accessible to conversation participants.';

  @override
  String get privacyPolicySection7Point2 =>
      'Bosdom automatically monitors chat content for off-platform contact detection and scam prevention purposes only.';

  @override
  String get privacyPolicySection7Point3 =>
      'Flagged messages may be reviewed manually by our Trust & Safety team.';

  @override
  String get privacyPolicySection7Point4 =>
      'Soliciting direct contact information through chat may result in account restrictions or bans as outlined in our Terms & Conditions.';

  @override
  String get privacyPolicySection8Title => '8. Children\'s Privacy';

  @override
  String get privacyPolicySection8Point1 =>
      'Bosdom is a B2B wholesale marketplace intended for use by verified business users aged 18 and above. We do not knowingly collect data from minors.';

  @override
  String get privacyPolicySection9Title => '9. Changes to This Policy';

  @override
  String get privacyPolicySection9Point1 =>
      'We may update this Privacy Policy periodically to reflect changes in our practices, legal requirements, or platform features. Material changes will be communicated via:';

  @override
  String get privacyPolicySection9Point2 => 'A prominent notice within the app';

  @override
  String get privacyPolicySection9Point3 =>
      'Email notification to registered users';

  @override
  String get privacyPolicySection9Point4 => 'An updated \"Last Modified\" date';

  @override
  String get privacyPolicyContactTitle => 'Contact Us';

  @override
  String get privacyPolicyContactIntro =>
      'For privacy-related questions or concerns, please contact:';

  @override
  String get privacyPolicyContactEmail => 'privacy@bosdom.com';

  @override
  String get privacyPolicyContactInApp => 'In-app: Support & Report an Issue';

  @override
  String get privacyPolicyContactLocation => 'Cambodia';

  @override
  String get aboutScreenTitle => 'About Bosdom';

  @override
  String get aboutAppTagline =>
      'The Automated B2B Wholesale Trust Market & Social Co-Buying Network';

  @override
  String aboutVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutMissionTitle => 'Our Mission';

  @override
  String get aboutMissionBody =>
      'Bosdom connects verified Cambodian retailers with trusted wholesalers through a secure digital procurement ecosystem featuring sample testing, social co-buying, automated escrow, and real-time chat.';

  @override
  String get aboutWhyChooseTitle => 'Why Choose Bosdom?';

  @override
  String get aboutFeatureSampleTestingTitle => 'Sample Testing';

  @override
  String get aboutFeatureSampleTestingBody =>
      'Try before you bulk buy to ensure quality.';

  @override
  String get aboutFeatureCoBuyTitle => 'Co-Buy Network';

  @override
  String get aboutFeatureCoBuyBody =>
      'Pool orders for direct volume discount prices.';

  @override
  String get aboutFeatureEscrowTitle => 'Escrow Protection';

  @override
  String get aboutFeatureEscrowBody => 'Secure automated payments on delivery.';

  @override
  String get aboutFeatureChatTitle => 'Real-Time Chat';

  @override
  String get aboutFeatureChatBody =>
      'Direct instant supplier communication channel.';

  @override
  String get aboutOfferTitle => 'What We Offer';

  @override
  String get aboutOfferItem1 => 'Wholesale Marketplace';

  @override
  String get aboutOfferItem2 => 'Volume-tiered pricing models';

  @override
  String get aboutOfferItem3 => 'Secure QR verification system';

  @override
  String get aboutOfferItem4 => 'Anti-scam media evidence lockers';

  @override
  String get aboutOfferItem5 => 'Social invite links';

  @override
  String get aboutOfferItem6 => 'Instant push notifications';

  @override
  String get aboutCompanyInfoTitle => 'Company Information';

  @override
  String get aboutCompanyHeadquartersLabel => 'HEADQUARTERS';

  @override
  String get aboutCompanyHeadquartersValue => 'Phnom Penh, Cambodia';

  @override
  String get aboutCompanyEmailLabel => 'CONTACT EMAIL';

  @override
  String get aboutCompanyEmailValue => 'support@bosdom.com';

  @override
  String get aboutCompanyWebsiteLabel => 'WEBSITE';

  @override
  String get aboutCompanyWebsiteValue => 'www.bosdom.com';

  @override
  String get aboutStoryTitle => 'Our Story';

  @override
  String get aboutStoryBody =>
      'Founded to solve trust deficiencies in Cambodia\'s B2B retail supply chain, Bosdom deploys an independent secure digital procurement ecosystem to empower small-to-medium retail owners.';

  @override
  String get aboutStatRetailers => 'Retailers';

  @override
  String get aboutStatSuppliers => 'Suppliers';

  @override
  String get aboutStatSuccessRate => 'Success Rate';

  @override
  String get aboutValuesTitle => 'Our Values';

  @override
  String get aboutValueTrustTitle => 'Trust & Transparency';

  @override
  String get aboutValueRetailerFirstTitle => 'Retailer First';

  @override
  String get aboutValueInnovationTitle => 'Innovation';

  @override
  String get aboutFooterCopyright => '© 2024-2026 Bosdom. All rights reserved.';

  @override
  String get variantSelectOptionsTitle => 'Select Options';

  @override
  String get variantSizeLabel => 'Size';

  @override
  String get variantColorLabel => 'Color';
}
