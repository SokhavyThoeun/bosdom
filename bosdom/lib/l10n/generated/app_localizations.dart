import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BosDom'**
  String get appTitle;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get commonSaveChanges;

  /// No description provided for @commonSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get commonSaved;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get commonSeeAll;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{label} coming soon'**
  String commonComingSoon(String label);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get navWishlist;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @languageScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageScreenTitle;

  /// No description provided for @languageScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the Bosdom app.'**
  String get languageScreenIntro;

  /// No description provided for @languageSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SELECT LANGUAGE'**
  String get languageSectionLabel;

  /// No description provided for @languageEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishLabel;

  /// No description provided for @languageEnglishSublabel.
  ///
  /// In en, this message translates to:
  /// **'Default language'**
  String get languageEnglishSublabel;

  /// No description provided for @languageKhmerLabel.
  ///
  /// In en, this message translates to:
  /// **'ភាសាខ្មែរ (Khmer)'**
  String get languageKhmerLabel;

  /// No description provided for @languageKhmerSublabel.
  ///
  /// In en, this message translates to:
  /// **'Cambodian language'**
  String get languageKhmerSublabel;

  /// No description provided for @languageNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Note'**
  String get languageNoteTitle;

  /// No description provided for @languageNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Changing the language will restart the app interface. Some supplier content may remain in its original language.'**
  String get languageNoteBody;

  /// No description provided for @languageSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Language set to {language}'**
  String languageSavedSnackbar(String language);

  /// No description provided for @authLoginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get authLoginEmailLabel;

  /// No description provided for @authLoginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authLoginEmailHint;

  /// No description provided for @authLoginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authLoginPasswordLabel;

  /// No description provided for @authLoginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authLoginPasswordHint;

  /// No description provided for @authLoginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authLoginForgotPassword;

  /// No description provided for @authLoginPasswordResetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset coming soon'**
  String get authLoginPasswordResetComingSoon;

  /// No description provided for @authLoginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginSignInButton;

  /// No description provided for @authLoginOrSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or Sign Up with'**
  String get authLoginOrSignUpWith;

  /// No description provided for @authLoginGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authLoginGoogleButton;

  /// No description provided for @authLoginNewMerchantPrompt.
  ///
  /// In en, this message translates to:
  /// **'New merchant? '**
  String get authLoginNewMerchantPrompt;

  /// No description provided for @authLoginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authLoginCreateAccount;

  /// No description provided for @authLoginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back\nMerchant'**
  String get authLoginWelcomeTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your wholesale account'**
  String get authLoginSubtitle;

  /// No description provided for @authSignupJoiningPrompt.
  ///
  /// In en, this message translates to:
  /// **'I am joining BosDom as a...'**
  String get authSignupJoiningPrompt;

  /// No description provided for @authSignupChooseRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get authSignupChooseRoleTitle;

  /// No description provided for @authSignupStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of {total}'**
  String authSignupStepLabel(String total);

  /// No description provided for @authBusinessInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Info'**
  String get authBusinessInfoTitle;

  /// No description provided for @authBusinessInfoStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String authBusinessInfoStepLabel(String current, String total);

  /// No description provided for @authBusinessInfoShopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'SHOP / BUSINESS NAME'**
  String get authBusinessInfoShopNameLabel;

  /// No description provided for @authBusinessInfoShopNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Angkor Wholesale Co.'**
  String get authBusinessInfoShopNameHint;

  /// No description provided for @authBusinessInfoStoreTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'TYPE OF STORE'**
  String get authBusinessInfoStoreTypeLabel;

  /// No description provided for @authBusinessInfoStoreTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get authBusinessInfoStoreTypeHint;

  /// No description provided for @authBusinessInfoStoreTypePhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical Store'**
  String get authBusinessInfoStoreTypePhysical;

  /// No description provided for @authBusinessInfoStoreTypeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online Store'**
  String get authBusinessInfoStoreTypeOnline;

  /// No description provided for @authBusinessInfoStoreTypeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both Physical & Online'**
  String get authBusinessInfoStoreTypeBoth;

  /// No description provided for @authBusinessInfoStorePhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'STORE PHOTOS'**
  String get authBusinessInfoStorePhotosLabel;

  /// No description provided for @authBusinessInfoPhotosUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload store photos'**
  String get authBusinessInfoPhotosUploadTitle;

  /// No description provided for @authBusinessInfoPhotosUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Physical store or online store screenshots)'**
  String get authBusinessInfoPhotosUploadSubtitle;

  /// No description provided for @authBusinessInfoStoreUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'ONLINE STORE URL (OPTIONAL)'**
  String get authBusinessInfoStoreUrlLabel;

  /// No description provided for @authBusinessInfoStoreUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. facebook.com/yourshop'**
  String get authBusinessInfoStoreUrlHint;

  /// No description provided for @authBusinessInfoProvinceLabel.
  ///
  /// In en, this message translates to:
  /// **'PROVINCE / CITY'**
  String get authBusinessInfoProvinceLabel;

  /// No description provided for @authBusinessInfoProvinceHint.
  ///
  /// In en, this message translates to:
  /// **'Select province...'**
  String get authBusinessInfoProvinceHint;

  /// No description provided for @authBusinessInfoProvincePhnomPenh.
  ///
  /// In en, this message translates to:
  /// **'Phnom Penh'**
  String get authBusinessInfoProvincePhnomPenh;

  /// No description provided for @authBusinessInfoProvinceKandal.
  ///
  /// In en, this message translates to:
  /// **'Kandal'**
  String get authBusinessInfoProvinceKandal;

  /// No description provided for @authBusinessInfoProvinceSiemReap.
  ///
  /// In en, this message translates to:
  /// **'Siem Reap'**
  String get authBusinessInfoProvinceSiemReap;

  /// No description provided for @authBusinessInfoProvinceBattambang.
  ///
  /// In en, this message translates to:
  /// **'Battambang'**
  String get authBusinessInfoProvinceBattambang;

  /// No description provided for @authBusinessInfoProvinceKampongCham.
  ///
  /// In en, this message translates to:
  /// **'Kampong Cham'**
  String get authBusinessInfoProvinceKampongCham;

  /// No description provided for @authBusinessInfoProvincePreahSihanouk.
  ///
  /// In en, this message translates to:
  /// **'Preah Sihanouk'**
  String get authBusinessInfoProvincePreahSihanouk;

  /// No description provided for @authBusinessInfoDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'DISTRICT / SANGKAT'**
  String get authBusinessInfoDistrictLabel;

  /// No description provided for @authBusinessInfoDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Select district...'**
  String get authBusinessInfoDistrictHint;

  /// No description provided for @authBusinessInfoDistrictChamkarmon.
  ///
  /// In en, this message translates to:
  /// **'Khan Chamkarmon'**
  String get authBusinessInfoDistrictChamkarmon;

  /// No description provided for @authBusinessInfoDistrictToulKork.
  ///
  /// In en, this message translates to:
  /// **'Khan Toul Kork'**
  String get authBusinessInfoDistrictToulKork;

  /// No description provided for @authBusinessInfoDistrictSenSok.
  ///
  /// In en, this message translates to:
  /// **'Khan Sen Sok'**
  String get authBusinessInfoDistrictSenSok;

  /// No description provided for @authBusinessInfoDistrictBoengKengKang.
  ///
  /// In en, this message translates to:
  /// **'Khan Boeng Keng Kang'**
  String get authBusinessInfoDistrictBoengKengKang;

  /// No description provided for @authBusinessInfoDistrictOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get authBusinessInfoDistrictOther;

  /// No description provided for @authBusinessInfoStreetAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'STREET ADDRESS'**
  String get authBusinessInfoStreetAddressLabel;

  /// No description provided for @authBusinessInfoStreetAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Street 271, Phnom Penh'**
  String get authBusinessInfoStreetAddressHint;

  /// No description provided for @authBusinessInfoAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to BosDom\'s '**
  String get authBusinessInfoAgreementPrefix;

  /// No description provided for @authBusinessInfoAgreementTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authBusinessInfoAgreementTermsLink;

  /// No description provided for @authBusinessInfoAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **' and confirm I am a registered business merchant in Cambodia.'**
  String get authBusinessInfoAgreementSuffix;

  /// No description provided for @authBusinessInfoSellerBadgePrefix.
  ///
  /// In en, this message translates to:
  /// **'Your '**
  String get authBusinessInfoSellerBadgePrefix;

  /// No description provided for @authBusinessInfoSellerBadgeLink.
  ///
  /// In en, this message translates to:
  /// **'Seller badge'**
  String get authBusinessInfoSellerBadgeLink;

  /// No description provided for @authBusinessInfoSellerBadgeSuffix.
  ///
  /// In en, this message translates to:
  /// **' activates immediately. You can start listing products right away!'**
  String get authBusinessInfoSellerBadgeSuffix;

  /// No description provided for @authBusinessInfoCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create my Account'**
  String get authBusinessInfoCreateAccountButton;

  /// No description provided for @authDeliveryAddressStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get authDeliveryAddressStepTitle;

  /// No description provided for @authDeliveryAddressStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String authDeliveryAddressStepLabel(String current, String total);

  /// No description provided for @authDeliveryAddressIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Delivery Address'**
  String get authDeliveryAddressIntroTitle;

  /// No description provided for @authDeliveryAddressIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your delivery address below.'**
  String get authDeliveryAddressIntroBody;

  /// No description provided for @authDeliveryAddressHouseLabel.
  ///
  /// In en, this message translates to:
  /// **'HOUSE / STREET NUMBER'**
  String get authDeliveryAddressHouseLabel;

  /// No description provided for @authDeliveryAddressHouseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. #12, Street 271'**
  String get authDeliveryAddressHouseHint;

  /// No description provided for @authDeliveryAddressSangkatLabel.
  ///
  /// In en, this message translates to:
  /// **'SANGKAT / DISTRICT'**
  String get authDeliveryAddressSangkatLabel;

  /// No description provided for @authDeliveryAddressSangkatHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sangkat Tomnob Tuek'**
  String get authDeliveryAddressSangkatHint;

  /// No description provided for @authDeliveryAddressProvinceLabel.
  ///
  /// In en, this message translates to:
  /// **'PROVINCE / CITY'**
  String get authDeliveryAddressProvinceLabel;

  /// No description provided for @authDeliveryAddressProvinceHint.
  ///
  /// In en, this message translates to:
  /// **'Select province...'**
  String get authDeliveryAddressProvinceHint;

  /// No description provided for @authDeliveryAddressProvincePhnomPenh.
  ///
  /// In en, this message translates to:
  /// **'Phnom Penh'**
  String get authDeliveryAddressProvincePhnomPenh;

  /// No description provided for @authDeliveryAddressProvinceKandal.
  ///
  /// In en, this message translates to:
  /// **'Kandal'**
  String get authDeliveryAddressProvinceKandal;

  /// No description provided for @authDeliveryAddressProvinceSiemReap.
  ///
  /// In en, this message translates to:
  /// **'Siem Reap'**
  String get authDeliveryAddressProvinceSiemReap;

  /// No description provided for @authDeliveryAddressProvinceBattambang.
  ///
  /// In en, this message translates to:
  /// **'Battambang'**
  String get authDeliveryAddressProvinceBattambang;

  /// No description provided for @authDeliveryAddressProvinceKampongCham.
  ///
  /// In en, this message translates to:
  /// **'Kampong Cham'**
  String get authDeliveryAddressProvinceKampongCham;

  /// No description provided for @authDeliveryAddressProvincePreahSihanouk.
  ///
  /// In en, this message translates to:
  /// **'Preah Sihanouk'**
  String get authDeliveryAddressProvincePreahSihanouk;

  /// No description provided for @authDeliveryAddressLandmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'NEAREST LANDMARK (OPTIONAL)'**
  String get authDeliveryAddressLandmarkLabel;

  /// No description provided for @authDeliveryAddressLandmarkHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Near Lucky Mall'**
  String get authDeliveryAddressLandmarkHint;

  /// No description provided for @authDeliveryAddressAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to BosDom\'s '**
  String get authDeliveryAddressAgreementPrefix;

  /// No description provided for @authDeliveryAddressAgreementTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authDeliveryAddressAgreementTermsLink;

  /// No description provided for @authDeliveryAddressAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **' and confirm I am a merchant in Cambodia.'**
  String get authDeliveryAddressAgreementSuffix;

  /// No description provided for @authDeliveryAddressVerificationPrefix.
  ///
  /// In en, this message translates to:
  /// **'You can start browsing and buying immediately. Optionally upload your business ID later in '**
  String get authDeliveryAddressVerificationPrefix;

  /// No description provided for @authDeliveryAddressVerificationProfileLink.
  ///
  /// In en, this message translates to:
  /// **'Profile → Verification'**
  String get authDeliveryAddressVerificationProfileLink;

  /// No description provided for @authDeliveryAddressVerificationMiddle.
  ///
  /// In en, this message translates to:
  /// **' to unlock the '**
  String get authDeliveryAddressVerificationMiddle;

  /// No description provided for @authDeliveryAddressVerificationBadgeLink.
  ///
  /// In en, this message translates to:
  /// **'Verified Buyer'**
  String get authDeliveryAddressVerificationBadgeLink;

  /// No description provided for @authDeliveryAddressVerificationSuffix.
  ///
  /// In en, this message translates to:
  /// **' badge.'**
  String get authDeliveryAddressVerificationSuffix;

  /// No description provided for @authDeliveryAddressCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create My Account'**
  String get authDeliveryAddressCreateAccountButton;

  /// No description provided for @authPersonalDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get authPersonalDetailsTitle;

  /// No description provided for @authPersonalDetailsStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String authPersonalDetailsStepLabel(String current, String total);

  /// No description provided for @authPersonalDetailsFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get authPersonalDetailsFullNameLabel;

  /// No description provided for @authPersonalDetailsFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get authPersonalDetailsFullNameHint;

  /// No description provided for @authPersonalDetailsPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER (+855)'**
  String get authPersonalDetailsPhoneLabel;

  /// No description provided for @authPersonalDetailsPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'012 345 678'**
  String get authPersonalDetailsPhoneHint;

  /// No description provided for @authPersonalDetailsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL (OPTIONAL)'**
  String get authPersonalDetailsEmailLabel;

  /// No description provided for @authPersonalDetailsEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authPersonalDetailsEmailHint;

  /// No description provided for @authPersonalDetailsPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authPersonalDetailsPasswordLabel;

  /// No description provided for @authPersonalDetailsPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get authPersonalDetailsPasswordHint;

  /// No description provided for @authPersonalDetailsConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get authPersonalDetailsConfirmPasswordLabel;

  /// No description provided for @authPersonalDetailsConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authPersonalDetailsConfirmPasswordHint;

  /// No description provided for @authUploadDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get authUploadDocumentsTitle;

  /// No description provided for @authUploadDocumentsStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String authUploadDocumentsStepLabel(String current, String total);

  /// No description provided for @authUploadDocumentsIdentityBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get authUploadDocumentsIdentityBannerTitle;

  /// No description provided for @authUploadDocumentsIdentityBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID for identity on file. Your Seller badge activates immediately no admin confirmation needed.'**
  String get authUploadDocumentsIdentityBannerBody;

  /// No description provided for @authUploadDocumentsNationalIdTitle.
  ///
  /// In en, this message translates to:
  /// **'National ID Card'**
  String get authUploadDocumentsNationalIdTitle;

  /// No description provided for @authUploadDocumentsNationalIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Front and back of your Cambodian National ID'**
  String get authUploadDocumentsNationalIdSubtitle;

  /// No description provided for @authUploadDocumentsPassportTitle.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get authUploadDocumentsPassportTitle;

  /// No description provided for @authUploadDocumentsPassportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alternative to National ID (optional)'**
  String get authUploadDocumentsPassportSubtitle;

  /// No description provided for @authUploadDocumentsBusinessCertTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Certificate'**
  String get authUploadDocumentsBusinessCertTitle;

  /// No description provided for @authUploadDocumentsBusinessCertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MOC registration certificate (optional but speeds up verification)'**
  String get authUploadDocumentsBusinessCertSubtitle;

  /// No description provided for @authUploadDocumentsRequiredMarker.
  ///
  /// In en, this message translates to:
  /// **' *'**
  String get authUploadDocumentsRequiredMarker;

  /// No description provided for @authUploadDocumentsOptionalMarker.
  ///
  /// In en, this message translates to:
  /// **' (optional)'**
  String get authUploadDocumentsOptionalMarker;

  /// No description provided for @authUploadDocumentsUploadedLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get authUploadDocumentsUploadedLabel;

  /// No description provided for @authUploadDocumentsTapToUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to Upload'**
  String get authUploadDocumentsTapToUploadLabel;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Cambodia\'s Trusted\nWholesale Network'**
  String get splashTagline;

  /// No description provided for @splashBadgeVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get splashBadgeVerified;

  /// No description provided for @splashBadgeSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get splashBadgeSecure;

  /// No description provided for @splashBadgeWholesale.
  ///
  /// In en, this message translates to:
  /// **'Wholesale'**
  String get splashBadgeWholesale;

  /// No description provided for @splashGetStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get splashGetStartedButton;

  /// No description provided for @splashLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get splashLoginPrompt;

  /// No description provided for @splashFooterNote.
  ///
  /// In en, this message translates to:
  /// **'For registered Cambodian merchants only'**
  String get splashFooterNote;

  /// No description provided for @sampleGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy sample'**
  String get sampleGateTitle;

  /// No description provided for @sampleGateBody.
  ///
  /// In en, this message translates to:
  /// **'1-per-account sample purchase flow. UI comes in phase 4'**
  String get sampleGateBody;

  /// No description provided for @cartMovedToWishlistSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{productName} moved to wishlist'**
  String cartMovedToWishlistSnackbar(String productName);

  /// No description provided for @cartProceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cartProceedToCheckout;

  /// No description provided for @cartScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get cartScreenTitle;

  /// No description provided for @cartSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get cartSelectAll;

  /// No description provided for @cartItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cartItemsCount(int count);

  /// No description provided for @cartWishlistAction.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get cartWishlistAction;

  /// No description provided for @cartUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit: {price}'**
  String cartUnitPrice(String price);

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartEstimatedShipping.
  ///
  /// In en, this message translates to:
  /// **'Estimated Shipping'**
  String get cartEstimatedShipping;

  /// No description provided for @cartEscrowFee.
  ///
  /// In en, this message translates to:
  /// **'Escrow Fee (2%)'**
  String get cartEscrowFee;

  /// No description provided for @cartTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get cartTotalAmount;

  /// No description provided for @cartEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyState;

  /// No description provided for @checkoutDeliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get checkoutDeliveryAddressLabel;

  /// No description provided for @checkoutOrderItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get checkoutOrderItemsLabel;

  /// No description provided for @checkoutItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String checkoutItemsCount(int count);

  /// No description provided for @checkoutShippingMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping Method'**
  String get checkoutShippingMethodLabel;

  /// No description provided for @checkoutShippingUnavailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Not available for this weight/address'**
  String get checkoutShippingUnavailableLabel;

  /// No description provided for @checkoutEscrowNotice.
  ///
  /// In en, this message translates to:
  /// **'Funds held in escrow until delivery confirmed.'**
  String get checkoutEscrowNotice;

  /// No description provided for @checkoutContinueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get checkoutContinueToPayment;

  /// No description provided for @checkoutScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutScreenTitle;

  /// No description provided for @checkoutNoAddressYet.
  ///
  /// In en, this message translates to:
  /// **'No delivery address yet'**
  String get checkoutNoAddressYet;

  /// No description provided for @checkoutChangeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get checkoutChangeAddress;

  /// No description provided for @checkoutOrderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get checkoutOrderSummaryTitle;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get checkoutShippingLabel;

  /// No description provided for @checkoutEscrowFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Escrow Fee (2%)'**
  String get checkoutEscrowFeeLabel;

  /// No description provided for @checkoutTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get checkoutTotalAmount;

  /// No description provided for @checkoutStepCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get checkoutStepCart;

  /// No description provided for @checkoutStepCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutStepCheckout;

  /// No description provided for @checkoutStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get checkoutStepPayment;

  /// No description provided for @addressLabelFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS LABEL'**
  String get addressLabelFieldLabel;

  /// No description provided for @addressLabelFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Warehouse, Shop'**
  String get addressLabelFieldHint;

  /// No description provided for @addressHouseFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'HOUSE / STREET NUMBER'**
  String get addressHouseFieldLabel;

  /// No description provided for @addressHouseFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Building B, Zone 3, Veng Sreng Blvd'**
  String get addressHouseFieldHint;

  /// No description provided for @addressSangkatFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'SANGKAT / DISTRICT'**
  String get addressSangkatFieldLabel;

  /// No description provided for @addressSangkatFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sangkat Choam Chao'**
  String get addressSangkatFieldHint;

  /// No description provided for @addressLandmarkFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'NEAREST LANDMARK (OPTIONAL)'**
  String get addressLandmarkFieldLabel;

  /// No description provided for @addressLandmarkFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Next to Veng Sreng Canopy'**
  String get addressLandmarkFieldHint;

  /// No description provided for @addressPhoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT PHONE NUMBER'**
  String get addressPhoneFieldLabel;

  /// No description provided for @addressPhoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +855 76 227 5858'**
  String get addressPhoneFieldHint;

  /// No description provided for @addressProvinceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'PROVINCE / CITY'**
  String get addressProvinceFieldLabel;

  /// No description provided for @addressProvinceFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Select province...'**
  String get addressProvinceFieldHint;

  /// No description provided for @addressFieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get addressFieldRequiredError;

  /// No description provided for @addressSetDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Set as Default Address'**
  String get addressSetDefaultTitle;

  /// No description provided for @addressSetDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deliver all primary orders here'**
  String get addressSetDefaultSubtitle;

  /// No description provided for @addressSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get addressSaveButton;

  /// No description provided for @addressAddScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addressAddScreenTitle;

  /// No description provided for @addressBookSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap an address to deliver here'**
  String get addressBookSelectionSubtitle;

  /// No description provided for @addressAddNewButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addressAddNewButton;

  /// No description provided for @addressBookScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Address Book'**
  String get addressBookScreenTitle;

  /// No description provided for @addressDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get addressDefaultBadge;

  /// No description provided for @storeAddressBookScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Addresses'**
  String get storeAddressBookScreenTitle;

  /// No description provided for @storeAddressAddNewButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Store Address'**
  String get storeAddressAddNewButton;

  /// No description provided for @storeAddressAddScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Store Address'**
  String get storeAddressAddScreenTitle;

  /// No description provided for @storeAddressLabelFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS LABEL'**
  String get storeAddressLabelFieldLabel;

  /// No description provided for @storeAddressLabelFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Phnom Penh Headquarters'**
  String get storeAddressLabelFieldHint;

  /// No description provided for @storeAddressNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'STORE / BUSINESS NAME'**
  String get storeAddressNameFieldLabel;

  /// No description provided for @storeAddressNameFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Angkor Artisans Store'**
  String get storeAddressNameFieldHint;

  /// No description provided for @storeAddressBusinessTypeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS TYPE'**
  String get storeAddressBusinessTypeFieldLabel;

  /// No description provided for @storeAddressBusinessTypeFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Wholesale & Manufacturer'**
  String get storeAddressBusinessTypeFieldHint;

  /// No description provided for @storeAddressFullAddressFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL ADDRESS'**
  String get storeAddressFullAddressFieldLabel;

  /// No description provided for @storeAddressFullAddressFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. No. 124, Street 271, Sangkat Boeung Salang'**
  String get storeAddressFullAddressFieldHint;

  /// No description provided for @storeAddressDistrictFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'SANGKAT / DISTRICT'**
  String get storeAddressDistrictFieldLabel;

  /// No description provided for @storeAddressDistrictFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sangkat Teuk Thla'**
  String get storeAddressDistrictFieldHint;

  /// No description provided for @storeAddressProvinceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'PROVINCE / CITY'**
  String get storeAddressProvinceFieldLabel;

  /// No description provided for @storeAddressProvinceFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Phnom Penh'**
  String get storeAddressProvinceFieldHint;

  /// No description provided for @storeAddressPhoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT PHONE NUMBER'**
  String get storeAddressPhoneFieldLabel;

  /// No description provided for @storeAddressPhoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +855 76 227 5858'**
  String get storeAddressPhoneFieldHint;

  /// No description provided for @storeAddressEmailFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT EMAIL'**
  String get storeAddressEmailFieldLabel;

  /// No description provided for @storeAddressEmailFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. orders@angkorartisans.com'**
  String get storeAddressEmailFieldHint;

  /// No description provided for @storeAddressHoursFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'OPERATING HOURS'**
  String get storeAddressHoursFieldLabel;

  /// No description provided for @storeAddressHoursFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mon - Fri: 8:00 AM - 5:30 PM'**
  String get storeAddressHoursFieldHint;

  /// No description provided for @storeAddressFieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get storeAddressFieldRequiredError;

  /// No description provided for @storeAddressEmailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get storeAddressEmailInvalidError;

  /// No description provided for @storeAddressSetDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Set as Default Store Address'**
  String get storeAddressSetDefaultTitle;

  /// No description provided for @storeAddressSetDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ship and dispatch all primary orders from here'**
  String get storeAddressSetDefaultSubtitle;

  /// No description provided for @storeAddressSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Store Address'**
  String get storeAddressSaveButton;

  /// No description provided for @storeAddressDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get storeAddressDefaultBadge;

  /// No description provided for @storeAddressEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No store addresses yet. Add one to start shipping from a fixed location.'**
  String get storeAddressEmptyState;

  /// No description provided for @chatScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatScreenTitle;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get chatSearchHint;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyQuery.
  ///
  /// In en, this message translates to:
  /// **'No conversations match \"{query}\"'**
  String chatEmptyQuery(String query);

  /// No description provided for @chatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load conversations'**
  String get chatLoadError;

  /// No description provided for @chatDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this conversation'**
  String get chatDetailLoadError;

  /// No description provided for @chatMessageSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get chatMessageSending;

  /// No description provided for @chatSendError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send message. Try again.'**
  String get chatSendError;

  /// No description provided for @chatStartConversationError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the conversation. Try again.'**
  String get chatStartConversationError;

  /// No description provided for @chatRestrictedError.
  ///
  /// In en, this message translates to:
  /// **'You\'re temporarily restricted from sending messages until {until}.'**
  String chatRestrictedError(String until);

  /// No description provided for @chatPolicySecurePayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay only through Bosdom Secure Pay'**
  String get chatPolicySecurePayTitle;

  /// No description provided for @chatPolicyBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Direct payments to the seller outside the app aren\'t covered by Bosdom\'s buyer protection. Keep transactions in Secure Pay to stay protected.'**
  String get chatPolicyBannerBody;

  /// No description provided for @chatFlaggedBadge.
  ///
  /// In en, this message translates to:
  /// **'Off-platform contact flagged'**
  String get chatFlaggedBadge;

  /// No description provided for @chatOffPlatformWarning.
  ///
  /// In en, this message translates to:
  /// **'This message may share contact info or arrange a deal outside Bosdom: you won\'t be covered by buyer protection.'**
  String get chatOffPlatformWarning;

  /// No description provided for @chatPhotoAttachmentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Photo attachment coming soon'**
  String get chatPhotoAttachmentComingSoon;

  /// No description provided for @chatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatComposerHint;

  /// No description provided for @chatAttachPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get chatAttachPhotoCamera;

  /// No description provided for @chatAttachPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chatAttachPhotoGallery;

  /// No description provided for @liveChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChatTitle;

  /// No description provided for @liveChatStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online • Usually replies instantly'**
  String get liveChatStatusOnline;

  /// No description provided for @liveChatStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline • We\'ll reply as soon as we\'re back'**
  String get liveChatStatusOffline;

  /// No description provided for @liveChatSecurityNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Notice'**
  String get liveChatSecurityNoticeTitle;

  /// No description provided for @liveChatSecurityNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Only make payments via Bosdom\'s official secure portal. Support will never ask for direct bank transfers in chat.'**
  String get liveChatSecurityNoticeBody;

  /// No description provided for @liveChatSuggestedTopicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested topics'**
  String get liveChatSuggestedTopicsLabel;

  /// No description provided for @liveChatTopicOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get liveChatTopicOrderStatus;

  /// No description provided for @liveChatTopicOrderStatusMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'d like an update on my order status.'**
  String get liveChatTopicOrderStatusMessage;

  /// No description provided for @liveChatTopicPaymentIssue.
  ///
  /// In en, this message translates to:
  /// **'Payment Issue'**
  String get liveChatTopicPaymentIssue;

  /// No description provided for @liveChatTopicPaymentIssueMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m having an issue with a payment.'**
  String get liveChatTopicPaymentIssueMessage;

  /// No description provided for @liveChatTopicRefundReturn.
  ///
  /// In en, this message translates to:
  /// **'Refund / Return'**
  String get liveChatTopicRefundReturn;

  /// No description provided for @liveChatTopicRefundReturnMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'d like to request a refund or return.'**
  String get liveChatTopicRefundReturnMessage;

  /// No description provided for @liveChatTopicShippingRates.
  ///
  /// In en, this message translates to:
  /// **'Shipping Rates'**
  String get liveChatTopicShippingRates;

  /// No description provided for @liveChatTopicShippingRatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, can you tell me more about your shipping rates?'**
  String get liveChatTopicShippingRatesMessage;

  /// No description provided for @chatPolicyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load chat settings: {error}'**
  String chatPolicyLoadError(String error);

  /// No description provided for @chatPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'Before you start chatting with buyers and sellers on Bosdom, please read and accept the terms below.'**
  String get chatPolicyIntro;

  /// No description provided for @chatPolicySecurePayBody.
  ///
  /// In en, this message translates to:
  /// **'Payments made outside the app are not covered by Bosdom\'s buyer protection or dispute resolution.'**
  String get chatPolicySecurePayBody;

  /// No description provided for @chatPolicyFlaggedTitle.
  ///
  /// In en, this message translates to:
  /// **'Off-platform deals are flagged'**
  String get chatPolicyFlaggedTitle;

  /// No description provided for @chatPolicyFlaggedBody.
  ///
  /// In en, this message translates to:
  /// **'Messages sharing phone numbers or third-party contact apps are automatically flagged for review.'**
  String get chatPolicyFlaggedBody;

  /// No description provided for @chatPolicyLiableTitle.
  ///
  /// In en, this message translates to:
  /// **'You are liable for what you send'**
  String get chatPolicyLiableTitle;

  /// No description provided for @chatPolicyLiableBody.
  ///
  /// In en, this message translates to:
  /// **'Bosdom is not responsible for losses from deals arranged outside the platform or against these terms.'**
  String get chatPolicyLiableBody;

  /// No description provided for @chatPolicyHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat & Trading Policy'**
  String get chatPolicyHeaderTitle;

  /// No description provided for @chatPolicyAgreementText.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Bosdom Chat Policy and Terms of Service.'**
  String get chatPolicyAgreementText;

  /// No description provided for @chatPolicyContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Chat'**
  String get chatPolicyContinueButton;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsScreenTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load notifications'**
  String get notificationsLoadError;

  /// No description provided for @notificationsPushTitle.
  ///
  /// In en, this message translates to:
  /// **'Push notification'**
  String get notificationsPushTitle;

  /// No description provided for @notificationsPushBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to hear about: weekly sales, exclusive offers, hot promotions and more'**
  String get notificationsPushBody;

  /// No description provided for @dataPrivacyContactBanner.
  ///
  /// In en, this message translates to:
  /// **'Get in touch to manage your data'**
  String get dataPrivacyContactBanner;

  /// No description provided for @dataPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Request access, correction, or deletion of your personal data. Contact our privacy team for any data-related inquiries.'**
  String get dataPrivacyBody;

  /// No description provided for @dataPrivacyContactButton.
  ///
  /// In en, this message translates to:
  /// **'Contact Privacy Team'**
  String get dataPrivacyContactButton;

  /// No description provided for @dataPrivacyLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your email app; copied {email} to your clipboard instead'**
  String dataPrivacyLaunchError(String email);

  /// No description provided for @marketingEmailsToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive marketing emails'**
  String get marketingEmailsToggleTitle;

  /// No description provided for @marketingEmailsBody.
  ///
  /// In en, this message translates to:
  /// **'I give Bosdom consent to send marketing emails including promotions, new supplier announcements, co-buy deals, and product recommendations tailored to my business needs.'**
  String get marketingEmailsBody;

  /// No description provided for @marketingEmailsFinePrint.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your consent at anytime. If you withdraw your consent, it will not affect the legality of data processed before. We process your data in line with our Privacy Policy.'**
  String get marketingEmailsFinePrint;

  /// No description provided for @marketingEmailsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your marketing email preference. Please try again.'**
  String get marketingEmailsSaveError;

  /// No description provided for @personalizedAdsAllowTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow personalized ads'**
  String get personalizedAdsAllowTitle;

  /// No description provided for @personalizedAdsBody.
  ///
  /// In en, this message translates to:
  /// **'We use your browsing data and purchase history to show you relevant product recommendations and ads. You can opt out anytime; you will still see ads, but they won\'t be tailored to your interests.'**
  String get personalizedAdsBody;

  /// No description provided for @personalizedAdsBrowsingTitle.
  ///
  /// In en, this message translates to:
  /// **'Browsing data'**
  String get personalizedAdsBrowsingTitle;

  /// No description provided for @personalizedAdsBrowsingBody.
  ///
  /// In en, this message translates to:
  /// **'Pages and products you view in the app'**
  String get personalizedAdsBrowsingBody;

  /// No description provided for @personalizedAdsPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get personalizedAdsPurchaseTitle;

  /// No description provided for @personalizedAdsPurchaseBody.
  ///
  /// In en, this message translates to:
  /// **'Items you have bought or added to cart'**
  String get personalizedAdsPurchaseBody;

  /// No description provided for @personalizedAdsAcceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept All'**
  String get personalizedAdsAcceptAll;

  /// No description provided for @personalizedAdsAdjustPreferences.
  ///
  /// In en, this message translates to:
  /// **'Adjust Preferences'**
  String get personalizedAdsAdjustPreferences;

  /// No description provided for @personalizedAdsHidePreferences.
  ///
  /// In en, this message translates to:
  /// **'Hide Preferences'**
  String get personalizedAdsHidePreferences;

  /// No description provided for @personalizedAdsSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get personalizedAdsSavePreferences;

  /// No description provided for @personalizedAdsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your ad preferences. Please try again.'**
  String get personalizedAdsSaveError;

  /// No description provided for @coBuyingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy'**
  String get coBuyingScreenTitle;

  /// No description provided for @coBuyingInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Pool orders with nearby retailers to unlock bulk wholesale discounts. Share invite links to grow your group!'**
  String get coBuyingInfoBanner;

  /// No description provided for @coBuyingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Co-Buy Sessions'**
  String get coBuyingSectionTitle;

  /// No description provided for @coBuyingMomentumReady.
  ///
  /// In en, this message translates to:
  /// **'Target reached, ready for checkout'**
  String get coBuyingMomentumReady;

  /// No description provided for @coBuyingMomentumAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost unlocked, grab it soon'**
  String get coBuyingMomentumAlmost;

  /// No description provided for @coBuyingMomentumFilling.
  ///
  /// In en, this message translates to:
  /// **'Filling up fast'**
  String get coBuyingMomentumFilling;

  /// No description provided for @coBuyingMomentumNew.
  ///
  /// In en, this message translates to:
  /// **'Newly opened, be an early buyer'**
  String get coBuyingMomentumNew;

  /// No description provided for @coBuyingPooledProgress.
  ///
  /// In en, this message translates to:
  /// **'{currentQty}/{targetQty} {unitLabel} pooled'**
  String coBuyingPooledProgress(
    int currentQty,
    int targetQty,
    String unitLabel,
  );

  /// No description provided for @coBuyingRemainingToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Just {remainingQty} {unitLabel} left to unlock the group price'**
  String coBuyingRemainingToUnlock(int remainingQty, String unitLabel);

  /// No description provided for @coBuyingGroupPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'GROUP PRICE'**
  String get coBuyingGroupPriceLabel;

  /// No description provided for @coBuyingYouSave.
  ///
  /// In en, this message translates to:
  /// **'You save {amount}'**
  String coBuyingYouSave(String amount);

  /// No description provided for @coBuyingJoinedPillLabel.
  ///
  /// In en, this message translates to:
  /// **'You\'re in this group buy · tap to leave'**
  String get coBuyingJoinedPillLabel;

  /// No description provided for @coBuyingCheckoutReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ready for checkout'**
  String get coBuyingCheckoutReadyLabel;

  /// No description provided for @coBuyingFullLabel.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Full'**
  String get coBuyingFullLabel;

  /// No description provided for @coBuyingJoinButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Join This Co-Buy'**
  String get coBuyingJoinButtonLabel;

  /// No description provided for @coBuyingShareText.
  ///
  /// In en, this message translates to:
  /// **'Join me on this Co-Buy for {productName} on BosDom! Get it for {price} ({savingsPct}% off).\n\n{url}'**
  String coBuyingShareText(
    String productName,
    String price,
    String savingsPct,
    String url,
  );

  /// No description provided for @coBuyingShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy: {productName}'**
  String coBuyingShareSubject(String productName);

  /// No description provided for @coBuyingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load co-buy deals. Tap to retry.'**
  String get coBuyingLoadError;

  /// No description provided for @coBuyingEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No co-buy deals yet. Check back soon!'**
  String get coBuyingEmptyMessage;

  /// No description provided for @coBuyDealsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your co-buy deals. Tap to retry.'**
  String get coBuyDealsLoadError;

  /// No description provided for @coBuyCreateScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a Co-Buy'**
  String get coBuyCreateScreenTitle;

  /// No description provided for @coBuyCreateEditScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Co-Buy Deal'**
  String get coBuyCreateEditScreenTitle;

  /// No description provided for @coBuyCreateProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get coBuyCreateProductNameLabel;

  /// No description provided for @coBuyCreateProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Jasmine Rice Premium 50kg'**
  String get coBuyCreateProductNameHint;

  /// No description provided for @coBuyCreateProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get coBuyCreateProductNameRequired;

  /// No description provided for @coBuyCreatePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Price (USD)'**
  String get coBuyCreatePriceLabel;

  /// No description provided for @coBuyCreatePriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Co-buy price is required'**
  String get coBuyCreatePriceRequired;

  /// No description provided for @coBuyCreatePriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get coBuyCreatePriceInvalid;

  /// No description provided for @coBuyCreateOriginalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Original Price (USD)'**
  String get coBuyCreateOriginalPriceLabel;

  /// No description provided for @coBuyCreateOriginalPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Original price is required'**
  String get coBuyCreateOriginalPriceRequired;

  /// No description provided for @coBuyCreateOriginalPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Original price must be higher than the co-buy price'**
  String get coBuyCreateOriginalPriceInvalid;

  /// No description provided for @coBuyCreateTargetQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Retailers'**
  String get coBuyCreateTargetQtyLabel;

  /// No description provided for @coBuyCreateTargetQtyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20'**
  String get coBuyCreateTargetQtyHint;

  /// No description provided for @coBuyCreateTargetQtyRequired.
  ///
  /// In en, this message translates to:
  /// **'Target retailers is required'**
  String get coBuyCreateTargetQtyRequired;

  /// No description provided for @coBuyCreateTargetQtyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get coBuyCreateTargetQtyInvalid;

  /// No description provided for @coBuyCreateUnitLabelLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get coBuyCreateUnitLabelLabel;

  /// No description provided for @coBuyCreateUnitLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. kg, packs, units'**
  String get coBuyCreateUnitLabelHint;

  /// No description provided for @coBuyCreateUnitLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit is required'**
  String get coBuyCreateUnitLabelRequired;

  /// No description provided for @coBuyCreateMinOrderQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order'**
  String get coBuyCreateMinOrderQtyLabel;

  /// No description provided for @coBuyCreateMinOrderQtyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500 kg'**
  String get coBuyCreateMinOrderQtyHint;

  /// No description provided for @coBuyCreateMinOrderQtyRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum order is required'**
  String get coBuyCreateMinOrderQtyRequired;

  /// No description provided for @coBuyCreateMinOrderQtyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get coBuyCreateMinOrderQtyInvalid;

  /// No description provided for @coBuyCreateDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Deal Duration'**
  String get coBuyCreateDurationLabel;

  /// No description provided for @coBuyCreateDuration1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get coBuyCreateDuration1Day;

  /// No description provided for @coBuyCreateDuration2Days.
  ///
  /// In en, this message translates to:
  /// **'2 days'**
  String get coBuyCreateDuration2Days;

  /// No description provided for @coBuyCreateDuration3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get coBuyCreateDuration3Days;

  /// No description provided for @coBuyCreateDuration5Days.
  ///
  /// In en, this message translates to:
  /// **'5 days'**
  String get coBuyCreateDuration5Days;

  /// No description provided for @coBuyCreateDuration1Week.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get coBuyCreateDuration1Week;

  /// No description provided for @coBuyCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Launch Co-Buy'**
  String get coBuyCreateButton;

  /// No description provided for @coBuyCreateCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy created! Invite others to join.'**
  String get coBuyCreateCreatedSnackbar;

  /// No description provided for @coBuyCreateUpdatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Co-buy deal updated'**
  String get coBuyCreateUpdatedSnackbar;

  /// No description provided for @coBuyCreateSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this co-buy deal. Please try again.'**
  String get coBuyCreateSaveError;

  /// No description provided for @coBuyCreateProductInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get coBuyCreateProductInfoSectionTitle;

  /// No description provided for @coBuyCreatePricingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Quantity'**
  String get coBuyCreatePricingSectionTitle;

  /// No description provided for @coBuyCreateDealSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deal Settings'**
  String get coBuyCreateDealSettingsSectionTitle;

  /// No description provided for @coBuyCreatePhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get coBuyCreatePhotosLabel;

  /// No description provided for @coBuyCreatePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to add cover photo'**
  String get coBuyCreatePhotoLabel;

  /// No description provided for @coBuyCreatePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended 512×512px JPG or PNG'**
  String get coBuyCreatePhotoHint;

  /// No description provided for @coBuyCreatePhotosHelper.
  ///
  /// In en, this message translates to:
  /// **'Add up to 4 photos. The first photo is the cover.'**
  String get coBuyCreatePhotosHelper;

  /// No description provided for @coBuyCreateDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get coBuyCreateDescriptionLabel;

  /// No description provided for @coBuyCreateDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the product for retailers'**
  String get coBuyCreateDescriptionHint;

  /// No description provided for @coBuyCreateAutoRenewLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew when expired'**
  String get coBuyCreateAutoRenewLabel;

  /// No description provided for @coBuyDealsWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Here is your co-buy performance summary today.'**
  String get coBuyDealsWelcomeMessage;

  /// No description provided for @coBuyDealsShopNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'My Shop'**
  String get coBuyDealsShopNamePlaceholder;

  /// No description provided for @coBuyDealsAutoRenewBadge.
  ///
  /// In en, this message translates to:
  /// **'Auto-renews'**
  String get coBuyDealsAutoRenewBadge;

  /// No description provided for @coBuyDealsActiveDealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Deals'**
  String get coBuyDealsActiveDealsLabel;

  /// No description provided for @coBuyDealsJoinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get coBuyDealsJoinedLabel;

  /// No description provided for @coBuyDealsRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get coBuyDealsRevenueLabel;

  /// No description provided for @coBuyDealsCreateButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Create New Co-Buy Deal'**
  String get coBuyDealsCreateButtonLabel;

  /// No description provided for @coBuyDealsListingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Co-Buy Listings'**
  String get coBuyDealsListingsSectionTitle;

  /// No description provided for @coBuyDealsMinTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Min wholesale target: {targetQty} {unitLabel}'**
  String coBuyDealsMinTargetLabel(int targetQty, String unitLabel);

  /// No description provided for @coBuyDealsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get coBuyDealsStatusActive;

  /// No description provided for @coBuyDealsStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get coBuyDealsStatusCompleted;

  /// No description provided for @coBuyDealsStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get coBuyDealsStatusExpired;

  /// No description provided for @coBuyDealsProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get coBuyDealsProgressLabel;

  /// No description provided for @coBuyDealsRetailersLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} retailers'**
  String coBuyDealsRetailersLabel(int count);

  /// No description provided for @coBuyDealsStatusEndedLabel.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get coBuyDealsStatusEndedLabel;

  /// No description provided for @coBuyDealsEndsSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends soon'**
  String get coBuyDealsEndsSoonLabel;

  /// No description provided for @coBuyDealsOriginalLabel.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get coBuyDealsOriginalLabel;

  /// No description provided for @coBuyDealsCoBuyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Co-buy price'**
  String get coBuyDealsCoBuyPriceLabel;

  /// No description provided for @coBuyDealsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Co-Buy Deal?'**
  String get coBuyDealsDeleteConfirmTitle;

  /// No description provided for @coBuyDealsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{productName} and its retailer progress will be permanently removed.'**
  String coBuyDealsDeleteConfirmBody(String productName);

  /// No description provided for @coBuyDealsDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Co-buy deal deleted'**
  String get coBuyDealsDeletedSnackbar;

  /// No description provided for @coBuyDealsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No co-buy deals yet. Create one so retailers can pool orders with you.'**
  String get coBuyDealsEmptyMessage;

  /// No description provided for @coBuyDetailActiveDealLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Deal'**
  String get coBuyDetailActiveDealLabel;

  /// No description provided for @coBuyDetailVisitShopLabel.
  ///
  /// In en, this message translates to:
  /// **'Visit Shop'**
  String get coBuyDetailVisitShopLabel;

  /// No description provided for @coBuyDetailJoinedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Joined {productName} Co-Buy · {amount}'**
  String coBuyDetailJoinedSnackbar(String productName, String amount);

  /// No description provided for @coBuyDetailLeftSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Left {productName} Co-Buy'**
  String coBuyDetailLeftSnackbar(String productName);

  /// No description provided for @coBuyDetailQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity} {unitLabel}'**
  String coBuyDetailQtyLabel(int quantity, String unitLabel);

  /// No description provided for @coBuyDetailProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Progress'**
  String get coBuyDetailProgressTitle;

  /// No description provided for @coBuyDetailProgressLine.
  ///
  /// In en, this message translates to:
  /// **'Progress: {currentQty}/{targetQty} {unitLabel}'**
  String coBuyDetailProgressLine(
    int currentQty,
    int targetQty,
    String unitLabel,
  );

  /// No description provided for @coBuyDetailRetailersJoined.
  ///
  /// In en, this message translates to:
  /// **'{count} retailers joined'**
  String coBuyDetailRetailersJoined(int count);

  /// No description provided for @coBuyDetailYouSaveLine.
  ///
  /// In en, this message translates to:
  /// **'You save {savingsPct}% {perUnitLabel} on this deal'**
  String coBuyDetailYouSaveLine(int savingsPct, String perUnitLabel);

  /// No description provided for @coBuyDetailYourOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Order'**
  String get coBuyDetailYourOrderTitle;

  /// No description provided for @coBuyDetailQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get coBuyDetailQuantityLabel;

  /// No description provided for @coBuyDetailMinOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Min order: {minOrderQty} {unitLabel}'**
  String coBuyDetailMinOrderLabel(int minOrderQty, String unitLabel);

  /// No description provided for @coBuyDetailSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get coBuyDetailSubtotalLabel;

  /// No description provided for @coBuyDetailCheckoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Checkout · {amount}'**
  String coBuyDetailCheckoutLabel(String amount);

  /// No description provided for @coBuyDetailFullLabel.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Full'**
  String get coBuyDetailFullLabel;

  /// No description provided for @coBuyDetailJoinedLabel.
  ///
  /// In en, this message translates to:
  /// **'You\'re in · tap to leave'**
  String get coBuyDetailJoinedLabel;

  /// No description provided for @coBuyDetailJoinLabel.
  ///
  /// In en, this message translates to:
  /// **'Join Co-Buy · {amount}'**
  String coBuyDetailJoinLabel(String amount);

  /// No description provided for @wishlistScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistScreenTitle;

  /// No description provided for @wishlistEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No items in your wishlist yet'**
  String get wishlistEmptyStateMessage;

  /// No description provided for @wishlistAddedToCartSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String wishlistAddedToCartSnackbar(String productName);

  /// No description provided for @wishlistAddToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get wishlistAddToCartButton;

  /// No description provided for @marketplaceCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Categories'**
  String get marketplaceCategoriesTitle;

  /// No description provided for @marketplaceCoBuyDealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Deals'**
  String get marketplaceCoBuyDealsTitle;

  /// No description provided for @marketplacePopularProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular wholesale products'**
  String get marketplacePopularProductsTitle;

  /// No description provided for @marketplaceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get marketplaceSearchHint;

  /// No description provided for @marketplaceNoProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products listed yet. Check back soon!'**
  String get marketplaceNoProductsYet;

  /// No description provided for @marketplaceProductsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load products. Tap to retry.'**
  String get marketplaceProductsLoadError;

  /// No description provided for @marketplaceCoBuyJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Join Co-Buy'**
  String get marketplaceCoBuyJoinButton;

  /// No description provided for @marketplaceCoBuyProgressToTarget.
  ///
  /// In en, this message translates to:
  /// **'{percent}% to target'**
  String marketplaceCoBuyProgressToTarget(String percent);

  /// No description provided for @marketplaceCoBuyRetailersJoined.
  ///
  /// In en, this message translates to:
  /// **'{count} joined'**
  String marketplaceCoBuyRetailersJoined(String count);

  /// No description provided for @productDetailPerUnit.
  ///
  /// In en, this message translates to:
  /// **'per unit'**
  String get productDetailPerUnit;

  /// No description provided for @productDetailMoqLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Quantity: {moq} Bags'**
  String productDetailMoqLabel(String moq);

  /// No description provided for @productDetailSpecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Specifications'**
  String get productDetailSpecsTitle;

  /// No description provided for @productDetailSpecWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get productDetailSpecWeight;

  /// No description provided for @productDetailSpecOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get productDetailSpecOrigin;

  /// No description provided for @productDetailSpecGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get productDetailSpecGrade;

  /// No description provided for @productDetailSpecPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get productDetailSpecPackaging;

  /// No description provided for @productDetailModeWholesale.
  ///
  /// In en, this message translates to:
  /// **'Wholesale'**
  String get productDetailModeWholesale;

  /// No description provided for @productDetailModeSample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get productDetailModeSample;

  /// No description provided for @productDetailVisitShop.
  ///
  /// In en, this message translates to:
  /// **'Visit Shop'**
  String get productDetailVisitShop;

  /// No description provided for @productDetailInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get productDetailInStock;

  /// No description provided for @productDetailOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productDetailOutOfStock;

  /// No description provided for @productDetailWholesaleBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Buy'**
  String get productDetailWholesaleBuyTitle;

  /// No description provided for @productDetailSampleBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Buy'**
  String get productDetailSampleBuyTitle;

  /// No description provided for @productDetailUnitBag.
  ///
  /// In en, this message translates to:
  /// **'/ bag'**
  String get productDetailUnitBag;

  /// No description provided for @productDetailUnitPiece.
  ///
  /// In en, this message translates to:
  /// **'/ unit'**
  String get productDetailUnitPiece;

  /// No description provided for @productDetailQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productDetailQuantityLabel;

  /// No description provided for @productDetailAddedToCartSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Added to cart · {price}'**
  String productDetailAddedToCartSnackbar(String price);

  /// No description provided for @productDetailSampleRequestedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Sample requested'**
  String get productDetailSampleRequestedSnackbar;

  /// No description provided for @productDetailAddToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart · {price}'**
  String productDetailAddToCartButton(String price);

  /// No description provided for @productDetailSampleAlreadyRequested.
  ///
  /// In en, this message translates to:
  /// **'Sample Already Requested'**
  String get productDetailSampleAlreadyRequested;

  /// No description provided for @productDetailSampleCooldownActive.
  ///
  /// In en, this message translates to:
  /// **'Cooldown Active'**
  String get productDetailSampleCooldownActive;

  /// No description provided for @productDetailRequestSample.
  ///
  /// In en, this message translates to:
  /// **'Request Sample'**
  String get productDetailRequestSample;

  /// No description provided for @productDetailSampleCooldownNote.
  ///
  /// In en, this message translates to:
  /// **'You can request another sample after {date}.'**
  String productDetailSampleCooldownNote(String date);

  /// No description provided for @productDetailSampleLimitNote.
  ///
  /// In en, this message translates to:
  /// **'Limited to 1 sample every 3 days'**
  String get productDetailSampleLimitNote;

  /// No description provided for @storeProfileStatProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get storeProfileStatProducts;

  /// No description provided for @storeProfileStatOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get storeProfileStatOrders;

  /// No description provided for @storeProfileStatRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get storeProfileStatRating;

  /// No description provided for @storeProfileTabProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get storeProfileTabProducts;

  /// No description provided for @storeProfileTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get storeProfileTabAbout;

  /// No description provided for @storeProfileTabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get storeProfileTabReviews;

  /// No description provided for @storeProfileNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get storeProfileNoProducts;

  /// No description provided for @storeProfileAboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get storeProfileAboutSectionTitle;

  /// No description provided for @storeProfileBusinessDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get storeProfileBusinessDetailsTitle;

  /// No description provided for @storeProfileLabelBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get storeProfileLabelBusinessType;

  /// No description provided for @storeProfileLabelYearEstablished.
  ///
  /// In en, this message translates to:
  /// **'Year Established'**
  String get storeProfileLabelYearEstablished;

  /// No description provided for @storeProfileLabelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get storeProfileLabelLocation;

  /// No description provided for @storeProfileLabelMinimumOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order'**
  String get storeProfileLabelMinimumOrder;

  /// No description provided for @storeProfileLabelResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get storeProfileLabelResponseTime;

  /// No description provided for @storeProfileLabelShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get storeProfileLabelShipping;

  /// No description provided for @storeProfileCertificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Certifications & Standards'**
  String get storeProfileCertificationsTitle;

  /// No description provided for @storeProfileWhyChooseUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us'**
  String get storeProfileWhyChooseUsTitle;

  /// No description provided for @storeProfileContactSupplierButton.
  ///
  /// In en, this message translates to:
  /// **'Contact Supplier'**
  String get storeProfileContactSupplierButton;

  /// No description provided for @storeProfileNoReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get storeProfileNoReviewsTitle;

  /// No description provided for @storeProfileNoReviewsBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review {sellerName} after your order.'**
  String storeProfileNoReviewsBody(String sellerName);

  /// No description provided for @storeProfileReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String storeProfileReviewsCount(String count);

  /// No description provided for @storeProfileRecommendPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Recommend'**
  String storeProfileRecommendPercent(String percent);

  /// No description provided for @storeProfileResponseTimeChip.
  ///
  /// In en, this message translates to:
  /// **'{time} Response'**
  String storeProfileResponseTimeChip(String time);

  /// No description provided for @storeProfileTopSellerChip.
  ///
  /// In en, this message translates to:
  /// **'Top Seller'**
  String get storeProfileTopSellerChip;

  /// No description provided for @storeProfileRatingBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating breakdown'**
  String get storeProfileRatingBreakdownTitle;

  /// No description provided for @storeProfileRecentReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Reviews'**
  String get storeProfileRecentReviewsTitle;

  /// No description provided for @categoryResultsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get categoryResultsSearchHint;

  /// No description provided for @categoryResultsFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get categoryResultsFiltersButton;

  /// No description provided for @categoryResultsItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String categoryResultsItemsCount(String count);

  /// No description provided for @categoryResultsNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get categoryResultsNoProducts;

  /// No description provided for @categoryResultsFilterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get categoryResultsFilterSheetTitle;

  /// No description provided for @categoryResultsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get categoryResultsClearAll;

  /// No description provided for @categoryResultsApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get categoryResultsApplyFilters;

  /// No description provided for @searchScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchScreenTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products or sellers...'**
  String get searchHint;

  /// No description provided for @searchRecentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchRecentSearchesTitle;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get searchClearAll;

  /// No description provided for @searchTrendingSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get searchTrendingSearchesTitle;

  /// No description provided for @searchSuggestedCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested Categories'**
  String get searchSuggestedCategoriesTitle;

  /// No description provided for @searchRecommendedForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended For You'**
  String get searchRecommendedForYouTitle;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No products found for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @ordersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get ordersScreenTitle;

  /// No description provided for @ordersEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No orders in this category'**
  String get ordersEmptyStateMessage;

  /// No description provided for @ordersFilterAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String ordersFilterAllLabel(int count);

  /// No description provided for @ordersItemCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String ordersItemCountLabel(int count);

  /// No description provided for @ordersOrderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String ordersOrderNumberLabel(String orderId);

  /// No description provided for @ordersRateReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review'**
  String get ordersRateReviewButton;

  /// No description provided for @ordersReportButton.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get ordersReportButton;

  /// No description provided for @ordersReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Report order'**
  String get ordersReportLabel;

  /// No description provided for @ordersReportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Order'**
  String get ordersReportSheetTitle;

  /// No description provided for @ordersReportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'What\'s the issue?'**
  String get ordersReportReasonLabel;

  /// No description provided for @ordersReportReasonWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong item received'**
  String get ordersReportReasonWrongItem;

  /// No description provided for @ordersReportReasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Item damaged'**
  String get ordersReportReasonDamaged;

  /// No description provided for @ordersReportReasonMissing.
  ///
  /// In en, this message translates to:
  /// **'Item missing'**
  String get ordersReportReasonMissing;

  /// No description provided for @ordersReportReasonLateDelivery.
  ///
  /// In en, this message translates to:
  /// **'Late delivery'**
  String get ordersReportReasonLateDelivery;

  /// No description provided for @ordersReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ordersReportReasonOther;

  /// No description provided for @ordersReportNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get ordersReportNoteLabel;

  /// No description provided for @ordersReportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about the issue...'**
  String get ordersReportNoteHint;

  /// No description provided for @ordersReportSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get ordersReportSubmitButton;

  /// No description provided for @ordersReportSubmittedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted'**
  String get ordersReportSubmittedSnackbar;

  /// No description provided for @ordersReportFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report: {error}'**
  String ordersReportFailedSnackbar(String error);

  /// No description provided for @ordersViewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get ordersViewDetailsButton;

  /// No description provided for @ordersTrackOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get ordersTrackOrderButton;

  /// No description provided for @orderDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailScreenTitle;

  /// No description provided for @orderDetailItemsAddedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Items added to your cart'**
  String get orderDetailItemsAddedSnackbar;

  /// No description provided for @orderDetailItemsOrderedSection.
  ///
  /// In en, this message translates to:
  /// **'Items Ordered'**
  String get orderDetailItemsOrderedSection;

  /// No description provided for @orderDetailOrderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderDetailOrderNumberLabel(String orderId);

  /// No description provided for @orderDetailDeliveryMethodSection.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get orderDetailDeliveryMethodSection;

  /// No description provided for @orderDetailCarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get orderDetailCarrierLabel;

  /// No description provided for @orderDetailPaymentSummarySection.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get orderDetailPaymentSummarySection;

  /// No description provided for @orderDetailPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String orderDetailPhoneLabel(String phone);

  /// No description provided for @orderDetailPlacedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String orderDetailPlacedOnLabel(String date);

  /// No description provided for @orderDetailReceiptSaveFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to save receipt: {error}'**
  String orderDetailReceiptSaveFailedSnackbar(String error);

  /// No description provided for @orderDetailReceiptSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved to your device'**
  String get orderDetailReceiptSavedSnackbar;

  /// No description provided for @orderDetailReorderButton.
  ///
  /// In en, this message translates to:
  /// **'Reorder Wholesale Items'**
  String get orderDetailReorderButton;

  /// No description provided for @orderDetailSaveReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Save Receipt as PDF'**
  String get orderDetailSaveReceiptButton;

  /// No description provided for @orderDetailSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get orderDetailSavingLabel;

  /// No description provided for @orderDetailShippingFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping Fee'**
  String get orderDetailShippingFeeLabel;

  /// No description provided for @orderDetailShippingSection.
  ///
  /// In en, this message translates to:
  /// **'Shipping & Delivery'**
  String get orderDetailShippingSection;

  /// No description provided for @orderDetailSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get orderDetailSubtotalLabel;

  /// No description provided for @orderDetailTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get orderDetailTotalAmountLabel;

  /// No description provided for @orderDetailTrackDeliveryButton.
  ///
  /// In en, this message translates to:
  /// **'Track Delivery'**
  String get orderDetailTrackDeliveryButton;

  /// No description provided for @orderDetailWholesaleDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Discount'**
  String get orderDetailWholesaleDiscountLabel;

  /// No description provided for @deliveryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Tracking'**
  String get deliveryScreenTitle;

  /// No description provided for @deliveryCurrentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get deliveryCurrentStatusLabel;

  /// No description provided for @deliveryEscrowNoteText.
  ///
  /// In en, this message translates to:
  /// **'Funds held securely in escrow until you confirm receipt.'**
  String get deliveryEscrowNoteText;

  /// No description provided for @deliveryInProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get deliveryInProgressLabel;

  /// No description provided for @deliveryPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get deliveryPendingLabel;

  /// No description provided for @deliveryPlacedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String deliveryPlacedOnLabel(String date);

  /// No description provided for @deliveryStatusSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Status'**
  String get deliveryStatusSectionTitle;

  /// No description provided for @deliveryStepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryStepDelivered;

  /// No description provided for @deliveryStepOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get deliveryStepOrderCancelled;

  /// No description provided for @deliveryStepOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get deliveryStepOrderPlaced;

  /// No description provided for @deliveryStepOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get deliveryStepOutForDelivery;

  /// No description provided for @deliveryStepPackedAtWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Packed at warehouse'**
  String get deliveryStepPackedAtWarehouse;

  /// No description provided for @reviewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review'**
  String get reviewSheetTitle;

  /// No description provided for @reviewAddPhotosButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get reviewAddPhotosButton;

  /// No description provided for @reviewAddPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'ADD PHOTOS OF RECEIVED ITEMS'**
  String get reviewAddPhotosLabel;

  /// No description provided for @reviewHintText.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this order...'**
  String get reviewHintText;

  /// No description provided for @reviewMaxPhotosSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {count} photos'**
  String reviewMaxPhotosSnackbar(int count);

  /// No description provided for @reviewOfficialBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL'**
  String get reviewOfficialBadge;

  /// No description provided for @reviewPhotoLibraryErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Could not open photo library: {error}'**
  String reviewPhotoLibraryErrorSnackbar(String error);

  /// No description provided for @reviewRateProductLabel.
  ///
  /// In en, this message translates to:
  /// **'RATE PRODUCT'**
  String get reviewRateProductLabel;

  /// No description provided for @reviewRateStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'RATE STORE'**
  String get reviewRateStoreLabel;

  /// No description provided for @reviewSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewSubmitButton;

  /// No description provided for @reviewSubmittedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your review has been submitted.'**
  String get reviewSubmittedSnackbar;

  /// No description provided for @reviewWriteReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'WRITE A REVIEW'**
  String get reviewWriteReviewLabel;

  /// No description provided for @paymentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentScreenTitle;

  /// No description provided for @paymentAbaMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'ABA Pay'**
  String get paymentAbaMethodTitle;

  /// No description provided for @paymentAbaNotAvailableSnackbar.
  ///
  /// In en, this message translates to:
  /// **'ABA Pay is not available yet'**
  String get paymentAbaNotAvailableSnackbar;

  /// No description provided for @paymentAmountToPayLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get paymentAmountToPayLabel;

  /// No description provided for @paymentCardDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Securely enter your card details'**
  String get paymentCardDetailsSubtitle;

  /// No description provided for @paymentCardMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get paymentCardMethodTitle;

  /// No description provided for @paymentCardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'CARD NUMBER'**
  String get paymentCardNumberLabel;

  /// No description provided for @paymentCardHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'CARD HOLDER'**
  String get paymentCardHolderLabel;

  /// No description provided for @paymentCardValidThruLabel.
  ///
  /// In en, this message translates to:
  /// **'VALID THRU'**
  String get paymentCardValidThruLabel;

  /// No description provided for @paymentConfirmedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed and paid.'**
  String get paymentConfirmedSubtitle;

  /// No description provided for @paymentConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re confirmed!'**
  String get paymentConfirmedTitle;

  /// No description provided for @paymentConfirmingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirming your order...'**
  String get paymentConfirmingSubtitle;

  /// No description provided for @paymentConfirmingTitle.
  ///
  /// In en, this message translates to:
  /// **'Just a moment'**
  String get paymentConfirmingTitle;

  /// No description provided for @paymentContinueShoppingButton.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get paymentContinueShoppingButton;

  /// No description provided for @paymentCvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get paymentCvvLabel;

  /// No description provided for @paymentExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'EXPIRY DATE'**
  String get paymentExpiryDateLabel;

  /// No description provided for @paymentFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailedSnackbar(String error);

  /// No description provided for @paymentItemsPurchasedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} items purchased'**
  String paymentItemsPurchasedLabel(int count);

  /// No description provided for @paymentMethodSubtitleVisaMastercard.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, etc.'**
  String get paymentMethodSubtitleVisaMastercard;

  /// No description provided for @paymentKhqrMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'KHQR / Bakong'**
  String get paymentKhqrMethodTitle;

  /// No description provided for @paymentKhqrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bakong, ABA, ACLEDA & more'**
  String get paymentKhqrSubtitle;

  /// No description provided for @paymentKhqrSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to Pay'**
  String get paymentKhqrSheetTitle;

  /// No description provided for @paymentKhqrInstructions.
  ///
  /// In en, this message translates to:
  /// **'Open your banking app and scan this code to complete payment'**
  String get paymentKhqrInstructions;

  /// No description provided for @paymentKhqrExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String paymentKhqrExpiresLabel(String time);

  /// No description provided for @paymentKhqrExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'QR code expired'**
  String get paymentKhqrExpiredLabel;

  /// No description provided for @paymentKhqrRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh Code'**
  String get paymentKhqrRefreshButton;

  /// No description provided for @paymentKhqrConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Completed the Payment'**
  String get paymentKhqrConfirmButton;

  /// No description provided for @paymentPayAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String paymentPayAmountLabel(String amount);

  /// No description provided for @paymentPayNowButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get paymentPayNowButton;

  /// No description provided for @paymentSecureEncryptionNote.
  ///
  /// In en, this message translates to:
  /// **'Your payment credentials are securely encrypted'**
  String get paymentSecureEncryptionNote;

  /// No description provided for @paymentSelectMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get paymentSelectMethodLabel;

  /// No description provided for @paymentTotalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get paymentTotalPaidLabel;

  /// No description provided for @paymentViewOrdersButton.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get paymentViewOrdersButton;

  /// No description provided for @paymentWholesaleItemsFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Items'**
  String get paymentWholesaleItemsFallbackLabel;

  /// No description provided for @escrowScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Escrow & checkout'**
  String get escrowScreenTitle;

  /// No description provided for @escrowPlaceholderText.
  ///
  /// In en, this message translates to:
  /// **'Payment, QR confirm, dispute evidence. UI comes in phase 8'**
  String get escrowPlaceholderText;

  /// No description provided for @profileMenuMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get profileMenuMyOrders;

  /// No description provided for @profileMenuCoBuyInvites.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Invites'**
  String get profileMenuCoBuyInvites;

  /// No description provided for @profileMenuAddressBook.
  ///
  /// In en, this message translates to:
  /// **'Address Book'**
  String get profileMenuAddressBook;

  /// No description provided for @profileMenuAddressStore.
  ///
  /// In en, this message translates to:
  /// **'Address Store'**
  String get profileMenuAddressStore;

  /// No description provided for @profileMenuBuyerChat.
  ///
  /// In en, this message translates to:
  /// **'Chat with Buyers'**
  String get profileMenuBuyerChat;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuPaymentCurrency.
  ///
  /// In en, this message translates to:
  /// **'Payment Currency'**
  String get profileMenuPaymentCurrency;

  /// No description provided for @profileMenuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileMenuLanguage;

  /// No description provided for @profileMenuDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy'**
  String get profileMenuDataPrivacy;

  /// No description provided for @profileMenuMarketingEmails.
  ///
  /// In en, this message translates to:
  /// **'Marketing Emails'**
  String get profileMenuMarketingEmails;

  /// No description provided for @profileMenuPersonalizedAds.
  ///
  /// In en, this message translates to:
  /// **'Personalized Ads'**
  String get profileMenuPersonalizedAds;

  /// No description provided for @profileMenuHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileMenuHelpSupport;

  /// No description provided for @profileMenuTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileMenuTermsConditions;

  /// No description provided for @profileMenuPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profileMenuPrivacyPolicy;

  /// No description provided for @profileMenuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileMenuAbout;

  /// No description provided for @profileMenuSellerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Seller Dashboard'**
  String get profileMenuSellerDashboard;

  /// No description provided for @profileMenuMyInventory.
  ///
  /// In en, this message translates to:
  /// **'My Inventory'**
  String get profileMenuMyInventory;

  /// No description provided for @profileMenuAddListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get profileMenuAddListing;

  /// No description provided for @profileMenuCoBuyDeals.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Deals'**
  String get profileMenuCoBuyDeals;

  /// No description provided for @profileMenuShopProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop Profile'**
  String get profileMenuShopProfile;

  /// No description provided for @profileSectionShopping.
  ///
  /// In en, this message translates to:
  /// **'SHOPPING'**
  String get profileSectionShopping;

  /// No description provided for @profileSectionSelling.
  ///
  /// In en, this message translates to:
  /// **'SELLING'**
  String get profileSectionSelling;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get profileSectionSettings;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get profileSectionSupport;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get profileSectionAbout;

  /// No description provided for @profileStatTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get profileStatTotalOrders;

  /// No description provided for @profileStatActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get profileStatActiveOrders;

  /// No description provided for @profileStatSavedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get profileStatSavedItems;

  /// No description provided for @profileStatTotalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get profileStatTotalProducts;

  /// No description provided for @profileStatRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get profileStatRevenue;

  /// No description provided for @profileSellerProgramBadge.
  ///
  /// In en, this message translates to:
  /// **'SELLER PROGRAM'**
  String get profileSellerProgramBadge;

  /// No description provided for @profileSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Selling on Bosdom'**
  String get profileSellerTitle;

  /// No description provided for @profileSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of wholesalers and reach more retailers across Cambodia'**
  String get profileSellerSubtitle;

  /// No description provided for @profileSellerCta.
  ///
  /// In en, this message translates to:
  /// **'Become a Seller'**
  String get profileSellerCta;

  /// No description provided for @profileSellerOnboardingLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller Onboarding'**
  String get profileSellerOnboardingLabel;

  /// No description provided for @profileSellerActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SELLER'**
  String get profileSellerActiveBadge;

  /// No description provided for @profileSellerActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re a Seller'**
  String get profileSellerActiveTitle;

  /// No description provided for @profileSellerActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your listings and orders from the Marketplace tab'**
  String get profileSellerActiveSubtitle;

  /// No description provided for @profileSellerActivatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You\'re now part of the Seller Program!'**
  String get profileSellerActivatedSnackbar;

  /// No description provided for @profileSellerGoToMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Go to Marketplace'**
  String get profileSellerGoToMarketplace;

  /// No description provided for @profileEditProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfileLabel;

  /// No description provided for @sellerDashboardScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get sellerDashboardScreenTitle;

  /// No description provided for @sellerDashboardVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get sellerDashboardVerifiedBadge;

  /// No description provided for @sellerDashboardWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Here\'s your wholesale store performance summary today.'**
  String get sellerDashboardWelcomeMessage;

  /// No description provided for @sellerDashboardRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get sellerDashboardRevenueLabel;

  /// No description provided for @sellerDashboardPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sellerDashboardPendingLabel;

  /// No description provided for @sellerDashboardPendingOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Orders'**
  String sellerDashboardPendingOrdersLabel(int count);

  /// No description provided for @sellerDashboardProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get sellerDashboardProductsLabel;

  /// No description provided for @sellerDashboardProductsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String sellerDashboardProductsCountLabel(int count);

  /// No description provided for @sellerDashboardQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get sellerDashboardQuickActionsTitle;

  /// No description provided for @sellerDashboardAddListingAction.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get sellerDashboardAddListingAction;

  /// No description provided for @sellerDashboardMyInventoryAction.
  ///
  /// In en, this message translates to:
  /// **'My Inventory'**
  String get sellerDashboardMyInventoryAction;

  /// No description provided for @sellerDashboardOrdersAction.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sellerDashboardOrdersAction;

  /// No description provided for @sellerDashboardEarningsAction.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get sellerDashboardEarningsAction;

  /// No description provided for @sellerDashboardBuyerToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop as a Buyer'**
  String get sellerDashboardBuyerToolsTitle;

  /// No description provided for @sellerDashboardMarketplaceAction.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get sellerDashboardMarketplaceAction;

  /// No description provided for @sellerDashboardWishlistAction.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get sellerDashboardWishlistAction;

  /// No description provided for @sellerDashboardCartAction.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get sellerDashboardCartAction;

  /// No description provided for @sellerDashboardCoBuyingAction.
  ///
  /// In en, this message translates to:
  /// **'Co-Buying'**
  String get sellerDashboardCoBuyingAction;

  /// No description provided for @sellerDashboardPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get sellerDashboardPerformanceTitle;

  /// No description provided for @sellerDashboardRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sellerDashboardRatingLabel;

  /// No description provided for @sellerDashboardCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get sellerDashboardCompletionLabel;

  /// No description provided for @sellerDashboardAvgDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg Delivery'**
  String get sellerDashboardAvgDeliveryLabel;

  /// No description provided for @sellerDashboardRecentOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Active Orders'**
  String get sellerDashboardRecentOrdersTitle;

  /// No description provided for @sellerDashboardViewAllLabel.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get sellerDashboardViewAllLabel;

  /// No description provided for @sellerEarningsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get sellerEarningsScreenTitle;

  /// No description provided for @sellerEarningsAvailableBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get sellerEarningsAvailableBalanceLabel;

  /// No description provided for @sellerEarningsCompletedSalesPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of completed sales'**
  String sellerEarningsCompletedSalesPercentLabel(int percent);

  /// No description provided for @sellerEarningsWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get sellerEarningsWithdrawButton;

  /// No description provided for @sellerEarningsReleasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get sellerEarningsReleasedLabel;

  /// No description provided for @sellerEarningsInEscrowLabel.
  ///
  /// In en, this message translates to:
  /// **'In Escrow'**
  String get sellerEarningsInEscrowLabel;

  /// No description provided for @sellerEarningsRefundedLabel.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get sellerEarningsRefundedLabel;

  /// No description provided for @sellerEarningsFilterAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sellerEarningsFilterAllLabel;

  /// No description provided for @sellerEarningsFilterReleasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get sellerEarningsFilterReleasedLabel;

  /// No description provided for @sellerEarningsFilterInEscrowLabel.
  ///
  /// In en, this message translates to:
  /// **'In Escrow'**
  String get sellerEarningsFilterInEscrowLabel;

  /// No description provided for @sellerEarningsFilterDisputedLabel.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get sellerEarningsFilterDisputedLabel;

  /// No description provided for @sellerEarningsTransactionsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String sellerEarningsTransactionsCountLabel(int count);

  /// No description provided for @sellerEarningsOrderBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'#{id} • {buyer}'**
  String sellerEarningsOrderBuyerLabel(String id, String buyer);

  /// No description provided for @sellerEarningsSaleAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale amount'**
  String get sellerEarningsSaleAmountLabel;

  /// No description provided for @sellerEarningsPlatformFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform fee ({rate}%)'**
  String sellerEarningsPlatformFeeLabel(int rate);

  /// No description provided for @sellerEarningsYourEarningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Your earnings'**
  String get sellerEarningsYourEarningsLabel;

  /// No description provided for @sellerEarningsWithdrawalLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get sellerEarningsWithdrawalLabel;

  /// No description provided for @sellerEarningsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sellerEarningsStatusPending;

  /// No description provided for @sellerEarningsStatusInEscrow.
  ///
  /// In en, this message translates to:
  /// **'In Escrow'**
  String get sellerEarningsStatusInEscrow;

  /// No description provided for @sellerEarningsStatusReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get sellerEarningsStatusReleased;

  /// No description provided for @sellerEarningsStatusDisputed.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get sellerEarningsStatusDisputed;

  /// No description provided for @sellerEarningsStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get sellerEarningsStatusWithdrawn;

  /// No description provided for @sellerEarningsEscrowNoticeText.
  ///
  /// In en, this message translates to:
  /// **'Funds are held in escrow for 48 hours after purchase. Once released, tap Withdraw to transfer earnings to your bank account.'**
  String get sellerEarningsEscrowNoticeText;

  /// No description provided for @sellerEarningsEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this category'**
  String get sellerEarningsEmptyStateMessage;

  /// No description provided for @sellerEarningsWithdrawSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get sellerEarningsWithdrawSheetTitle;

  /// No description provided for @sellerEarningsWithdrawPoweredByLabel.
  ///
  /// In en, this message translates to:
  /// **'Powered by ABA Pay'**
  String get sellerEarningsWithdrawPoweredByLabel;

  /// No description provided for @sellerEarningsWithdrawAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Amount (\$)'**
  String get sellerEarningsWithdrawAmountLabel;

  /// No description provided for @sellerEarningsAccountHolderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get sellerEarningsAccountHolderNameLabel;

  /// No description provided for @sellerEarningsAccountHolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name on account'**
  String get sellerEarningsAccountHolderNameHint;

  /// No description provided for @sellerEarningsRoutingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Routing Number'**
  String get sellerEarningsRoutingNumberLabel;

  /// No description provided for @sellerEarningsRoutingNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter ABA routing number (e.g., 020001)'**
  String get sellerEarningsRoutingNumberHint;

  /// No description provided for @sellerEarningsAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get sellerEarningsAccountNumberLabel;

  /// No description provided for @sellerEarningsAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter ABA account number'**
  String get sellerEarningsAccountNumberHint;

  /// No description provided for @sellerEarningsWithdrawNoticeText.
  ///
  /// In en, this message translates to:
  /// **'Funds will be instantly transferred to your designated ABA Pay account. Standard security holds may apply.'**
  String get sellerEarningsWithdrawNoticeText;

  /// No description provided for @sellerEarningsWithdrawContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sellerEarningsWithdrawContinueButton;

  /// No description provided for @sellerEarningsWithdrawFieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get sellerEarningsWithdrawFieldRequiredError;

  /// No description provided for @sellerEarningsWithdrawAmountInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get sellerEarningsWithdrawAmountInvalidError;

  /// No description provided for @sellerEarningsWithdrawAmountExceedsError.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds available balance'**
  String get sellerEarningsWithdrawAmountExceedsError;

  /// No description provided for @sellerEarningsWithdrawJustNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get sellerEarningsWithdrawJustNowLabel;

  /// No description provided for @sellerEarningsWithdrawSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal of \${amount} submitted'**
  String sellerEarningsWithdrawSuccessSnackbar(String amount);

  /// No description provided for @sellerEarningsWithdrawSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get sellerEarningsWithdrawSuccessTitle;

  /// No description provided for @sellerEarningsWithdrawSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'\${amount} withdrawal initiated. Funds will arrive in 2-3 business days.'**
  String sellerEarningsWithdrawSuccessMessage(String amount);

  /// No description provided for @sellerEarningsWithdrawSuccessOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sellerEarningsWithdrawSuccessOkButton;

  /// No description provided for @sellerOrdersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sellerOrdersScreenTitle;

  /// No description provided for @sellerOrdersEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No orders in this category'**
  String get sellerOrdersEmptyStateMessage;

  /// No description provided for @sellerOrdersFilterAllLabel.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String sellerOrdersFilterAllLabel(int count);

  /// No description provided for @sellerOrdersFilterPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String sellerOrdersFilterPendingLabel(int count);

  /// No description provided for @sellerOrdersQuantityProductLabel.
  ///
  /// In en, this message translates to:
  /// **'{quantity} • {product}'**
  String sellerOrdersQuantityProductLabel(String quantity, String product);

  /// No description provided for @sellerOrdersCoBuyBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy'**
  String get sellerOrdersCoBuyBadgeLabel;

  /// No description provided for @sellerOrderDetailBuyerInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Buyer Information'**
  String get sellerOrderDetailBuyerInfoSection;

  /// No description provided for @sellerOrderDetailPlatformFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee ({rate}%)'**
  String sellerOrderDetailPlatformFeeLabel(int rate);

  /// No description provided for @sellerOrderDetailYourEarningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Earnings'**
  String get sellerOrderDetailYourEarningsLabel;

  /// No description provided for @sellerOrderDetailAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get sellerOrderDetailAcceptButton;

  /// No description provided for @sellerOrderDetailDeclineButton.
  ///
  /// In en, this message translates to:
  /// **'Decline Order'**
  String get sellerOrderDetailDeclineButton;

  /// No description provided for @sellerOrderDetailOrderAcceptedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Order accepted'**
  String get sellerOrderDetailOrderAcceptedSnackbar;

  /// No description provided for @sellerOrderDetailOrderDeclinedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Order declined'**
  String get sellerOrderDetailOrderDeclinedSnackbar;

  /// No description provided for @sellerOrderDetailDeclineConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this order?'**
  String get sellerOrderDetailDeclineConfirmTitle;

  /// No description provided for @sellerOrderDetailDeclineConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The buyer will be notified that you can\'t fulfill this order.'**
  String get sellerOrderDetailDeclineConfirmMessage;

  /// No description provided for @sellerOrderDetailDeclineConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sellerOrderDetailDeclineConfirmCancel;

  /// No description provided for @sellerOrderDetailDeclineConfirmConfirm.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get sellerOrderDetailDeclineConfirmConfirm;

  /// No description provided for @myInventoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Inventory'**
  String get myInventoryScreenTitle;

  /// No description provided for @myInventorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get myInventorySearchHint;

  /// No description provided for @myInventoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get myInventoryFilterAll;

  /// No description provided for @myInventoryFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myInventoryFilterActive;

  /// No description provided for @myInventoryFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get myInventoryFilterInactive;

  /// No description provided for @myInventoryStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock}'**
  String myInventoryStockLabel(String stock);

  /// No description provided for @myInventoryEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get myInventoryEmptyStateMessage;

  /// No description provided for @myInventoryListingActivatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{product} is now active'**
  String myInventoryListingActivatedSnackbar(String product);

  /// No description provided for @myInventoryListingDeactivatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{product} is now inactive'**
  String myInventoryListingDeactivatedSnackbar(String product);

  /// No description provided for @profileEditProfileRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role Profile'**
  String get profileEditProfileRoleLabel;

  /// No description provided for @profileEditProfileRoleSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Role Profile'**
  String get profileEditProfileRoleSheetTitle;

  /// No description provided for @profileEditProfileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileEditProfileChangePhoto;

  /// No description provided for @profileEditProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileEditProfileNameLabel;

  /// No description provided for @profileEditProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get profileEditProfileNameHint;

  /// No description provided for @profileEditProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get profileEditProfileNameRequired;

  /// No description provided for @profileEditProfilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profileEditProfilePhoneLabel;

  /// No description provided for @profileEditProfilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get profileEditProfilePhoneHint;

  /// No description provided for @profileEditProfilePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get profileEditProfilePhoneRequired;

  /// No description provided for @profileEditProfileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEditProfileEmailLabel;

  /// No description provided for @profileEditProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get profileEditProfileEmailHint;

  /// No description provided for @profileEditProfileEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get profileEditProfileEmailRequired;

  /// No description provided for @profileEditProfileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get profileEditProfileEmailInvalid;

  /// No description provided for @profileEditProfileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileEditProfileSaveButton;

  /// No description provided for @profileEditProfileSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileEditProfileSavedSnackbar;

  /// No description provided for @profileEditProfileSaveErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your profile. Please try again.'**
  String get profileEditProfileSaveErrorSnackbar;

  /// No description provided for @profileEditProfileLoadErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile. Please try again.'**
  String get profileEditProfileLoadErrorSnackbar;

  /// No description provided for @shopProfileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Profile'**
  String get shopProfileScreenTitle;

  /// No description provided for @shopProfileChangeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change Store Logo'**
  String get shopProfileChangeLogo;

  /// No description provided for @shopProfileShopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopProfileShopNameLabel;

  /// No description provided for @shopProfileShopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your shop name'**
  String get shopProfileShopNameHint;

  /// No description provided for @shopProfileShopNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your shop name'**
  String get shopProfileShopNameRequired;

  /// No description provided for @shopProfileBusinessTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get shopProfileBusinessTypeLabel;

  /// No description provided for @shopProfileBusinessTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Manufacturer & Distributor'**
  String get shopProfileBusinessTypeHint;

  /// No description provided for @shopProfileBusinessTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your business type'**
  String get shopProfileBusinessTypeRequired;

  /// No description provided for @shopProfileYearEstablishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Year Established'**
  String get shopProfileYearEstablishedLabel;

  /// No description provided for @shopProfileYearEstablishedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2018'**
  String get shopProfileYearEstablishedHint;

  /// No description provided for @shopProfileLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get shopProfileLocationLabel;

  /// No description provided for @shopProfileLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Phnom Penh'**
  String get shopProfileLocationHint;

  /// No description provided for @shopProfileLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your location'**
  String get shopProfileLocationRequired;

  /// No description provided for @shopProfilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get shopProfilePhoneLabel;

  /// No description provided for @shopProfilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get shopProfilePhoneHint;

  /// No description provided for @shopProfilePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get shopProfilePhoneRequired;

  /// No description provided for @shopProfileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get shopProfileEmailLabel;

  /// No description provided for @shopProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get shopProfileEmailHint;

  /// No description provided for @shopProfileEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get shopProfileEmailRequired;

  /// No description provided for @shopProfileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get shopProfileEmailInvalid;

  /// No description provided for @shopProfileDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Business Description'**
  String get shopProfileDescriptionLabel;

  /// No description provided for @shopProfileDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell buyers about your business'**
  String get shopProfileDescriptionHint;

  /// No description provided for @shopProfileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get shopProfileSaveButton;

  /// No description provided for @shopProfileSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Shop profile updated successfully'**
  String get shopProfileSavedSnackbar;

  /// No description provided for @shopProfileSaveErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your shop profile. Please try again.'**
  String get shopProfileSaveErrorSnackbar;

  /// No description provided for @addListingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListingScreenTitle;

  /// No description provided for @addListingProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get addListingProductNameLabel;

  /// No description provided for @addListingProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Premium Cashew Nuts'**
  String get addListingProductNameHint;

  /// No description provided for @addListingProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get addListingProductNameRequired;

  /// No description provided for @addListingCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addListingCategoryLabel;

  /// No description provided for @addListingCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get addListingCategoryHint;

  /// No description provided for @addListingCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get addListingCategoryRequired;

  /// No description provided for @addListingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price USD'**
  String get addListingPriceLabel;

  /// No description provided for @addListingPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get addListingPriceRequired;

  /// No description provided for @addListingPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get addListingPriceInvalid;

  /// No description provided for @addListingMoqLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Qty'**
  String get addListingMoqLabel;

  /// No description provided for @addListingMoqHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100 bags'**
  String get addListingMoqHint;

  /// No description provided for @addListingMoqRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a minimum order quantity'**
  String get addListingMoqRequired;

  /// No description provided for @addListingMoqInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get addListingMoqInvalid;

  /// No description provided for @addListingStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get addListingStockLabel;

  /// No description provided for @addListingStockHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500'**
  String get addListingStockHint;

  /// No description provided for @addListingStockRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a stock quantity'**
  String get addListingStockRequired;

  /// No description provided for @addListingStockInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get addListingStockInvalid;

  /// No description provided for @addListingPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get addListingPhotosLabel;

  /// No description provided for @addListingCoverPhotoCta.
  ///
  /// In en, this message translates to:
  /// **'Tap to add cover photo'**
  String get addListingCoverPhotoCta;

  /// No description provided for @addListingPhotosFormatHint.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG up to 5MB'**
  String get addListingPhotosFormatHint;

  /// No description provided for @addListingPhotosHelper.
  ///
  /// In en, this message translates to:
  /// **'Upload up to 5 photos. First photo is the cover.'**
  String get addListingPhotosHelper;

  /// No description provided for @addListingCoverPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a cover photo'**
  String get addListingCoverPhotoRequired;

  /// No description provided for @addListingDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addListingDescriptionLabel;

  /// No description provided for @addListingDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100% cotton crew-neck t-shirts, Grade A quality, sold in bulk from 50pcs, ships within 3-5 business days.'**
  String get addListingDescriptionHint;

  /// No description provided for @addListingSampleTestingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sample Testing'**
  String get addListingSampleTestingLabel;

  /// No description provided for @addListingSampleTestingToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Sample Testing'**
  String get addListingSampleTestingToggleTitle;

  /// No description provided for @addListingSampleTestingToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Limit 1 item per buyer'**
  String get addListingSampleTestingToggleSubtitle;

  /// No description provided for @addListingSamplePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Sample Price USD'**
  String get addListingSamplePriceLabel;

  /// No description provided for @addListingSamplePriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a sample price'**
  String get addListingSamplePriceRequired;

  /// No description provided for @addListingSamplePriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid sample price'**
  String get addListingSamplePriceInvalid;

  /// No description provided for @addListingVariantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sizes & Colors'**
  String get addListingVariantsLabel;

  /// No description provided for @addListingVariantsHelper.
  ///
  /// In en, this message translates to:
  /// **'Let buyers pick from the options you offer'**
  String get addListingVariantsHelper;

  /// No description provided for @addListingAddSizeChip.
  ///
  /// In en, this message translates to:
  /// **'Add size'**
  String get addListingAddSizeChip;

  /// No description provided for @addListingAddSizeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a size'**
  String get addListingAddSizeDialogTitle;

  /// No description provided for @addListingAddSizeDialogHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kids, 42, Free Size'**
  String get addListingAddSizeDialogHint;

  /// No description provided for @addListingAddSizeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addListingAddSizeConfirm;

  /// No description provided for @addListingAddColorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get addListingAddColorDialogTitle;

  /// No description provided for @addListingCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get addListingCreateButton;

  /// No description provided for @addListingCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully'**
  String get addListingCreatedSnackbar;

  /// No description provided for @addListingCreateErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your listing. Please try again.'**
  String get addListingCreateErrorSnackbar;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileRefreshFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh your profile. Check your connection and try again.'**
  String get profileRefreshFailedSnackbar;

  /// No description provided for @currencyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Currency'**
  String get currencyScreenTitle;

  /// No description provided for @currencyScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred currency for all transactions on Bosdom. Prices will be displayed in your selected currency.'**
  String get currencyScreenIntro;

  /// No description provided for @currencySectionSelect.
  ///
  /// In en, this message translates to:
  /// **'SELECT CURRENCY'**
  String get currencySectionSelect;

  /// No description provided for @currencySectionDisplaySettings.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY DISPLAY SETTINGS'**
  String get currencySectionDisplaySettings;

  /// No description provided for @currencyUsdName.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD)'**
  String get currencyUsdName;

  /// No description provided for @currencyKhrName.
  ///
  /// In en, this message translates to:
  /// **'Khmer Riel (KHR)'**
  String get currencyKhrName;

  /// No description provided for @currencyExchangeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get currencyExchangeRateLabel;

  /// No description provided for @currencyRateDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates are updated daily. Final conversion rates are applied at the time of payment.'**
  String get currencyRateDisclaimer;

  /// No description provided for @currencyLastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String currencyLastUpdatedLabel(String date);

  /// No description provided for @currencyActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get currencyActiveStatus;

  /// No description provided for @currencyDailyUpdateChip.
  ///
  /// In en, this message translates to:
  /// **'Daily Update'**
  String get currencyDailyUpdateChip;

  /// No description provided for @currencyShowBothToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Show prices in both currencies'**
  String get currencyShowBothToggleLabel;

  /// No description provided for @currencySavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Currency preferences saved'**
  String get currencySavedSnackbar;

  /// No description provided for @helpSupportScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportScreenTitle;

  /// No description provided for @helpSupportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search FAQs or articles...'**
  String get helpSupportSearchHint;

  /// No description provided for @helpSupportCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'FAQ Categories'**
  String get helpSupportCategoriesLabel;

  /// No description provided for @helpSupportCategoryGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get helpSupportCategoryGettingStarted;

  /// No description provided for @helpSupportCategoryOrdersPayments.
  ///
  /// In en, this message translates to:
  /// **'Orders & Payments'**
  String get helpSupportCategoryOrdersPayments;

  /// No description provided for @helpSupportCategoryShippingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Shipping & Delivery'**
  String get helpSupportCategoryShippingDelivery;

  /// No description provided for @helpSupportCategoryAccountVerification.
  ///
  /// In en, this message translates to:
  /// **'Account & Verification'**
  String get helpSupportCategoryAccountVerification;

  /// No description provided for @helpSupportCategoryReturnsDisputes.
  ///
  /// In en, this message translates to:
  /// **'Returns & Disputes'**
  String get helpSupportCategoryReturnsDisputes;

  /// No description provided for @helpSupportAssistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Personal Assistance?'**
  String get helpSupportAssistanceTitle;

  /// No description provided for @helpSupportAssistanceBody.
  ///
  /// In en, this message translates to:
  /// **'Our B2B support team is available Mon-Fri, 8 AM - 6 PM (Cambodia Time) to resolve order disputes or platform inquiries.'**
  String get helpSupportAssistanceBody;

  /// No description provided for @helpSupportLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get helpSupportLiveChat;

  /// No description provided for @helpSupportCallUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get helpSupportCallUs;

  /// No description provided for @helpSupportReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue / Bug'**
  String get helpSupportReportIssue;

  /// No description provided for @reportIssueScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssueScreenTitle;

  /// No description provided for @reportIssueTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Type'**
  String get reportIssueTypeLabel;

  /// No description provided for @reportIssueTypeOrderProblem.
  ///
  /// In en, this message translates to:
  /// **'Order Problem'**
  String get reportIssueTypeOrderProblem;

  /// No description provided for @reportIssueTypePaymentIssue.
  ///
  /// In en, this message translates to:
  /// **'Payment Issue'**
  String get reportIssueTypePaymentIssue;

  /// No description provided for @reportIssueTypeAppBug.
  ///
  /// In en, this message translates to:
  /// **'App Bug'**
  String get reportIssueTypeAppBug;

  /// No description provided for @reportIssueTypeDeliveryIssue.
  ///
  /// In en, this message translates to:
  /// **'Delivery Issue'**
  String get reportIssueTypeDeliveryIssue;

  /// No description provided for @reportIssueTypeAccountProblem.
  ///
  /// In en, this message translates to:
  /// **'Account Problem'**
  String get reportIssueTypeAccountProblem;

  /// No description provided for @reportIssueTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportIssueTypeOther;

  /// No description provided for @reportIssueSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get reportIssueSubjectLabel;

  /// No description provided for @reportIssueSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the issue'**
  String get reportIssueSubjectHint;

  /// No description provided for @reportIssueSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get reportIssueSubjectRequired;

  /// No description provided for @reportIssueDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportIssueDescriptionLabel;

  /// No description provided for @reportIssueDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue in detail...'**
  String get reportIssueDescriptionHint;

  /// No description provided for @reportIssueDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get reportIssueDescriptionRequired;

  /// No description provided for @reportIssueAttachLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach Screenshots'**
  String get reportIssueAttachLabel;

  /// No description provided for @reportIssueAttachTapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload images'**
  String get reportIssueAttachTapToUpload;

  /// No description provided for @reportIssueAttachSupports.
  ///
  /// In en, this message translates to:
  /// **'Supports PNG, JPG up to 5MB (Max {max} files)'**
  String reportIssueAttachSupports(int max);

  /// No description provided for @reportIssueMaxFilesSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to {max} files'**
  String reportIssueMaxFilesSnackbar(int max);

  /// No description provided for @reportIssuePhotoLibraryErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Could not open photo library: {error}'**
  String reportIssuePhotoLibraryErrorSnackbar(String error);

  /// No description provided for @reportIssueOrderRefLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Reference'**
  String get reportIssueOrderRefLabel;

  /// No description provided for @reportIssueOrderRefOptional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get reportIssueOrderRefOptional;

  /// No description provided for @reportIssueOrderRefHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., #B2B-98741'**
  String get reportIssueOrderRefHint;

  /// No description provided for @reportIssueResponseNote.
  ///
  /// In en, this message translates to:
  /// **'Our wholesale support team typically responds to app bugs and order technical inquiries within 2 hours.'**
  String get reportIssueResponseNote;

  /// No description provided for @reportIssueSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get reportIssueSubmitButton;

  /// No description provided for @reportIssueSubmittedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted. We\'ll get back to you soon.'**
  String get reportIssueSubmittedSnackbar;

  /// No description provided for @callUsPopupBody.
  ///
  /// In en, this message translates to:
  /// **'Our specialized B2B customer assistance hotline is available for order resolutions, disputes, and urgent support.'**
  String get callUsPopupBody;

  /// No description provided for @callUsPopupHours.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri, 8 AM - 6 PM (Cambodia Time)'**
  String get callUsPopupHours;

  /// No description provided for @callUsPopupSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'B2B Wholesale Support'**
  String get callUsPopupSupportLabel;

  /// No description provided for @callUsPopupPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'+855 23 456 789'**
  String get callUsPopupPhoneNumber;

  /// No description provided for @callUsPopupCallNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callUsPopupCallNow;

  /// No description provided for @callUsPopupLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the phone dialer'**
  String get callUsPopupLaunchError;

  /// No description provided for @termsConditionsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditionsScreenTitle;

  /// No description provided for @termsConditionsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: August 2026'**
  String get termsConditionsLastUpdated;

  /// No description provided for @termsConditionsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Platform Overview & Acceptance'**
  String get termsConditionsSection1Title;

  /// No description provided for @termsConditionsSection1Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom is a localized B2B wholesale marketplace built for verified Cambodian retailers and suppliers. The Platform connects independent retail merchants with trusted wholesalers through a secure escrow payment system, featuring sample verification, group co-buying, and automated escrow protections.'**
  String get termsConditionsSection1Point1;

  /// No description provided for @termsConditionsSection1Point2.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you confirm that:'**
  String get termsConditionsSection1Point2;

  /// No description provided for @termsConditionsSection1Point3.
  ///
  /// In en, this message translates to:
  /// **'You are at least 18 years of age.'**
  String get termsConditionsSection1Point3;

  /// No description provided for @termsConditionsSection1Point4.
  ///
  /// In en, this message translates to:
  /// **'You are operating a legitimate business in Cambodia.'**
  String get termsConditionsSection1Point4;

  /// No description provided for @termsConditionsSection1Point5.
  ///
  /// In en, this message translates to:
  /// **'All information provided during registration is accurate, current, and complete.'**
  String get termsConditionsSection1Point5;

  /// No description provided for @termsConditionsSection1Point6.
  ///
  /// In en, this message translates to:
  /// **'You agree to comply with these Terms and all applicable local laws and regulations.'**
  String get termsConditionsSection1Point6;

  /// No description provided for @termsConditionsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Account Registration & Verification'**
  String get termsConditionsSection2Title;

  /// No description provided for @termsConditionsSection2Point1.
  ///
  /// In en, this message translates to:
  /// **'All users must register with valid business and identity information before completing any transaction on the Platform.'**
  String get termsConditionsSection2Point1;

  /// No description provided for @termsConditionsSection2Point2.
  ///
  /// In en, this message translates to:
  /// **'Bosdom reserves the right to reject or suspend account registrations that fail identity verification or contain false information.'**
  String get termsConditionsSection2Point2;

  /// No description provided for @termsConditionsSection2Point3.
  ///
  /// In en, this message translates to:
  /// **'Each user is limited to one verified merchant profile per business.'**
  String get termsConditionsSection2Point3;

  /// No description provided for @termsConditionsSection2Point4.
  ///
  /// In en, this message translates to:
  /// **'Suppliers are required to provide accurate product listings, pricing, and inventory information at all times.'**
  String get termsConditionsSection2Point4;

  /// No description provided for @termsConditionsSection2Point5.
  ///
  /// In en, this message translates to:
  /// **'Buyers are responsible for keeping their account and business information up to date.'**
  String get termsConditionsSection2Point5;

  /// No description provided for @termsConditionsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Try-Before-You-Bulk Sample Gate'**
  String get termsConditionsSection3Title;

  /// No description provided for @termsConditionsSection3Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom\'s Sample Gate lets buyers order a single unit of a product at consumer price before committing to a bulk wholesale purchase.'**
  String get termsConditionsSection3Point1;

  /// No description provided for @termsConditionsSection3Point2.
  ///
  /// In en, this message translates to:
  /// **'Each buyer is limited to one sample order per product to prevent misuse of the feature.'**
  String get termsConditionsSection3Point2;

  /// No description provided for @termsConditionsSection3Point3.
  ///
  /// In en, this message translates to:
  /// **'Sample orders do not carry wholesale pricing and are subject to standard shipping and handling fees.'**
  String get termsConditionsSection3Point3;

  /// No description provided for @termsConditionsSection3Point4.
  ///
  /// In en, this message translates to:
  /// **'Suppliers must fulfill sample orders with the same product quality advertised in the listing. Misrepresenting sample quality is a violation of these Terms.'**
  String get termsConditionsSection3Point4;

  /// No description provided for @termsConditionsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Collaborative Social Co-Buying'**
  String get termsConditionsSection4Title;

  /// No description provided for @termsConditionsSection4Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom\'s Co-Buy feature lets buyers combine orders with other merchants to unlock wholesale bulk pricing.'**
  String get termsConditionsSection4Point1;

  /// No description provided for @termsConditionsSection4Point2.
  ///
  /// In en, this message translates to:
  /// **'Any registered buyer may start a co-buy pool by selecting \"Invite to Co-Buy\" on an eligible product and sharing the generated invite link.'**
  String get termsConditionsSection4Point2;

  /// No description provided for @termsConditionsSection4Point3.
  ///
  /// In en, this message translates to:
  /// **'Once a pool reaches its target quantity, the supplier fulfills the order under the applicable bulk pricing tier.'**
  String get termsConditionsSection4Point3;

  /// No description provided for @termsConditionsSection4Point4.
  ///
  /// In en, this message translates to:
  /// **'Participants share shipping costs proportionally to their share of the order.'**
  String get termsConditionsSection4Point4;

  /// No description provided for @termsConditionsSection4Point5.
  ///
  /// In en, this message translates to:
  /// **'If a co-buy pool does not reach its required threshold within the specified timeframe, all funds are automatically refunded to participants.'**
  String get termsConditionsSection4Point5;

  /// No description provided for @termsConditionsSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Escrow Payment & QR Verification System'**
  String get termsConditionsSection5Title;

  /// No description provided for @termsConditionsSection5Point1.
  ///
  /// In en, this message translates to:
  /// **'All financial transactions on Bosdom are processed through the Platform\'s escrow system.'**
  String get termsConditionsSection5Point1;

  /// No description provided for @termsConditionsSection5Point2.
  ///
  /// In en, this message translates to:
  /// **'Supported payment methods include Bakong (National Bank of Cambodia) and other approved payment gateways.'**
  String get termsConditionsSection5Point2;

  /// No description provided for @termsConditionsSection5Point3.
  ///
  /// In en, this message translates to:
  /// **'Funds are held in escrow until delivery is confirmed.'**
  String get termsConditionsSection5Point3;

  /// No description provided for @termsConditionsSection5Point4.
  ///
  /// In en, this message translates to:
  /// **'Upon delivery, the receiving party must scan the QR code presented by the supplier or courier to confirm receipt.'**
  String get termsConditionsSection5Point4;

  /// No description provided for @termsConditionsSection5Point5.
  ///
  /// In en, this message translates to:
  /// **'Once delivery is confirmed via QR scan, escrow funds are released to the supplier. Delivery issues may be escalated through the dispute resolution process described in Section 8.'**
  String get termsConditionsSection5Point5;

  /// No description provided for @termsConditionsSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Chat Policy & Communication Rules'**
  String get termsConditionsSection6Title;

  /// No description provided for @termsConditionsSection6Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom provides in-app chat for direct communication between buyers and suppliers.'**
  String get termsConditionsSection6Point1;

  /// No description provided for @termsConditionsSection6Point2.
  ///
  /// In en, this message translates to:
  /// **'Before accessing chat, users must review and accept the Chat & Trading Policy and Liability Disclosure.'**
  String get termsConditionsSection6Point2;

  /// No description provided for @termsConditionsSection6Point3.
  ///
  /// In en, this message translates to:
  /// **'The following are prohibited in Platform communications:'**
  String get termsConditionsSection6Point3;

  /// No description provided for @termsConditionsSection6Point4.
  ///
  /// In en, this message translates to:
  /// **'Arranging payments outside the Platform.'**
  String get termsConditionsSection6Point4;

  /// No description provided for @termsConditionsSection6Point5.
  ///
  /// In en, this message translates to:
  /// **'Sharing personal bank details for off-platform payment.'**
  String get termsConditionsSection6Point5;

  /// No description provided for @termsConditionsSection6Point6.
  ///
  /// In en, this message translates to:
  /// **'Sending abusive, fraudulent, or otherwise inappropriate content.'**
  String get termsConditionsSection6Point6;

  /// No description provided for @termsConditionsSection6Point7.
  ///
  /// In en, this message translates to:
  /// **'Bosdom holds no liability for losses arising from off-platform payments or trades arranged in violation of this policy. Violations may result in a warning, account suspension, or permanent ban, depending on severity, at Bosdom\'s sole discretion.'**
  String get termsConditionsSection6Point7;

  /// No description provided for @termsConditionsSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Pricing & Volume Tiers'**
  String get termsConditionsSection7Title;

  /// No description provided for @termsConditionsSection7Point1.
  ///
  /// In en, this message translates to:
  /// **'Suppliers set their own pricing for both sample and bulk purchase tiers.'**
  String get termsConditionsSection7Point1;

  /// No description provided for @termsConditionsSection7Point2.
  ///
  /// In en, this message translates to:
  /// **'Bulk pricing is structured in volume tiers that unlock as a co-buy pool or bulk order grows.'**
  String get termsConditionsSection7Point2;

  /// No description provided for @termsConditionsSection7Point3.
  ///
  /// In en, this message translates to:
  /// **'Applicable pricing tiers are shown on each product listing and update automatically as order volume changes.'**
  String get termsConditionsSection7Point3;

  /// No description provided for @termsConditionsSection7Point4.
  ///
  /// In en, this message translates to:
  /// **'Bosdom does not own, store, or handle physical inventory. Suppliers are solely responsible for product quality, packaging, and inventory accuracy. Prices may be listed in Khmer Riel (KHR) or US Dollars (USD).'**
  String get termsConditionsSection7Point4;

  /// No description provided for @termsConditionsSection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Dispute Resolution'**
  String get termsConditionsSection8Title;

  /// No description provided for @termsConditionsSection8Point1.
  ///
  /// In en, this message translates to:
  /// **'In the event of a dispute, such as damaged goods, non-delivery, or a quality mismatch, Bosdom provides a structured dispute resolution process.'**
  String get termsConditionsSection8Point1;

  /// No description provided for @termsConditionsSection8Point2.
  ///
  /// In en, this message translates to:
  /// **'Escrow funds related to a disputed order remain locked until the dispute is resolved.'**
  String get termsConditionsSection8Point2;

  /// No description provided for @termsConditionsSection8Point3.
  ///
  /// In en, this message translates to:
  /// **'Buyers have a 5-day window after delivery confirmation to file a dispute and submit supporting evidence.'**
  String get termsConditionsSection8Point3;

  /// No description provided for @termsConditionsSection8Point4.
  ///
  /// In en, this message translates to:
  /// **'Bosdom reserves the right to review evidence and adjust escrow disbursement in cases of fraud, non-delivery, or breach of these Terms.'**
  String get termsConditionsSection8Point4;

  /// No description provided for @termsConditionsSection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Prohibited Activities'**
  String get termsConditionsSection9Title;

  /// No description provided for @termsConditionsSection9Point1.
  ///
  /// In en, this message translates to:
  /// **'Users of the Platform must not:'**
  String get termsConditionsSection9Point1;

  /// No description provided for @termsConditionsSection9Point2.
  ///
  /// In en, this message translates to:
  /// **'Sell counterfeit, illegal, or hazardous goods.'**
  String get termsConditionsSection9Point2;

  /// No description provided for @termsConditionsSection9Point3.
  ///
  /// In en, this message translates to:
  /// **'Create multiple accounts to bypass sample-gate limits.'**
  String get termsConditionsSection9Point3;

  /// No description provided for @termsConditionsSection9Point4.
  ///
  /// In en, this message translates to:
  /// **'Manipulate co-buy pools through fake participants or false pricing.'**
  String get termsConditionsSection9Point4;

  /// No description provided for @termsConditionsSection9Point5.
  ///
  /// In en, this message translates to:
  /// **'Engage in price fixing, deceptive advertising, or false product listings.'**
  String get termsConditionsSection9Point5;

  /// No description provided for @termsConditionsSection9Point6.
  ///
  /// In en, this message translates to:
  /// **'Use automated bots or scripts to interact with the Platform.'**
  String get termsConditionsSection9Point6;

  /// No description provided for @termsConditionsSection9Point7.
  ///
  /// In en, this message translates to:
  /// **'Violating any of the above may result in immediate account suspension, forfeiture of pending escrow funds, and, where applicable, referral to relevant authorities.'**
  String get termsConditionsSection9Point7;

  /// No description provided for @termsConditionsSection10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Limitation of Liability'**
  String get termsConditionsSection10Title;

  /// No description provided for @termsConditionsSection10Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom acts solely as a marketplace facilitator connecting buyers and suppliers. To the maximum extent permitted by law, Bosdom is not liable for:'**
  String get termsConditionsSection10Point1;

  /// No description provided for @termsConditionsSection10Point2.
  ///
  /// In en, this message translates to:
  /// **'Product quality, accuracy of descriptions, or supplier claims.'**
  String get termsConditionsSection10Point2;

  /// No description provided for @termsConditionsSection10Point3.
  ///
  /// In en, this message translates to:
  /// **'Delivery timelines or courier performance beyond the Platform\'s control.'**
  String get termsConditionsSection10Point3;

  /// No description provided for @termsConditionsSection10Point4.
  ///
  /// In en, this message translates to:
  /// **'Losses resulting from a user\'s violation of these Terms or applicable Cambodian law.'**
  String get termsConditionsSection10Point4;

  /// No description provided for @termsConditionsSection10Point5.
  ///
  /// In en, this message translates to:
  /// **'Bosdom is not liable for indirect, incidental, or consequential damages arising from use of the Platform.'**
  String get termsConditionsSection10Point5;

  /// No description provided for @termsConditionsSection11Title.
  ///
  /// In en, this message translates to:
  /// **'11. Privacy & Data Protection'**
  String get termsConditionsSection11Title;

  /// No description provided for @termsConditionsSection11Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom collects and processes personal data in accordance with our Privacy Policy and applicable Cambodian data protection laws.'**
  String get termsConditionsSection11Point1;

  /// No description provided for @termsConditionsSection11Point2.
  ///
  /// In en, this message translates to:
  /// **'This includes business registration details, name, phone number, and email address, collected solely for identity verification and Platform operation.'**
  String get termsConditionsSection11Point2;

  /// No description provided for @termsConditionsSection12Title.
  ///
  /// In en, this message translates to:
  /// **'12. Modifications to Terms'**
  String get termsConditionsSection12Title;

  /// No description provided for @termsConditionsSection12Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom reserves the right to update or modify these Terms at any time. Continued use of the Platform after changes take effect constitutes acceptance of the updated Terms.'**
  String get termsConditionsSection12Point1;

  /// No description provided for @termsConditionsSection12Point2.
  ///
  /// In en, this message translates to:
  /// **'Users who do not agree with updated Terms should discontinue use of the Platform.'**
  String get termsConditionsSection12Point2;

  /// No description provided for @termsConditionsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get termsConditionsContactTitle;

  /// No description provided for @termsConditionsContactIntro.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about these Terms & Conditions, please contact us:'**
  String get termsConditionsContactIntro;

  /// No description provided for @termsConditionsContactEmail.
  ///
  /// In en, this message translates to:
  /// **'support@bosdom.com'**
  String get termsConditionsContactEmail;

  /// No description provided for @termsConditionsContactInApp.
  ///
  /// In en, this message translates to:
  /// **'In-app: Help & Support'**
  String get termsConditionsContactInApp;

  /// No description provided for @privacyPolicyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyScreenTitle;

  /// No description provided for @privacyPolicyEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: August 2026'**
  String get privacyPolicyEffectiveDate;

  /// No description provided for @privacyPolicySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyPolicySection1Title;

  /// No description provided for @privacyPolicySection1Point1.
  ///
  /// In en, this message translates to:
  /// **'a) Account Information'**
  String get privacyPolicySection1Point1;

  /// No description provided for @privacyPolicySection1Point2.
  ///
  /// In en, this message translates to:
  /// **'Full name, phone number, and email'**
  String get privacyPolicySection1Point2;

  /// No description provided for @privacyPolicySection1Point3.
  ///
  /// In en, this message translates to:
  /// **'Business name, type, and registration number'**
  String get privacyPolicySection1Point3;

  /// No description provided for @privacyPolicySection1Point4.
  ///
  /// In en, this message translates to:
  /// **'Business location and delivery address'**
  String get privacyPolicySection1Point4;

  /// No description provided for @privacyPolicySection1Point5.
  ///
  /// In en, this message translates to:
  /// **'Profile photo (optional)'**
  String get privacyPolicySection1Point5;

  /// No description provided for @privacyPolicySection1Point6.
  ///
  /// In en, this message translates to:
  /// **'b) Identity Verification Info'**
  String get privacyPolicySection1Point6;

  /// No description provided for @privacyPolicySection1Point7.
  ///
  /// In en, this message translates to:
  /// **'Government-issued ID (for buyer verification)'**
  String get privacyPolicySection1Point7;

  /// No description provided for @privacyPolicySection1Point8.
  ///
  /// In en, this message translates to:
  /// **'Business registration certificate (for supplier verification)'**
  String get privacyPolicySection1Point8;

  /// No description provided for @privacyPolicySection1Point9.
  ///
  /// In en, this message translates to:
  /// **'Bank account/e-wallet details (Bakong QR) for payments'**
  String get privacyPolicySection1Point9;

  /// No description provided for @privacyPolicySection1Point10.
  ///
  /// In en, this message translates to:
  /// **'c) Transaction Data'**
  String get privacyPolicySection1Point10;

  /// No description provided for @privacyPolicySection1Point11.
  ///
  /// In en, this message translates to:
  /// **'Order history, purchase amounts, and payment methods'**
  String get privacyPolicySection1Point11;

  /// No description provided for @privacyPolicySection1Point12.
  ///
  /// In en, this message translates to:
  /// **'Sample order and co-buy pool participation'**
  String get privacyPolicySection1Point12;

  /// No description provided for @privacyPolicySection1Point13.
  ///
  /// In en, this message translates to:
  /// **'d) Communication Data'**
  String get privacyPolicySection1Point13;

  /// No description provided for @privacyPolicySection1Point14.
  ///
  /// In en, this message translates to:
  /// **'In-app chat messages and conversation history'**
  String get privacyPolicySection1Point14;

  /// No description provided for @privacyPolicySection1Point15.
  ///
  /// In en, this message translates to:
  /// **'Chat attachments shared between participants'**
  String get privacyPolicySection1Point15;

  /// No description provided for @privacyPolicySection1Point16.
  ///
  /// In en, this message translates to:
  /// **'e) Verification & Fraud Detection'**
  String get privacyPolicySection1Point16;

  /// No description provided for @privacyPolicySection1Point17.
  ///
  /// In en, this message translates to:
  /// **'QR code scans used for delivery confirmation'**
  String get privacyPolicySection1Point17;

  /// No description provided for @privacyPolicySection1Point18.
  ///
  /// In en, this message translates to:
  /// **'Video evidence submitted with dispute resolution'**
  String get privacyPolicySection1Point18;

  /// No description provided for @privacyPolicySection1Point19.
  ///
  /// In en, this message translates to:
  /// **'f) Device & Usage Data'**
  String get privacyPolicySection1Point19;

  /// No description provided for @privacyPolicySection1Point20.
  ///
  /// In en, this message translates to:
  /// **'Device type, operating system, and app version'**
  String get privacyPolicySection1Point20;

  /// No description provided for @privacyPolicySection1Point21.
  ///
  /// In en, this message translates to:
  /// **'Location data used for delivery and courier matching'**
  String get privacyPolicySection1Point21;

  /// No description provided for @privacyPolicySection1Point22.
  ///
  /// In en, this message translates to:
  /// **'IP address and general session/log information'**
  String get privacyPolicySection1Point22;

  /// No description provided for @privacyPolicySection1Point23.
  ///
  /// In en, this message translates to:
  /// **'g) Co-Buy & Social Data'**
  String get privacyPolicySection1Point23;

  /// No description provided for @privacyPolicySection1Point24.
  ///
  /// In en, this message translates to:
  /// **'Co-buy invitation creation and participation'**
  String get privacyPolicySection1Point24;

  /// No description provided for @privacyPolicySection1Point25.
  ///
  /// In en, this message translates to:
  /// **'Invite link clicks and pool-joining activity'**
  String get privacyPolicySection1Point25;

  /// No description provided for @privacyPolicySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacyPolicySection2Title;

  /// No description provided for @privacyPolicySection2Point1.
  ///
  /// In en, this message translates to:
  /// **'We use your personal data for the following purposes:'**
  String get privacyPolicySection2Point1;

  /// No description provided for @privacyPolicySection2Point2.
  ///
  /// In en, this message translates to:
  /// **'a) Platform Operations'**
  String get privacyPolicySection2Point2;

  /// No description provided for @privacyPolicySection2Point3.
  ///
  /// In en, this message translates to:
  /// **'To create and manage your buyer or seller account'**
  String get privacyPolicySection2Point3;

  /// No description provided for @privacyPolicySection2Point4.
  ///
  /// In en, this message translates to:
  /// **'To process orders, payments, and shipment tracking'**
  String get privacyPolicySection2Point4;

  /// No description provided for @privacyPolicySection2Point5.
  ///
  /// In en, this message translates to:
  /// **'To facilitate the Try-Before-You-Bulk sample gate feature'**
  String get privacyPolicySection2Point5;

  /// No description provided for @privacyPolicySection2Point6.
  ///
  /// In en, this message translates to:
  /// **'To enable Co-Buy session creation and order pooling'**
  String get privacyPolicySection2Point6;

  /// No description provided for @privacyPolicySection2Point7.
  ///
  /// In en, this message translates to:
  /// **'b) Trust & Safety'**
  String get privacyPolicySection2Point7;

  /// No description provided for @privacyPolicySection2Point8.
  ///
  /// In en, this message translates to:
  /// **'To verify identity for suppliers and buyers'**
  String get privacyPolicySection2Point8;

  /// No description provided for @privacyPolicySection2Point9.
  ///
  /// In en, this message translates to:
  /// **'To confirm order delivery via QR code scan'**
  String get privacyPolicySection2Point9;

  /// No description provided for @privacyPolicySection2Point10.
  ///
  /// In en, this message translates to:
  /// **'To detect and prevent off-platform payment or contact violations'**
  String get privacyPolicySection2Point10;

  /// No description provided for @privacyPolicySection2Point11.
  ///
  /// In en, this message translates to:
  /// **'To process disputes, evidence submissions, and refund requests'**
  String get privacyPolicySection2Point11;

  /// No description provided for @privacyPolicySection2Point12.
  ///
  /// In en, this message translates to:
  /// **'c) Payment Processing & Analytics'**
  String get privacyPolicySection2Point12;

  /// No description provided for @privacyPolicySection2Point13.
  ///
  /// In en, this message translates to:
  /// **'To securely process payments through Bakong and other integrated payment providers'**
  String get privacyPolicySection2Point13;

  /// No description provided for @privacyPolicySection2Point14.
  ///
  /// In en, this message translates to:
  /// **'To hold funds in escrow until delivery is confirmed'**
  String get privacyPolicySection2Point14;

  /// No description provided for @privacyPolicySection2Point15.
  ///
  /// In en, this message translates to:
  /// **'To analyze usage patterns and improve app features and performance'**
  String get privacyPolicySection2Point15;

  /// No description provided for @privacyPolicySection2Point16.
  ///
  /// In en, this message translates to:
  /// **'To personalize product recommendations and search suggestions'**
  String get privacyPolicySection2Point16;

  /// No description provided for @privacyPolicySection2Point17.
  ///
  /// In en, this message translates to:
  /// **'d) Push Notifications'**
  String get privacyPolicySection2Point17;

  /// No description provided for @privacyPolicySection2Point18.
  ///
  /// In en, this message translates to:
  /// **'To notify you about order status updates, chat messages, co-buy progress, and important account activity'**
  String get privacyPolicySection2Point18;

  /// No description provided for @privacyPolicySection2Point19.
  ///
  /// In en, this message translates to:
  /// **'e) Legal Compliance'**
  String get privacyPolicySection2Point19;

  /// No description provided for @privacyPolicySection2Point20.
  ///
  /// In en, this message translates to:
  /// **'To comply with applicable legal requirements'**
  String get privacyPolicySection2Point20;

  /// No description provided for @privacyPolicySection2Point21.
  ///
  /// In en, this message translates to:
  /// **'To respond to lawful requests from authorities'**
  String get privacyPolicySection2Point21;

  /// No description provided for @privacyPolicySection2Point22.
  ///
  /// In en, this message translates to:
  /// **'f) Business Transfers'**
  String get privacyPolicySection2Point22;

  /// No description provided for @privacyPolicySection2Point23.
  ///
  /// In en, this message translates to:
  /// **'In the event of a merger, acquisition, or asset sale, information may be transferred as part of the business assets, subject to equivalent privacy protection'**
  String get privacyPolicySection2Point23;

  /// No description provided for @privacyPolicySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. How We Share Your Information'**
  String get privacyPolicySection3Title;

  /// No description provided for @privacyPolicySection3Point1.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal data. We only share information in the following circumstances:'**
  String get privacyPolicySection3Point1;

  /// No description provided for @privacyPolicySection3Point2.
  ///
  /// In en, this message translates to:
  /// **'a) Between Buyers & Sellers'**
  String get privacyPolicySection3Point2;

  /// No description provided for @privacyPolicySection3Point3.
  ///
  /// In en, this message translates to:
  /// **'Business name, rating, and product listings shared to enable trading'**
  String get privacyPolicySection3Point3;

  /// No description provided for @privacyPolicySection3Point4.
  ///
  /// In en, this message translates to:
  /// **'Chat messages shared strictly between chat participants'**
  String get privacyPolicySection3Point4;

  /// No description provided for @privacyPolicySection3Point5.
  ///
  /// In en, this message translates to:
  /// **'b) Payment Providers'**
  String get privacyPolicySection3Point5;

  /// No description provided for @privacyPolicySection3Point6.
  ///
  /// In en, this message translates to:
  /// **'Transaction data shared with Bakong and other approved gateways to complete payments'**
  String get privacyPolicySection3Point6;

  /// No description provided for @privacyPolicySection3Point7.
  ///
  /// In en, this message translates to:
  /// **'c) Service Providers'**
  String get privacyPolicySection3Point7;

  /// No description provided for @privacyPolicySection3Point8.
  ///
  /// In en, this message translates to:
  /// **'Cloud hosting and data storage (Supabase infrastructure)'**
  String get privacyPolicySection3Point8;

  /// No description provided for @privacyPolicySection3Point9.
  ///
  /// In en, this message translates to:
  /// **'Analytics services to improve app performance and user experience'**
  String get privacyPolicySection3Point9;

  /// No description provided for @privacyPolicySection3Point10.
  ///
  /// In en, this message translates to:
  /// **'d) Legal Requirements'**
  String get privacyPolicySection3Point10;

  /// No description provided for @privacyPolicySection3Point11.
  ///
  /// In en, this message translates to:
  /// **'When required by applicable legal requirements'**
  String get privacyPolicySection3Point11;

  /// No description provided for @privacyPolicySection3Point12.
  ///
  /// In en, this message translates to:
  /// **'To protect Bosdom\'s legal rights or investigate fraud'**
  String get privacyPolicySection3Point12;

  /// No description provided for @privacyPolicySection3Point13.
  ///
  /// In en, this message translates to:
  /// **'e) Business Transfers'**
  String get privacyPolicySection3Point13;

  /// No description provided for @privacyPolicySection3Point14.
  ///
  /// In en, this message translates to:
  /// **'In the event of a merger, acquisition, or reorganization of Bosdom, user data may be transferred with equivalent privacy protection commitments'**
  String get privacyPolicySection3Point14;

  /// No description provided for @privacyPolicySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Storage & Security'**
  String get privacyPolicySection4Title;

  /// No description provided for @privacyPolicySection4Point1.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely using Supabase infrastructure, which provides:'**
  String get privacyPolicySection4Point1;

  /// No description provided for @privacyPolicySection4Point2.
  ///
  /// In en, this message translates to:
  /// **'Encryption of data in transit (TLS/SSL) and at rest'**
  String get privacyPolicySection4Point2;

  /// No description provided for @privacyPolicySection4Point3.
  ///
  /// In en, this message translates to:
  /// **'Secure authentication and session management'**
  String get privacyPolicySection4Point3;

  /// No description provided for @privacyPolicySection4Point4.
  ///
  /// In en, this message translates to:
  /// **'Access controls and regular security audits with vulnerability assessments'**
  String get privacyPolicySection4Point4;

  /// No description provided for @privacyPolicySection4Point5.
  ///
  /// In en, this message translates to:
  /// **'Escrow payment information is protected using PCI-compliant payment gateway standards.'**
  String get privacyPolicySection4Point5;

  /// No description provided for @privacyPolicySection4Point6.
  ///
  /// In en, this message translates to:
  /// **'Chat conversations and dispute evidence are encrypted and access-restricted to relevant parties.'**
  String get privacyPolicySection4Point6;

  /// No description provided for @privacyPolicySection4Point7.
  ///
  /// In en, this message translates to:
  /// **'While we implement industry-standard security measures, no method of electronic transmission or storage is 100% secure.'**
  String get privacyPolicySection4Point7;

  /// No description provided for @privacyPolicySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Data Retention'**
  String get privacyPolicySection5Title;

  /// No description provided for @privacyPolicySection5Point1.
  ///
  /// In en, this message translates to:
  /// **'We retain your personal data only for as long as necessary to fulfill the purposes outlined in this policy:'**
  String get privacyPolicySection5Point1;

  /// No description provided for @privacyPolicySection5Point2.
  ///
  /// In en, this message translates to:
  /// **'Account Data: retained while your account is active and for up to 12 months after deletion'**
  String get privacyPolicySection5Point2;

  /// No description provided for @privacyPolicySection5Point3.
  ///
  /// In en, this message translates to:
  /// **'Transaction Records: retained for 5 years for accounting and legal compliance'**
  String get privacyPolicySection5Point3;

  /// No description provided for @privacyPolicySection5Point4.
  ///
  /// In en, this message translates to:
  /// **'Chat Messages: retained for 12 months'**
  String get privacyPolicySection5Point4;

  /// No description provided for @privacyPolicySection5Point5.
  ///
  /// In en, this message translates to:
  /// **'Dispute Evidence: retained for 12 months after resolution'**
  String get privacyPolicySection5Point5;

  /// No description provided for @privacyPolicySection5Point6.
  ///
  /// In en, this message translates to:
  /// **'You may request account deletion at any time by contacting support or using the in-app support feature.'**
  String get privacyPolicySection5Point6;

  /// No description provided for @privacyPolicySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Your Privacy Rights'**
  String get privacyPolicySection6Title;

  /// No description provided for @privacyPolicySection6Point1.
  ///
  /// In en, this message translates to:
  /// **'As a Bosdom user, you have the right to:'**
  String get privacyPolicySection6Point1;

  /// No description provided for @privacyPolicySection6Point2.
  ///
  /// In en, this message translates to:
  /// **'Access: request a copy of the personal data we hold about you'**
  String get privacyPolicySection6Point2;

  /// No description provided for @privacyPolicySection6Point3.
  ///
  /// In en, this message translates to:
  /// **'Correction: update inaccurate or outdated information'**
  String get privacyPolicySection6Point3;

  /// No description provided for @privacyPolicySection6Point4.
  ///
  /// In en, this message translates to:
  /// **'Deletion: request deletion of your personal data, subject to legal retention requirements'**
  String get privacyPolicySection6Point4;

  /// No description provided for @privacyPolicySection6Point5.
  ///
  /// In en, this message translates to:
  /// **'Data Portability: request your data in a machine-readable format'**
  String get privacyPolicySection6Point5;

  /// No description provided for @privacyPolicySection6Point6.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences: manage notification settings within the app'**
  String get privacyPolicySection6Point6;

  /// No description provided for @privacyPolicySection6Point7.
  ///
  /// In en, this message translates to:
  /// **'Opt-Out: opt out of marketing communications at any time'**
  String get privacyPolicySection6Point7;

  /// No description provided for @privacyPolicySection6Point8.
  ///
  /// In en, this message translates to:
  /// **'To exercise these rights, contact us at privacy@bosdom.com or via the in-app Support section.'**
  String get privacyPolicySection6Point8;

  /// No description provided for @privacyPolicySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Chat & Communication Privacy'**
  String get privacyPolicySection7Title;

  /// No description provided for @privacyPolicySection7Point1.
  ///
  /// In en, this message translates to:
  /// **'All in-app chat messages are stored securely and only accessible to conversation participants.'**
  String get privacyPolicySection7Point1;

  /// No description provided for @privacyPolicySection7Point2.
  ///
  /// In en, this message translates to:
  /// **'Bosdom automatically monitors chat content for off-platform contact detection and scam prevention purposes only.'**
  String get privacyPolicySection7Point2;

  /// No description provided for @privacyPolicySection7Point3.
  ///
  /// In en, this message translates to:
  /// **'Flagged messages may be reviewed manually by our Trust & Safety team.'**
  String get privacyPolicySection7Point3;

  /// No description provided for @privacyPolicySection7Point4.
  ///
  /// In en, this message translates to:
  /// **'Soliciting direct contact information through chat may result in account restrictions or bans as outlined in our Terms & Conditions.'**
  String get privacyPolicySection7Point4;

  /// No description provided for @privacyPolicySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Children\'s Privacy'**
  String get privacyPolicySection8Title;

  /// No description provided for @privacyPolicySection8Point1.
  ///
  /// In en, this message translates to:
  /// **'Bosdom is a B2B wholesale marketplace intended for use by verified business users aged 18 and above. We do not knowingly collect data from minors.'**
  String get privacyPolicySection8Point1;

  /// No description provided for @privacyPolicySection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Changes to This Policy'**
  String get privacyPolicySection9Title;

  /// No description provided for @privacyPolicySection9Point1.
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy periodically to reflect changes in our practices, legal requirements, or platform features. Material changes will be communicated via:'**
  String get privacyPolicySection9Point1;

  /// No description provided for @privacyPolicySection9Point2.
  ///
  /// In en, this message translates to:
  /// **'A prominent notice within the app'**
  String get privacyPolicySection9Point2;

  /// No description provided for @privacyPolicySection9Point3.
  ///
  /// In en, this message translates to:
  /// **'Email notification to registered users'**
  String get privacyPolicySection9Point3;

  /// No description provided for @privacyPolicySection9Point4.
  ///
  /// In en, this message translates to:
  /// **'An updated \"Last Modified\" date'**
  String get privacyPolicySection9Point4;

  /// No description provided for @privacyPolicyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privacyPolicyContactTitle;

  /// No description provided for @privacyPolicyContactIntro.
  ///
  /// In en, this message translates to:
  /// **'For privacy-related questions or concerns, please contact:'**
  String get privacyPolicyContactIntro;

  /// No description provided for @privacyPolicyContactEmail.
  ///
  /// In en, this message translates to:
  /// **'privacy@bosdom.com'**
  String get privacyPolicyContactEmail;

  /// No description provided for @privacyPolicyContactInApp.
  ///
  /// In en, this message translates to:
  /// **'In-app: Support & Report an Issue'**
  String get privacyPolicyContactInApp;

  /// No description provided for @privacyPolicyContactLocation.
  ///
  /// In en, this message translates to:
  /// **'Cambodia'**
  String get privacyPolicyContactLocation;

  /// No description provided for @aboutScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'About Bosdom'**
  String get aboutScreenTitle;

  /// No description provided for @aboutAppTagline.
  ///
  /// In en, this message translates to:
  /// **'The Automated B2B Wholesale Trust Market & Social Co-Buying Network'**
  String get aboutAppTagline;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersionLabel(String version);

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'Bosdom connects verified Cambodian retailers with trusted wholesalers through a secure digital procurement ecosystem featuring sample testing, social co-buying, automated escrow, and real-time chat.'**
  String get aboutMissionBody;

  /// No description provided for @aboutWhyChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Bosdom?'**
  String get aboutWhyChooseTitle;

  /// No description provided for @aboutFeatureSampleTestingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Testing'**
  String get aboutFeatureSampleTestingTitle;

  /// No description provided for @aboutFeatureSampleTestingBody.
  ///
  /// In en, this message translates to:
  /// **'Try before you bulk buy to ensure quality.'**
  String get aboutFeatureSampleTestingBody;

  /// No description provided for @aboutFeatureCoBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Co-Buy Network'**
  String get aboutFeatureCoBuyTitle;

  /// No description provided for @aboutFeatureCoBuyBody.
  ///
  /// In en, this message translates to:
  /// **'Pool orders for direct volume discount prices.'**
  String get aboutFeatureCoBuyBody;

  /// No description provided for @aboutFeatureEscrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Escrow Protection'**
  String get aboutFeatureEscrowTitle;

  /// No description provided for @aboutFeatureEscrowBody.
  ///
  /// In en, this message translates to:
  /// **'Secure automated payments on delivery.'**
  String get aboutFeatureEscrowBody;

  /// No description provided for @aboutFeatureChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Chat'**
  String get aboutFeatureChatTitle;

  /// No description provided for @aboutFeatureChatBody.
  ///
  /// In en, this message translates to:
  /// **'Direct instant supplier communication channel.'**
  String get aboutFeatureChatBody;

  /// No description provided for @aboutOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get aboutOfferTitle;

  /// No description provided for @aboutOfferItem1.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Marketplace'**
  String get aboutOfferItem1;

  /// No description provided for @aboutOfferItem2.
  ///
  /// In en, this message translates to:
  /// **'Volume-tiered pricing models'**
  String get aboutOfferItem2;

  /// No description provided for @aboutOfferItem3.
  ///
  /// In en, this message translates to:
  /// **'Secure QR verification system'**
  String get aboutOfferItem3;

  /// No description provided for @aboutOfferItem4.
  ///
  /// In en, this message translates to:
  /// **'Anti-scam media evidence lockers'**
  String get aboutOfferItem4;

  /// No description provided for @aboutOfferItem5.
  ///
  /// In en, this message translates to:
  /// **'Social invite links'**
  String get aboutOfferItem5;

  /// No description provided for @aboutOfferItem6.
  ///
  /// In en, this message translates to:
  /// **'Instant push notifications'**
  String get aboutOfferItem6;

  /// No description provided for @aboutCompanyInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get aboutCompanyInfoTitle;

  /// No description provided for @aboutCompanyHeadquartersLabel.
  ///
  /// In en, this message translates to:
  /// **'HEADQUARTERS'**
  String get aboutCompanyHeadquartersLabel;

  /// No description provided for @aboutCompanyHeadquartersValue.
  ///
  /// In en, this message translates to:
  /// **'Phnom Penh, Cambodia'**
  String get aboutCompanyHeadquartersValue;

  /// No description provided for @aboutCompanyEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT EMAIL'**
  String get aboutCompanyEmailLabel;

  /// No description provided for @aboutCompanyEmailValue.
  ///
  /// In en, this message translates to:
  /// **'support@bosdom.com'**
  String get aboutCompanyEmailValue;

  /// No description provided for @aboutCompanyWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'WEBSITE'**
  String get aboutCompanyWebsiteLabel;

  /// No description provided for @aboutCompanyWebsiteValue.
  ///
  /// In en, this message translates to:
  /// **'www.bosdom.com'**
  String get aboutCompanyWebsiteValue;

  /// No description provided for @aboutStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get aboutStoryTitle;

  /// No description provided for @aboutStoryBody.
  ///
  /// In en, this message translates to:
  /// **'Founded to solve trust deficiencies in Cambodia\'s B2B retail supply chain, Bosdom deploys an independent secure digital procurement ecosystem to empower small-to-medium retail owners.'**
  String get aboutStoryBody;

  /// No description provided for @aboutStatRetailers.
  ///
  /// In en, this message translates to:
  /// **'Retailers'**
  String get aboutStatRetailers;

  /// No description provided for @aboutStatSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get aboutStatSuppliers;

  /// No description provided for @aboutStatSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get aboutStatSuccessRate;

  /// No description provided for @aboutValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Values'**
  String get aboutValuesTitle;

  /// No description provided for @aboutValueTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust & Transparency'**
  String get aboutValueTrustTitle;

  /// No description provided for @aboutValueRetailerFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Retailer First'**
  String get aboutValueRetailerFirstTitle;

  /// No description provided for @aboutValueInnovationTitle.
  ///
  /// In en, this message translates to:
  /// **'Innovation'**
  String get aboutValueInnovationTitle;

  /// No description provided for @aboutFooterCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024-2026 Bosdom. All rights reserved.'**
  String get aboutFooterCopyright;

  /// No description provided for @variantSelectOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Options'**
  String get variantSelectOptionsTitle;

  /// No description provided for @variantSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get variantSizeLabel;

  /// No description provided for @variantColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get variantColorLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
