// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'BosDom';

  @override
  String get commonBack => 'ថយក្រោយ';

  @override
  String get commonSave => 'រក្សាទុក';

  @override
  String get commonSaveChanges => 'រក្សាទុកការផ្លាស់ប្តូរ';

  @override
  String get commonSaved => 'បានរក្សាទុក';

  @override
  String get commonCancel => 'បោះបង់';

  @override
  String get commonContinue => 'បន្ត';

  @override
  String get commonDone => 'រួចរាល់';

  @override
  String get commonEdit => 'កែសម្រួល';

  @override
  String get commonDelete => 'លុប';

  @override
  String get commonRemove => 'ដកចេញ';

  @override
  String get commonConfirm => 'បញ្ជាក់';

  @override
  String get commonRetry => 'ព្យាយាមម្តងទៀត';

  @override
  String get commonSeeAll => 'មើលទាំងអស់';

  @override
  String commonComingSoon(String label) {
    return '$label នឹងមកដល់ឆាប់ៗនេះ';
  }

  @override
  String get navHome => 'ទំព័រដើម';

  @override
  String get navSearch => 'ស្វែងរក';

  @override
  String get navWishlist => 'ចំណូលចិត្ត';

  @override
  String get navCart => 'រទេះទំនិញ';

  @override
  String get navAccount => 'គណនី';

  @override
  String get languageScreenTitle => 'ភាសា';

  @override
  String get languageScreenIntro =>
      'ជ្រើសរើសភាសាដែលអ្នកចង់ប្រើសម្រាប់កម្មវិធី Bosdom។';

  @override
  String get languageSectionLabel => 'ជ្រើសរើសភាសា';

  @override
  String get languageEnglishLabel => 'English';

  @override
  String get languageEnglishSublabel => 'ភាសាលំនាំដើម';

  @override
  String get languageKhmerLabel => 'ភាសាខ្មែរ (Khmer)';

  @override
  String get languageKhmerSublabel => 'ភាសាកម្ពុជា';

  @override
  String get languageNoteTitle => 'សូមចំណាំ';

  @override
  String get languageNoteBody =>
      'ការផ្លាស់ប្តូរភាសានឹងចាប់ផ្តើមចំណុចប្រទាក់កម្មវិធីឡើងវិញ។ ខ្លឹមសារអ្នកផ្គត់ផ្គង់មួយចំនួនអាចនៅតែជាភាសាដើម។';

  @override
  String languageSavedSnackbar(String language) {
    return 'ភាសាត្រូវបានកំណត់ទៅជា $language';
  }

  @override
  String get authLoginEmailLabel => 'អ៊ីមែល';

  @override
  String get authLoginEmailHint => 'you@example.com';

  @override
  String get authLoginPasswordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get authLoginPasswordHint => 'បញ្ចូលពាក្យសម្ងាត់';

  @override
  String get authLoginForgotPassword => 'ភ្លេចពាក្យសម្ងាត់?';

  @override
  String get authLoginPasswordResetComingSoon =>
      'មុខងារកំណត់ពាក្យសម្ងាត់ឡើងវិញ នឹងមកដល់ឆាប់ៗនេះ';

  @override
  String get authLoginSignInButton => 'ចូលគណនី';

  @override
  String get authLoginOrSignUpWith => 'ឬចុះឈ្មោះជាមួយ';

  @override
  String get authLoginGoogleButton => 'Google';

  @override
  String get authLoginNewMerchantPrompt => 'អ្នកលក់ថ្មី? ';

  @override
  String get authLoginCreateAccount => 'បង្កើតគណនី';

  @override
  String get authLoginWelcomeTitle => 'សូមស្វាគមន៍ត្រឡប់មកវិញ\nពាណិជ្ជករ';

  @override
  String get authLoginSubtitle => 'ចូលទៅកាន់គណនីលក់ដុំរបស់អ្នក';

  @override
  String get authSignupJoiningPrompt => 'ខ្ញុំចូលរួម BosDom ក្នុងនាមជា...';

  @override
  String get authSignupChooseRoleTitle => 'ជ្រើសរើសតួនាទីរបស់អ្នក';

  @override
  String authSignupStepLabel(String total) {
    return 'ជំហានទី 1 នៃ $total';
  }

  @override
  String get authBusinessInfoTitle => 'ព័ត៌មានអាជីវកម្ម';

  @override
  String authBusinessInfoStepLabel(String current, String total) {
    return 'ជំហានទី $current នៃ $total';
  }

  @override
  String get authBusinessInfoShopNameLabel => 'ឈ្មោះហាង / អាជីវកម្ម';

  @override
  String get authBusinessInfoShopNameHint => 'ឧ. Angkor Wholesale Co.';

  @override
  String get authBusinessInfoStoreTypeLabel => 'ប្រភេទហាង';

  @override
  String get authBusinessInfoStoreTypeHint => 'ជ្រើសរើសប្រភេទ';

  @override
  String get authBusinessInfoStoreTypePhysical => 'ហាងជាក់ស្តែង';

  @override
  String get authBusinessInfoStoreTypeOnline => 'ហាងអនឡាញ';

  @override
  String get authBusinessInfoStoreTypeBoth => 'ទាំងជាក់ស្តែង និងអនឡាញ';

  @override
  String get authBusinessInfoStorePhotosLabel => 'រូបភាពហាង';

  @override
  String get authBusinessInfoPhotosUploadTitle => 'ចុចដើម្បីបញ្ចូលរូបភាពហាង';

  @override
  String get authBusinessInfoPhotosUploadSubtitle =>
      '(រូបថតហាងជាក់ស្តែង ឬអេក្រង់ហាងអនឡាញ)';

  @override
  String get authBusinessInfoStoreUrlLabel => 'តំណភ្ជាប់ហាងអនឡាញ (ស្រេចចិត្ត)';

  @override
  String get authBusinessInfoStoreUrlHint => 'ឧ. facebook.com/yourshop';

  @override
  String get authBusinessInfoProvinceLabel => 'ខេត្ត / ក្រុង';

  @override
  String get authBusinessInfoProvinceHint => 'ជ្រើសរើសខេត្ត...';

  @override
  String get authBusinessInfoProvincePhnomPenh => 'ភ្នំពេញ';

  @override
  String get authBusinessInfoProvinceKandal => 'កណ្តាល';

  @override
  String get authBusinessInfoProvinceSiemReap => 'សៀមរាប';

  @override
  String get authBusinessInfoProvinceBattambang => 'បាត់ដំបង';

  @override
  String get authBusinessInfoProvinceKampongCham => 'កំពង់ចាម';

  @override
  String get authBusinessInfoProvincePreahSihanouk => 'ព្រះសីហនុ';

  @override
  String get authBusinessInfoDistrictLabel => 'ខណ្ឌ / សង្កាត់';

  @override
  String get authBusinessInfoDistrictHint => 'ជ្រើសរើសខណ្ឌ...';

  @override
  String get authBusinessInfoDistrictChamkarmon => 'ខណ្ឌចំការមន';

  @override
  String get authBusinessInfoDistrictToulKork => 'ខណ្ឌទួលគោក';

  @override
  String get authBusinessInfoDistrictSenSok => 'ខណ្ឌសែនសុខ';

  @override
  String get authBusinessInfoDistrictBoengKengKang => 'ខណ្ឌបឹងកេងកង';

  @override
  String get authBusinessInfoDistrictOther => 'ផ្សេងទៀត';

  @override
  String get authBusinessInfoStreetAddressLabel => 'អាសយដ្ឋានផ្លូវ';

  @override
  String get authBusinessInfoStreetAddressHint => 'ឧ. ផ្លូវ 271, ភ្នំពេញ';

  @override
  String get authBusinessInfoAgreementPrefix => 'ខ្ញុំយល់ព្រមតាម ';

  @override
  String get authBusinessInfoAgreementTermsLink => 'លក្ខខណ្ឌប្រើប្រាស់';

  @override
  String get authBusinessInfoAgreementSuffix =>
      ' របស់ BosDom និងបញ្ជាក់ថាខ្ញុំគឺជាពាណិជ្ជករអាជីវកម្មដែលបានចុះបញ្ជីនៅកម្ពុជា។';

  @override
  String get authBusinessInfoSellerBadgePrefix => '';

  @override
  String get authBusinessInfoSellerBadgeLink => 'ស្លាកអ្នកលក់';

  @override
  String get authBusinessInfoSellerBadgeSuffix =>
      'របស់អ្នកនឹងដំណើរការភ្លាមៗ។ អ្នកអាចចាប់ផ្តើមចុះបញ្ជីផលិតផលបានភ្លាមៗ!';

  @override
  String get authBusinessInfoCreateAccountButton => 'បង្កើតគណនីរបស់ខ្ញុំ';

  @override
  String get authDeliveryAddressStepTitle => 'ព័ត៌មានផ្ទាល់ខ្លួន';

  @override
  String authDeliveryAddressStepLabel(String current, String total) {
    return 'ជំហានទី $current នៃ $total';
  }

  @override
  String get authDeliveryAddressIntroTitle => 'អាសយដ្ឋានដឹកជញ្ជូនរបស់អ្នក';

  @override
  String get authDeliveryAddressIntroBody =>
      'បញ្ចូលអាសយដ្ឋានដឹកជញ្ជូនរបស់អ្នកខាងក្រោម។';

  @override
  String get authDeliveryAddressHouseLabel => 'ផ្ទះលេខ / ផ្លូវលេខ';

  @override
  String get authDeliveryAddressHouseHint => 'ឧ. ផ្ទះលេខ ១២, ផ្លូវ 271';

  @override
  String get authDeliveryAddressSangkatLabel => 'សង្កាត់ / ខណ្ឌ';

  @override
  String get authDeliveryAddressSangkatHint => 'ឧ. សង្កាត់ទំនប់ទឹក';

  @override
  String get authDeliveryAddressProvinceLabel => 'ខេត្ត / ក្រុង';

  @override
  String get authDeliveryAddressProvinceHint => 'ជ្រើសរើសខេត្ត...';

  @override
  String get authDeliveryAddressProvincePhnomPenh => 'ភ្នំពេញ';

  @override
  String get authDeliveryAddressProvinceKandal => 'កណ្តាល';

  @override
  String get authDeliveryAddressProvinceSiemReap => 'សៀមរាប';

  @override
  String get authDeliveryAddressProvinceBattambang => 'បាត់ដំបង';

  @override
  String get authDeliveryAddressProvinceKampongCham => 'កំពង់ចាម';

  @override
  String get authDeliveryAddressProvincePreahSihanouk => 'ព្រះសីហនុ';

  @override
  String get authDeliveryAddressLandmarkLabel =>
      'ចំណុចសំគាល់ជិតបំផុត (ស្រេចចិត្ត)';

  @override
  String get authDeliveryAddressLandmarkHint => 'ឧ. ជិត Lucky Mall';

  @override
  String get authDeliveryAddressAgreementPrefix => 'ខ្ញុំយល់ព្រមតាម ';

  @override
  String get authDeliveryAddressAgreementTermsLink => 'លក្ខខណ្ឌប្រើប្រាស់';

  @override
  String get authDeliveryAddressAgreementSuffix =>
      ' របស់ BosDom ហើយបញ្ជាក់ថាខ្ញុំគឺជាពាណិជ្ជករនៅកម្ពុជា។';

  @override
  String get authDeliveryAddressVerificationPrefix =>
      'អ្នកអាចចាប់ផ្តើមរកមើល និងទិញផលិតផលបានភ្លាមៗ។ អ្នកអាចបញ្ចូលអត្តសញ្ញាណប័ណ្ណអាជីវកម្មនៅពេលក្រោយក្នុង ';

  @override
  String get authDeliveryAddressVerificationProfileLink =>
      'ប្រវត្តិរូប → ការផ្ទៀងផ្ទាត់';

  @override
  String get authDeliveryAddressVerificationMiddle => ' ដើម្បីដោះសោស្លាក ';

  @override
  String get authDeliveryAddressVerificationBadgeLink =>
      'អ្នកទិញដែលបានផ្ទៀងផ្ទាត់';

  @override
  String get authDeliveryAddressVerificationSuffix => '។';

  @override
  String get authDeliveryAddressCreateAccountButton => 'បង្កើតគណនីរបស់ខ្ញុំ';

  @override
  String get authPersonalDetailsTitle => 'ព័ត៌មានផ្ទាល់ខ្លួន';

  @override
  String authPersonalDetailsStepLabel(String current, String total) {
    return 'ជំហានទី $current នៃ $total';
  }

  @override
  String get authPersonalDetailsFullNameLabel => 'ឈ្មោះពេញ';

  @override
  String get authPersonalDetailsFullNameHint => 'ឈ្មោះពេញរបស់អ្នក';

  @override
  String get authPersonalDetailsPhoneLabel => 'លេខទូរស័ព្ទ (+855)';

  @override
  String get authPersonalDetailsPhoneHint => '012 345 678';

  @override
  String get authPersonalDetailsEmailLabel => 'អ៊ីមែល (ស្រេចចិត្ត)';

  @override
  String get authPersonalDetailsEmailHint => 'you@example.com';

  @override
  String get authPersonalDetailsPasswordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get authPersonalDetailsPasswordHint => 'បង្កើតពាក្យសម្ងាត់';

  @override
  String get authPersonalDetailsConfirmPasswordLabel => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get authPersonalDetailsConfirmPasswordHint =>
      'បញ្ចូលពាក្យសម្ងាត់ម្ដងទៀត';

  @override
  String get authUploadDocumentsTitle => 'បញ្ចូលឯកសារ';

  @override
  String authUploadDocumentsStepLabel(String current, String total) {
    return 'ជំហានទី $current នៃ $total';
  }

  @override
  String get authUploadDocumentsIdentityBannerTitle =>
      'ការផ្ទៀងផ្ទាត់អត្តសញ្ញាណ';

  @override
  String get authUploadDocumentsIdentityBannerBody =>
      'បញ្ចូលអត្តសញ្ញាណប័ណ្ណរបស់អ្នកសម្រាប់រក្សាទុក។ ស្លាកអ្នកលក់របស់អ្នកនឹងដំណើរការភ្លាមៗ ដោយមិនចាំបាច់រង់ចាំការបញ្ជាក់ពីអ្នកគ្រប់គ្រង។';

  @override
  String get authUploadDocumentsNationalIdTitle => 'អត្តសញ្ញាណប័ណ្ណជាតិ';

  @override
  String get authUploadDocumentsNationalIdSubtitle =>
      'ផ្នែកខាងមុខ និងខាងក្រោយអត្តសញ្ញាណប័ណ្ណជាតិកម្ពុជារបស់អ្នក';

  @override
  String get authUploadDocumentsPassportTitle => 'លិខិតឆ្លងដែន';

  @override
  String get authUploadDocumentsPassportSubtitle =>
      'ជម្រើសផ្សេងពីអត្តសញ្ញាណប័ណ្ណជាតិ (ស្រេចចិត្ត)';

  @override
  String get authUploadDocumentsBusinessCertTitle => 'វិញ្ញាបនបត្រអាជីវកម្ម';

  @override
  String get authUploadDocumentsBusinessCertSubtitle =>
      'វិញ្ញាបនបត្រចុះបញ្ជីពីក្រសួងពាណិជ្ជកម្ម (ស្រេចចិត្ត ប៉ុន្តែជួយឲ្យការផ្ទៀងផ្ទាត់លឿនជាងមុន)';

  @override
  String get authUploadDocumentsRequiredMarker => ' *';

  @override
  String get authUploadDocumentsOptionalMarker => ' (ស្រេចចិត្ត)';

  @override
  String get authUploadDocumentsUploadedLabel => 'បានបញ្ចូល';

  @override
  String get authUploadDocumentsTapToUploadLabel => 'ចុចដើម្បីបញ្ចូល';

  @override
  String get splashTagline => 'បណ្តាញលក់ដុំដែលគួរឱ្យទុកចិត្ត\nរបស់កម្ពុជា';

  @override
  String get splashBadgeVerified => 'បានផ្ទៀងផ្ទាត់';

  @override
  String get splashBadgeSecure => 'សុវត្ថិភាព';

  @override
  String get splashBadgeWholesale => 'លក់ដុំ';

  @override
  String get splashGetStartedButton => 'ចាប់ផ្តើម';

  @override
  String get splashLoginPrompt => 'មានគណនីរួចហើយ? ចូលគណនី';

  @override
  String get splashFooterNote =>
      'សម្រាប់តែពាណិជ្ជករកម្ពុជាដែលបានចុះបញ្ជីប៉ុណ្ណោះ';

  @override
  String get sampleGateTitle => 'ទិញគំរូ';

  @override
  String get sampleGateBody =>
      'ដំណើរការទិញគំរូ ១ ក្នុងមួយគណនី. ចំណុចប្រទាក់នឹងមកដល់នៅដំណាក់កាលទី ៤';

  @override
  String cartMovedToWishlistSnackbar(String productName) {
    return '$productName ត្រូវបានផ្លាស់ទៅបញ្ជីចង់បាន';
  }

  @override
  String get cartProceedToCheckout => 'បន្តទៅការទូទាត់';

  @override
  String get cartScreenTitle => 'កន្ត្រករបស់ខ្ញុំ';

  @override
  String get cartSelectAll => 'ជ្រើសរើសទាំងអស់';

  @override
  String cartItemsCount(int count) {
    return '$count ធាតុ';
  }

  @override
  String get cartWishlistAction => 'បញ្ជីចង់បាន';

  @override
  String cartUnitPrice(String price) {
    return 'ឯកតា៖ $price';
  }

  @override
  String get cartSubtotal => 'សរុបរង';

  @override
  String get cartEstimatedShipping => 'ការដឹកជញ្ជូនប៉ាន់ស្មាន';

  @override
  String get cartEscrowFee => 'កម្រៃសេវាធានា (២%)';

  @override
  String get cartTotalAmount => 'ចំនួនទឹកប្រាក់សរុប';

  @override
  String get cartEmptyState => 'កន្ត្រករបស់អ្នកទទេ';

  @override
  String get checkoutDeliveryAddressLabel => 'អាសយដ្ឋានដឹកជញ្ជូន';

  @override
  String get checkoutOrderItemsLabel => 'ទំនិញក្នុងការបញ្ជាទិញ';

  @override
  String checkoutItemsCount(int count) {
    return '$count ធាតុ';
  }

  @override
  String get checkoutShippingMethodLabel => 'វិធីសាស្ត្រដឹកជញ្ជូន';

  @override
  String get checkoutShippingUnavailableLabel =>
      'មិនអាចប្រើសម្រាប់ទម្ងន់/អាសយដ្ឋាននេះទេ';

  @override
  String get checkoutEscrowNotice =>
      'ថវិកាត្រូវបានរក្សាទុកក្នុងគណនីធានារហូតដល់ការដឹកជញ្ជូនត្រូវបានបញ្ជាក់។';

  @override
  String get checkoutContinueToPayment => 'បន្តទៅការទូទាត់ប្រាក់';

  @override
  String get checkoutScreenTitle => 'ការទូទាត់';

  @override
  String get checkoutNoAddressYet => 'មិនទាន់មានអាសយដ្ឋានដឹកជញ្ជូននៅឡើយ';

  @override
  String get checkoutChangeAddress => 'ផ្លាស់ប្ដូរ';

  @override
  String get checkoutOrderSummaryTitle => 'សេចក្ដីសង្ខេបការបញ្ជាទិញ';

  @override
  String get checkoutSubtotal => 'សរុបរង';

  @override
  String get checkoutShippingLabel => 'ការដឹកជញ្ជូន';

  @override
  String get checkoutEscrowFeeLabel => 'កម្រៃសេវាធានា (២%)';

  @override
  String get checkoutTotalAmount => 'ចំនួនទឹកប្រាក់សរុប';

  @override
  String get checkoutStepCart => 'កន្ត្រក';

  @override
  String get checkoutStepCheckout => 'ការទូទាត់';

  @override
  String get checkoutStepPayment => 'ការបង់ប្រាក់';

  @override
  String get addressLabelFieldLabel => 'ស្លាកអាសយដ្ឋាន';

  @override
  String get addressLabelFieldHint => 'ឧ. ផ្ទះ, ឃ្លាំង, ហាង';

  @override
  String get addressHouseFieldLabel => 'ផ្ទះ / លេខផ្លូវ';

  @override
  String get addressHouseFieldHint => 'ឧ. អគារ B, តំបន់ ៣, មហាវិថីវេងស្រេង';

  @override
  String get addressSangkatFieldLabel => 'សង្កាត់ / ស្រុក';

  @override
  String get addressSangkatFieldHint => 'ឧ. សង្កាត់ជាំចារ';

  @override
  String get addressLandmarkFieldLabel => 'ចំណុចសម្គាល់ជិតបំផុត (ស្រេចចិត្ត)';

  @override
  String get addressLandmarkFieldHint => 'ឧ. ក្បែរដំបូលវេងស្រេង';

  @override
  String get addressPhoneFieldLabel => 'លេខទូរស័ព្ទទំនាក់ទំនង';

  @override
  String get addressPhoneFieldHint => 'ឧ. +855 76 227 5858';

  @override
  String get addressProvinceFieldLabel => 'ខេត្ត / ក្រុង';

  @override
  String get addressProvinceFieldHint => 'ជ្រើសរើសខេត្ត...';

  @override
  String get addressFieldRequiredError => 'ត្រូវការបំពេញ';

  @override
  String get addressSetDefaultTitle => 'កំណត់ជាអាសយដ្ឋានលំនាំដើម';

  @override
  String get addressSetDefaultSubtitle =>
      'ដឹកជញ្ជូនការបញ្ជាទិញសំខាន់ៗទាំងអស់មកទីនេះ';

  @override
  String get addressSaveButton => 'រក្សាទុកអាសយដ្ឋាន';

  @override
  String get addressAddScreenTitle => 'បន្ថែមអាសយដ្ឋាន';

  @override
  String get addressBookSelectionSubtitle =>
      'ចុចលើអាសយដ្ឋានមួយដើម្បីដឹកជញ្ជូនមកទីនេះ';

  @override
  String get addressAddNewButton => 'បន្ថែមអាសយដ្ឋានថ្មី';

  @override
  String get addressBookScreenTitle => 'សៀវភៅអាសយដ្ឋាន';

  @override
  String get addressDefaultBadge => 'លំនាំដើម';

  @override
  String get storeAddressBookScreenTitle => 'អាសយដ្ឋានហាង';

  @override
  String get storeAddressAddNewButton => 'បន្ថែមអាសយដ្ឋានហាងថ្មី';

  @override
  String get storeAddressAddScreenTitle => 'បន្ថែមអាសយដ្ឋានហាង';

  @override
  String get storeAddressLabelFieldLabel => 'ស្លាកអាសយដ្ឋាន';

  @override
  String get storeAddressLabelFieldHint => 'ឧ. ការិយាល័យកណ្តាលភ្នំពេញ';

  @override
  String get storeAddressNameFieldLabel => 'ឈ្មោះហាង / អាជីវកម្ម';

  @override
  String get storeAddressNameFieldHint => 'ឧ. ហាង Angkor Artisans';

  @override
  String get storeAddressBusinessTypeFieldLabel => 'ប្រភេទអាជីវកម្ម';

  @override
  String get storeAddressBusinessTypeFieldHint => 'ឧ. លក់ដុំ និងផលិត';

  @override
  String get storeAddressFullAddressFieldLabel => 'អាសយដ្ឋានពេញលេញ';

  @override
  String get storeAddressFullAddressFieldHint =>
      'ឧ. ផ្ទះលេខ ១២៤, ផ្លូវ ២៧១, សង្កាត់បឹងសាឡាង';

  @override
  String get storeAddressDistrictFieldLabel => 'សង្កាត់ / ស្រុក';

  @override
  String get storeAddressDistrictFieldHint => 'ឧ. សង្កាត់ទឹកថ្លា';

  @override
  String get storeAddressProvinceFieldLabel => 'ខេត្ត / ក្រុង';

  @override
  String get storeAddressProvinceFieldHint => 'ឧ. ភ្នំពេញ';

  @override
  String get storeAddressPhoneFieldLabel => 'លេខទូរស័ព្ទទំនាក់ទំនង';

  @override
  String get storeAddressPhoneFieldHint => 'ឧ. +855 76 227 5858';

  @override
  String get storeAddressEmailFieldLabel => 'អ៊ីមែលទំនាក់ទំនង';

  @override
  String get storeAddressEmailFieldHint => 'ឧ. orders@angkorartisans.com';

  @override
  String get storeAddressHoursFieldLabel => 'ម៉ោងបើកធ្វើការ';

  @override
  String get storeAddressHoursFieldHint =>
      'ឧ. ច័ន្ទ - សុក្រ: ៨:០០ ព្រឹក - ៥:៣០ ល្ងាច';

  @override
  String get storeAddressFieldRequiredError => 'ត្រូវការបំពេញ';

  @override
  String get storeAddressEmailInvalidError => 'សូមបញ្ចូលអ៊ីមែលត្រឹមត្រូវ';

  @override
  String get storeAddressSetDefaultTitle => 'កំណត់ជាអាសយដ្ឋានហាងលំនាំដើម';

  @override
  String get storeAddressSetDefaultSubtitle =>
      'ដឹកជញ្ជូន និងចាត់ចែងការបញ្ជាទិញសំខាន់ៗទាំងអស់ពីទីនេះ';

  @override
  String get storeAddressSaveButton => 'រក្សាទុកអាសយដ្ឋានហាង';

  @override
  String get storeAddressDefaultBadge => 'លំនាំដើម';

  @override
  String get storeAddressEmptyState =>
      'មិនទាន់មានអាសយដ្ឋានហាងទេ។ បន្ថែមមួយដើម្បីចាប់ផ្តើមដឹកជញ្ជូនពីទីតាំងថេរ។';

  @override
  String get chatScreenTitle => 'ជជែក';

  @override
  String get chatSearchHint => 'ស្វែងរកការសន្ទនា...';

  @override
  String get chatEmptyTitle => 'មិនទាន់មានការសន្ទនាទេ';

  @override
  String chatEmptyQuery(String query) {
    return 'រកមិនឃើញការសន្ទនាដែលត្រូវនឹង \"$query\"';
  }

  @override
  String get chatLoadError => 'មិនអាចផ្ទុកការសន្ទនាបានទេ';

  @override
  String get chatDetailLoadError => 'មិនអាចផ្ទុកការសន្ទនានេះបានទេ';

  @override
  String get chatStatusOnline => 'កំពុងអនឡាញ';

  @override
  String get chatStatusOffline => 'គ្មានអនឡាញ';

  @override
  String get chatPolicySecurePayTitle =>
      'សូមទូទាត់ប្រាក់តាមរយៈ Bosdom Secure Pay តែប៉ុណ្ណោះ';

  @override
  String get chatPolicyBannerBody =>
      'ការទូទាត់ប្រាក់ដោយផ្ទាល់ទៅអ្នកលក់ក្រៅកម្មវិធី មិនស្ថិតក្រោមការការពារអ្នកទិញរបស់ Bosdom ទេ។ សូមរក្សាប្រតិបត្តិការក្នុង Secure Pay ដើម្បីទទួលបានការការពារ។';

  @override
  String get chatFlaggedBadge => 'ការទាក់ទងក្រៅវេទិកាត្រូវបានដាក់ទង់';

  @override
  String get chatOffPlatformWarning =>
      'សារនេះប្រហែលជាចែករំលែកព័ត៌មានទំនាក់ទំនង ឬរៀបចំកិច្ចព្រមព្រៀងក្រៅ Bosdom៖ អ្នកនឹងមិនត្រូវបានការពារជាអ្នកទិញនោះទេ។';

  @override
  String get chatPhotoAttachmentComingSoon => 'ការភ្ជាប់រូបថតនឹងមកដល់ឆាប់ៗនេះ';

  @override
  String get chatComposerHint => 'វាយសារ...';

  @override
  String get chatAttachPhotoCamera => 'ថតរូប';

  @override
  String get chatAttachPhotoGallery => 'ជ្រើសរើសពីវិចិត្រសាល';

  @override
  String get liveChatTitle => 'ជជែកផ្ទាល់';

  @override
  String get liveChatStatusOnline => 'កំពុងអនឡាញ • ឆ្លើយតបភ្លាមៗ';

  @override
  String get liveChatStatusOffline =>
      'គ្មានអនឡាញ • យើងនឹងឆ្លើយតបនៅពេលត្រឡប់មកវិញ';

  @override
  String get liveChatSecurityNoticeTitle => 'សេចក្តីជូនដំណឹងសុវត្ថិភាព';

  @override
  String get liveChatSecurityNoticeBody =>
      'សូមទូទាត់ប្រាក់តាមរយៈវេទិកាសុវត្ថិភាពផ្លូវការរបស់ Bosdom តែប៉ុណ្ណោះ។ ក្រុមគាំទ្រនឹងមិនស្នើសុំការផ្ទេរប្រាក់ចូលធនាគារដោយផ្ទាល់តាមរយៈជជែកទេ។';

  @override
  String get liveChatSuggestedTopicsLabel => 'ប្រធានបទណែនាំ';

  @override
  String get liveChatTopicOrderStatus => 'ស្ថានភាពការបញ្ជាទិញ';

  @override
  String get liveChatTopicOrderStatusMessage =>
      'សួស្តី ខ្ញុំចង់ដឹងព័ត៌មានថ្មីអំពីស្ថានភាពការបញ្ជាទិញរបស់ខ្ញុំ។';

  @override
  String get liveChatTopicPaymentIssue => 'បញ្ហាការទូទាត់ប្រាក់';

  @override
  String get liveChatTopicPaymentIssueMessage =>
      'សួស្តី ខ្ញុំកំពុងជួបបញ្ហាទាក់ទងនឹងការទូទាត់ប្រាក់។';

  @override
  String get liveChatTopicRefundReturn => 'ការសងប្រាក់ / ការត្រឡប់ទំនិញ';

  @override
  String get liveChatTopicRefundReturnMessage =>
      'សួស្តី ខ្ញុំចង់ស្នើសុំការសងប្រាក់ឬត្រឡប់ទំនិញ។';

  @override
  String get liveChatTopicShippingRates => 'អត្រាដឹកជញ្ជូន';

  @override
  String get liveChatTopicShippingRatesMessage =>
      'សួស្តី តើអ្នកអាចប្រាប់ខ្ញុំបន្ថែមអំពីអត្រាដឹកជញ្ជូនរបស់អ្នកបានទេ?';

  @override
  String chatPolicyLoadError(String error) {
    return 'មិនអាចផ្ទុកការកំណត់ជជែកបានទេ៖ $error';
  }

  @override
  String get chatPolicyIntro =>
      'មុននឹងចាប់ផ្តើមជជែកជាមួយអ្នកទិញ និងអ្នកលក់នៅលើ Bosdom សូមអានហើយយល់ព្រមតាមលក្ខខណ្ឌខាងក្រោម។';

  @override
  String get chatPolicySecurePayBody =>
      'ការទូទាត់ប្រាក់ដែលធ្វើឡើងក្រៅកម្មវិធី មិនស្ថិតក្រោមការការពារអ្នកទិញ ឬដំណោះស្រាយវិវាទរបស់ Bosdom ទេ។';

  @override
  String get chatPolicyFlaggedTitle =>
      'កិច្ចព្រមព្រៀងក្រៅវេទិកាត្រូវបានដាក់ទង់';

  @override
  String get chatPolicyFlaggedBody =>
      'សារដែលចែករំលែកលេខទូរស័ព្ទ ឬកម្មវិធីទំនាក់ទំនងភាគីទីបី នឹងត្រូវបានដាក់ទង់ដោយស្វ័យប្រវត្តិសម្រាប់ការត្រួតពិនិត្យ។';

  @override
  String get chatPolicyLiableTitle => 'អ្នកទទួលខុសត្រូវចំពោះអ្វីដែលអ្នកផ្ញើ';

  @override
  String get chatPolicyLiableBody =>
      'Bosdom មិនទទួលខុសត្រូវចំពោះការខាតបង់ណាមួយ ដែលកើតចេញពីកិច្ចព្រមព្រៀងដែលរៀបចំក្រៅវេទិកា ឬផ្ទុយពីលក្ខខណ្ឌទាំងនេះទេ។';

  @override
  String get chatPolicyHeaderTitle => 'គោលការណ៍ជជែក និងជួញដូរ';

  @override
  String get chatPolicyAgreementText =>
      'ខ្ញុំបានអានហើយយល់ព្រមតាមគោលការណ៍ជជែក និងលក្ខខណ្ឌប្រើប្រាស់របស់ Bosdom។';

  @override
  String get chatPolicyContinueButton => 'បន្តទៅកាន់ការជជែក';

  @override
  String get notificationsMarkAllRead => 'សម្គាល់ថាបានអានទាំងអស់';

  @override
  String get notificationsScreenTitle => 'ការជូនដំណឹង';

  @override
  String get notificationsEmptyTitle => 'អ្នកបានអានការជូនដំណឹងទាំងអស់ហើយ';

  @override
  String get notificationsLoadError => 'មិនអាចផ្ទុកការជូនដំណឹងបានទេ';

  @override
  String get notificationsPushTitle => 'ការជូនដំណឹងផុស';

  @override
  String get notificationsPushBody =>
      'ក្លាយជាអ្នកដំបូងដែលបានដឹងអំពី៖ ការលក់ប្រចាំសប្តាហ៍ ការផ្តល់ជូនផ្តាច់មុខ ការផ្សព្វផ្សាយពិសេស និងច្រើនទៀត';

  @override
  String get dataPrivacyContactBanner =>
      'ទាក់ទងដើម្បីគ្រប់គ្រងទិន្នន័យរបស់អ្នក';

  @override
  String get dataPrivacyBody =>
      'ស្នើសុំការចូលប្រើ ការកែតម្រូវ ឬការលុបទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នក។ ទាក់ទងក្រុមឯកជនភាពរបស់យើងសម្រាប់ការសាកសួរទាក់ទងនឹងទិន្នន័យ។';

  @override
  String get dataPrivacyContactButton => 'ទាក់ទងក្រុមឯកជនភាព';

  @override
  String dataPrivacyLaunchError(String email) {
    return 'មិនអាចបើកកម្មវិធីអ៊ីមែលបានទេ៖ បានចម្លង $email ទៅក្តារតម្បៀតខ្ទាស់ជំនួសវិញ';
  }

  @override
  String get marketingEmailsToggleTitle => 'ទទួលអ៊ីមែលទីផ្សារ';

  @override
  String get marketingEmailsBody =>
      'ខ្ញុំផ្តល់ការយល់ព្រមឱ្យ Bosdom ផ្ញើអ៊ីមែលទីផ្សារ រួមទាំងការផ្តល់ជូន សេចក្តីប្រកាសអ្នកផ្គត់ផ្គង់ថ្មី ការផ្តល់ជូនទិញរួម និងអនុសាសន៍ផលិតផលដែលសមស្របនឹងតម្រូវការអាជីវកម្មរបស់ខ្ញុំ។';

  @override
  String get marketingEmailsFinePrint =>
      'អ្នកអាចដកការយល់ព្រមរបស់អ្នកបានគ្រប់ពេល។ ប្រសិនបើអ្នកដកការយល់ព្រម វានឹងមិនប៉ះពាល់ដល់ភាពស្របច្បាប់នៃទិន្នន័យដែលបានដំណើរការពីមុនទេ។ យើងដំណើរការទិន្នន័យរបស់អ្នកស្របតាមគោលការណ៍ភាពឯកជនរបស់យើង។';

  @override
  String get marketingEmailsSaveError =>
      'មិនអាចរក្សាទុកចំណូលចិត្តអ៊ីមែលទីផ្សាររបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get personalizedAdsAllowTitle =>
      'អនុញ្ញាតការផ្សាយពាណិជ្ជកម្មផ្ទាល់ខ្លួន';

  @override
  String get personalizedAdsBody =>
      'យើងប្រើប្រាស់ទិន្នន័យរុករក និងប្រវត្តិការទិញរបស់អ្នក ដើម្បីបង្ហាញការណែនាំផលិតផល និងការផ្សាយពាណិជ្ជកម្មដែលពាក់ព័ន្ធ។ អ្នកអាចដកខ្លួនបានគ្រប់ពេល៖ អ្នកនៅតែឃើញការផ្សាយពាណិជ្ជកម្ម ប៉ុន្តែវានឹងមិនត្រូវបានកែសម្រួលតាមចំណាប់អារម្មណ៍របស់អ្នកទេ។';

  @override
  String get personalizedAdsBrowsingTitle => 'ទិន្នន័យរុករក';

  @override
  String get personalizedAdsBrowsingBody =>
      'ទំព័រ និងផលិតផលដែលអ្នកមើលក្នុងកម្មវិធី';

  @override
  String get personalizedAdsPurchaseTitle => 'ប្រវត្តិការទិញ';

  @override
  String get personalizedAdsPurchaseBody =>
      'ទំនិញដែលអ្នកបានទិញ ឬបានដាក់ក្នុងកន្ត្រក';

  @override
  String get personalizedAdsAcceptAll => 'ព្រមទទួលទាំងអស់';

  @override
  String get personalizedAdsAdjustPreferences => 'កែសម្រួលចំណូលចិត្ត';

  @override
  String get personalizedAdsHidePreferences => 'លាក់ចំណូលចិត្ត';

  @override
  String get personalizedAdsSavePreferences => 'រក្សាទុកចំណូលចិត្ត';

  @override
  String get personalizedAdsSaveError =>
      'មិនអាចរក្សាទុកចំណូលចិត្តរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get coBuyingScreenTitle => 'ទិញរួម';

  @override
  String get coBuyingInfoBanner =>
      'រួមបញ្ចូលការបញ្ជាទិញជាមួយអ្នកលក់រាយនៅជិតៗ ដើម្បីទទួលបានការបញ្ចុះតម្លៃលក់ដុំចំនួនច្រើន។ ចែករំលែកតំណអញ្ជើញដើម្បីពង្រីកក្រុមរបស់អ្នក!';

  @override
  String get coBuyingSectionTitle => 'សម័យទិញរួមកំពុងដំណើរការ';

  @override
  String get coBuyingMomentumReady =>
      'សម្រេចគោលដៅហើយ ត្រៀមរួចរាល់សម្រាប់ការទូទាត់';

  @override
  String get coBuyingMomentumAlmost => 'ជិតដោះសោហើយ សូមប្រញាប់ទិញ';

  @override
  String get coBuyingMomentumFilling => 'កំពុងពេញយ៉ាងឆាប់រហ័ស';

  @override
  String get coBuyingMomentumNew => 'ទើបបើកថ្មី សូមធ្វើជាអ្នកទិញមុនគេ';

  @override
  String coBuyingPooledProgress(
    int currentQty,
    int targetQty,
    String unitLabel,
  ) {
    return '$currentQty/$targetQty $unitLabel បានប្រមូលផ្តុំ';
  }

  @override
  String coBuyingRemainingToUnlock(int remainingQty, String unitLabel) {
    return 'នៅសល់តែ $remainingQty $unitLabel ទៀតដើម្បីដោះសោតម្លៃជាក្រុម';
  }

  @override
  String get coBuyingGroupPriceLabel => 'តម្លៃជាក្រុម';

  @override
  String coBuyingYouSave(String amount) {
    return 'អ្នកសន្សំបាន $amount';
  }

  @override
  String get coBuyingJoinedPillLabel =>
      'អ្នកបានចូលរួមក្នុងការទិញជាក្រុមនេះ · ចុចដើម្បីចាកចេញ';

  @override
  String get coBuyingCheckoutReadyLabel => 'ត្រៀមរួចរាល់សម្រាប់ការទូទាត់';

  @override
  String get coBuyingFullLabel => 'ការទិញរួមពេញ';

  @override
  String get coBuyingJoinButtonLabel => 'ចូលរួមការទិញរួមនេះ';

  @override
  String coBuyingShareText(
    String productName,
    String price,
    String savingsPct,
    String url,
  ) {
    return 'ចូលរួមជាមួយខ្ញុំក្នុងការទិញរួមសម្រាប់ $productName នៅលើ BosDom! ទទួលបានក្នុងតម្លៃ $price (បញ្ចុះតម្លៃ $savingsPct%)។\n\n$url';
  }

  @override
  String coBuyingShareSubject(String productName) {
    return 'ការទិញរួម៖ $productName';
  }

  @override
  String get coBuyCreateScreenTitle => 'បង្កើតការទិញរួម';

  @override
  String get coBuyCreateEditScreenTitle => 'កែសម្រួលកិច្ចព្រមព្រៀងទិញរួម';

  @override
  String get coBuyCreateProductNameLabel => 'ឈ្មោះទំនិញ';

  @override
  String get coBuyCreateProductNameHint => 'ឧ. អង្ករសែនក្រអូបលក់ដុំ 50kg';

  @override
  String get coBuyCreateProductNameRequired => 'ត្រូវការឈ្មោះទំនិញ';

  @override
  String get coBuyCreatePriceLabel => 'តម្លៃក្រុម (ក្នុងមួយឯកតា)';

  @override
  String get coBuyCreatePriceRequired => 'ត្រូវការតម្លៃក្រុម';

  @override
  String get coBuyCreatePriceInvalid => 'សូមបញ្ចូលតម្លៃត្រឹមត្រូវ';

  @override
  String get coBuyCreateOriginalPriceLabel => 'តម្លៃដើម';

  @override
  String get coBuyCreateOriginalPriceRequired => 'ត្រូវការតម្លៃដើម';

  @override
  String get coBuyCreateOriginalPriceInvalid =>
      'តម្លៃដើមត្រូវតែខ្ពស់ជាងតម្លៃក្រុម';

  @override
  String get coBuyCreateTargetQtyLabel => 'បរិមាណគោលដៅ';

  @override
  String get coBuyCreateTargetQtyHint => 'ឧ. 50';

  @override
  String get coBuyCreateTargetQtyRequired => 'ត្រូវការបរិមាណគោលដៅ';

  @override
  String get coBuyCreateTargetQtyInvalid => 'សូមបញ្ចូលបរិមាណត្រឹមត្រូវ';

  @override
  String get coBuyCreateUnitLabelLabel => 'ឯកតា';

  @override
  String get coBuyCreateUnitLabelHint => 'ឧ. kg, packs, units';

  @override
  String get coBuyCreateUnitLabelRequired => 'ត្រូវការឯកតា';

  @override
  String get coBuyCreateMinOrderQtyLabel => 'បរិមាណបញ្ជាទិញអប្បបរមា';

  @override
  String get coBuyCreateMinOrderQtyHint => 'ឧ. 2';

  @override
  String get coBuyCreateMinOrderQtyRequired => 'ត្រូវការបរិមាណបញ្ជាទិញអប្បបរមា';

  @override
  String get coBuyCreateMinOrderQtyInvalid => 'សូមបញ្ចូលបរិមាណត្រឹមត្រូវ';

  @override
  String get coBuyCreateDurationLabel => 'រយៈពេលកំណត់';

  @override
  String get coBuyCreateDuration1Day => '1 ថ្ងៃ';

  @override
  String get coBuyCreateDuration2Days => '2 ថ្ងៃ';

  @override
  String get coBuyCreateDuration3Days => '3 ថ្ងៃ';

  @override
  String get coBuyCreateDuration5Days => '5 ថ្ងៃ';

  @override
  String get coBuyCreateDuration1Week => '1 សប្តាហ៍';

  @override
  String get coBuyCreateButton => 'ចាប់ផ្តើមការទិញរួម';

  @override
  String get coBuyCreateCreatedSnackbar =>
      'បានបង្កើតការទិញរួម! អញ្ជើញអ្នកដទៃឱ្យចូលរួម។';

  @override
  String get coBuyCreateUpdatedSnackbar =>
      'បានធ្វើបច្ចុប្បន្នភាពកិច្ចព្រមព្រៀងទិញរួម';

  @override
  String get coBuyCreateProductInfoSectionTitle => 'ព័ត៌មានផលិតផល';

  @override
  String get coBuyCreatePricingSectionTitle => 'តម្លៃ និងបរិមាណ';

  @override
  String get coBuyCreateDealSettingsSectionTitle => 'ការកំណត់កិច្ចព្រមព្រៀង';

  @override
  String get coBuyCreatePhotosLabel => 'រូបភាពផលិតផល';

  @override
  String get coBuyCreatePhotoLabel => 'ចុចដើម្បីបន្ថែមរូបភាពគម្រប';

  @override
  String get coBuyCreatePhotoHint => 'ណែនាំទំហំ 512×512px JPG ឬ PNG';

  @override
  String get coBuyCreatePhotosHelper =>
      'បន្ថែមរូបភាពរហូតដល់ ៤ សន្លឹក។ រូបភាពទីមួយគឺជារូបគម្រប។';

  @override
  String get coBuyCreateDescriptionLabel => 'ការពិពណ៌នាផលិតផល';

  @override
  String get coBuyCreateDescriptionHint => 'ពិពណ៌នាផលិតផលនេះសម្រាប់អ្នកលក់រាយ';

  @override
  String get coBuyCreateAutoRenewLabel => 'បន្តដោយស្វ័យប្រវត្តិពេលផុតកំណត់';

  @override
  String get coBuyDealsWelcomeMessage =>
      'សូមស្វាគមន៍! នេះជាសង្ខេបលទ្ធផលទិញរួមរបស់អ្នកថ្ងៃនេះ។';

  @override
  String get coBuyDealsShopNamePlaceholder => 'ហាងរបស់ខ្ញុំ';

  @override
  String get coBuyDealsAutoRenewBadge => 'បន្តដោយស្វ័យប្រវត្តិ';

  @override
  String get coBuyDealsActiveDealsLabel => 'កិច្ចព្រមព្រៀងកំពុងដំណើរការ';

  @override
  String get coBuyDealsJoinedLabel => 'បានចូលរួម';

  @override
  String get coBuyDealsRevenueLabel => 'ចំណូល';

  @override
  String get coBuyDealsCreateButtonLabel => 'បង្កើតកិច្ចព្រមព្រៀងទិញរួមថ្មី';

  @override
  String get coBuyDealsListingsSectionTitle => 'បញ្ជីទិញរួមរបស់អ្នក';

  @override
  String coBuyDealsMinTargetLabel(int targetQty, String unitLabel) {
    return 'គោលដៅលក់ដុំអប្បបរមា៖ $targetQty $unitLabel';
  }

  @override
  String get coBuyDealsStatusActive => 'កំពុងដំណើរការ';

  @override
  String get coBuyDealsStatusCompleted => 'បានបញ្ចប់';

  @override
  String get coBuyDealsStatusExpired => 'ផុតកំណត់';

  @override
  String get coBuyDealsProgressLabel => 'វឌ្ឍនភាព';

  @override
  String coBuyDealsRetailersLabel(int count) {
    return 'អ្នកលក់រាយ $count នាក់';
  }

  @override
  String get coBuyDealsStatusEndedLabel => 'បានបញ្ចប់';

  @override
  String get coBuyDealsEndsSoonLabel => 'ជិតផុតកំណត់';

  @override
  String get coBuyDealsOriginalLabel => 'តម្លៃដើម';

  @override
  String get coBuyDealsCoBuyPriceLabel => 'តម្លៃទិញរួម';

  @override
  String get coBuyDealsDeleteConfirmTitle => 'លុបកិច្ចព្រមព្រៀងទិញរួម?';

  @override
  String coBuyDealsDeleteConfirmBody(String productName) {
    return '$productName និងវឌ្ឍនភាពអ្នកលក់រាយនឹងត្រូវលុបជាអចិន្ត្រៃយ៍។';
  }

  @override
  String get coBuyDealsDeletedSnackbar => 'បានលុបកិច្ចព្រមព្រៀងទិញរួម';

  @override
  String get coBuyDealsEmptyMessage =>
      'មិនទាន់មានកិច្ចព្រមព្រៀងទិញរួមទេ។ បង្កើតមួយ ដើម្បីឱ្យអ្នកលក់រាយអាចរួមបញ្ជាទិញជាមួយអ្នក។';

  @override
  String get coBuyDetailActiveDealLabel => 'ការផ្តល់ជូនកំពុងដំណើរការ';

  @override
  String get coBuyDetailVisitShopLabel => 'មើលហាង';

  @override
  String coBuyDetailJoinedSnackbar(String productName, String amount) {
    return 'បានចូលរួមទិញរួម $productName · $amount';
  }

  @override
  String coBuyDetailLeftSnackbar(String productName) {
    return 'បានចាកចេញពីការទិញរួម $productName';
  }

  @override
  String coBuyDetailQtyLabel(int quantity, String unitLabel) {
    return 'ចំនួន៖ $quantity $unitLabel';
  }

  @override
  String get coBuyDetailProgressTitle => 'វឌ្ឍនភាពការទិញរួម';

  @override
  String coBuyDetailProgressLine(
    int currentQty,
    int targetQty,
    String unitLabel,
  ) {
    return 'វឌ្ឍនភាព៖ $currentQty/$targetQty $unitLabel';
  }

  @override
  String coBuyDetailRetailersJoined(int count) {
    return '$count អ្នកលក់រាយបានចូលរួម';
  }

  @override
  String coBuyDetailYouSaveLine(int savingsPct, String perUnitLabel) {
    return 'អ្នកសន្សំបាន $savingsPct% $perUnitLabel ក្នុងកិច្ចព្រមព្រៀងនេះ';
  }

  @override
  String get coBuyDetailYourOrderTitle => 'ការបញ្ជាទិញរបស់អ្នក';

  @override
  String get coBuyDetailQuantityLabel => 'បរិមាណ';

  @override
  String coBuyDetailMinOrderLabel(int minOrderQty, String unitLabel) {
    return 'បញ្ជាទិញអប្បបរមា៖ $minOrderQty $unitLabel';
  }

  @override
  String get coBuyDetailSubtotalLabel => 'សរុបរង';

  @override
  String coBuyDetailCheckoutLabel(String amount) {
    return 'ការទូទាត់ · $amount';
  }

  @override
  String get coBuyDetailFullLabel => 'ការទិញរួមពេញ';

  @override
  String get coBuyDetailJoinedLabel => 'អ្នកបានចូលរួម · ចុចដើម្បីចាកចេញ';

  @override
  String coBuyDetailJoinLabel(String amount) {
    return 'ចូលរួមទិញរួម · $amount';
  }

  @override
  String get wishlistScreenTitle => 'បញ្ជីចង់បាន';

  @override
  String get wishlistEmptyStateMessage =>
      'មិនទាន់មានទំនិញនៅក្នុងបញ្ជីចង់បានរបស់អ្នកទេ';

  @override
  String wishlistAddedToCartSnackbar(String productName) {
    return '$productName ត្រូវបានបញ្ចូលទៅកន្ត្រក';
  }

  @override
  String get wishlistAddToCartButton => 'បញ្ចូលទៅកន្ត្រក';

  @override
  String get marketplaceCategoriesTitle => 'ប្រភេទផលិតផល';

  @override
  String get marketplaceCoBuyDealsTitle => 'ការទិញរួមគ្នា';

  @override
  String get marketplacePopularProductsTitle => 'ផលិតផលលក់ដុំពេញនិយម';

  @override
  String get marketplaceSearchHint => 'ស្វែងរកផលិតផល...';

  @override
  String get marketplaceCoBuyJoinButton => 'ចូលរួមទិញរួមគ្នា';

  @override
  String marketplaceCoBuyProgressToTarget(String percent) {
    return '$percent% ទៅគោលដៅ';
  }

  @override
  String marketplaceCoBuyRetailersJoined(String count) {
    return 'អ្នកលក់រាយចូលរួម $count នាក់';
  }

  @override
  String get productDetailPerUnit => 'ក្នុងមួយឯកតា';

  @override
  String productDetailMoqLabel(String moq) {
    return 'បរិមាណបញ្ជាទិញអប្បបរមា៖ $moq បាវ';
  }

  @override
  String get productDetailSpecsTitle => 'លក្ខណៈបច្ចេកទេសលក់ដុំ';

  @override
  String get productDetailSpecWeight => 'ទម្ងន់';

  @override
  String get productDetailSpecOrigin => 'ប្រភពដើម';

  @override
  String get productDetailSpecGrade => 'កម្រិតគុណភាព';

  @override
  String get productDetailSpecPackaging => 'កញ្ចប់ខ្ចប់';

  @override
  String get productDetailModeWholesale => 'លក់ដុំ';

  @override
  String get productDetailModeSample => 'គំរូ';

  @override
  String get productDetailVisitShop => 'ចូលមើលហាង';

  @override
  String get productDetailInStock => 'នៅមានស្តុក';

  @override
  String get productDetailOutOfStock => 'អស់ស្តុក';

  @override
  String get productDetailWholesaleBuyTitle => 'ទិញលក់ដុំ';

  @override
  String get productDetailSampleBuyTitle => 'ទិញគំរូ';

  @override
  String get productDetailUnitBag => '/ បាវ';

  @override
  String get productDetailUnitPiece => '/ ឯកតា';

  @override
  String get productDetailQuantityLabel => 'បរិមាណ';

  @override
  String productDetailAddedToCartSnackbar(String price) {
    return 'បានដាក់ចូលរទេះ · $price';
  }

  @override
  String get productDetailSampleRequestedSnackbar => 'បានស្នើសុំគំរូ';

  @override
  String productDetailAddToCartButton(String price) {
    return 'ដាក់ចូលរទេះ · $price';
  }

  @override
  String get productDetailSampleAlreadyRequested => 'បានស្នើសុំគំរូរួចហើយ';

  @override
  String get productDetailSampleLimitReached => 'បានដល់កំណត់គំរូ';

  @override
  String get productDetailRequestSample => 'សុំគំរូ';

  @override
  String productDetailSampleUsedNote(String productName) {
    return 'អ្នកបានប្រើប្រាស់គំរូឥតគិតថ្លៃចំនួន ១ របស់អ្នករួចហើយលើ $productName។';
  }

  @override
  String get productDetailSampleLimitNote => 'កំណត់ត្រឹមគំរូ ១ ក្នុងមួយគណនី';

  @override
  String get storeProfileStatProducts => 'ផលិតផល';

  @override
  String get storeProfileStatOrders => 'ការបញ្ជាទិញ';

  @override
  String get storeProfileStatRating => 'ការវាយតម្លៃ';

  @override
  String get storeProfileTabProducts => 'ផលិតផល';

  @override
  String get storeProfileTabAbout => 'អំពី';

  @override
  String get storeProfileTabReviews => 'ការវាយតម្លៃ';

  @override
  String get storeProfileNoProducts => 'មិនទាន់មានផលិតផលនៅឡើយទេ';

  @override
  String get storeProfileAboutSectionTitle => 'អំពី';

  @override
  String get storeProfileBusinessDetailsTitle => 'ព័ត៌មានលម្អិតអាជីវកម្ម';

  @override
  String get storeProfileLabelBusinessType => 'ប្រភេទអាជីវកម្ម';

  @override
  String get storeProfileLabelYearEstablished => 'ឆ្នាំបង្កើត';

  @override
  String get storeProfileLabelLocation => 'ទីតាំង';

  @override
  String get storeProfileLabelMinimumOrder => 'ការបញ្ជាទិញអប្បបរមា';

  @override
  String get storeProfileLabelResponseTime => 'រយៈពេលឆ្លើយតប';

  @override
  String get storeProfileLabelShipping => 'ការដឹកជញ្ជូន';

  @override
  String get storeProfileCertificationsTitle => 'វិញ្ញាបនបត្រ និងស្តង់ដារ';

  @override
  String get storeProfileWhyChooseUsTitle => 'ហេតុអ្វីជ្រើសរើសយើង';

  @override
  String get storeProfileContactSupplierButton => 'ទាក់ទងអ្នកផ្គត់ផ្គង់';

  @override
  String get storeProfileNoReviewsTitle => 'មិនទាន់មានការវាយតម្លៃនៅឡើយទេ';

  @override
  String storeProfileNoReviewsBody(String sellerName) {
    return 'សូមក្លាយជាអ្នកដំបូងដែលវាយតម្លៃ $sellerName បន្ទាប់ពីការបញ្ជាទិញរបស់អ្នក។';
  }

  @override
  String storeProfileReviewsCount(String count) {
    return 'ការវាយតម្លៃ $count';
  }

  @override
  String storeProfileRecommendPercent(String percent) {
    return '$percent% ណែនាំ';
  }

  @override
  String storeProfileResponseTimeChip(String time) {
    return 'ឆ្លើយតបក្នុងរយៈពេល $time';
  }

  @override
  String get storeProfileTopSellerChip => 'អ្នកលក់កំពូល';

  @override
  String get storeProfileRatingBreakdownTitle => 'ការបំបែកការវាយតម្លៃ';

  @override
  String get storeProfileRecentReviewsTitle => 'ការវាយតម្លៃថ្មីៗ';

  @override
  String get categoryResultsSearchHint => 'ស្វែងរកផលិតផល...';

  @override
  String get categoryResultsFiltersButton => 'តម្រង';

  @override
  String categoryResultsItemsCount(String count) {
    return '$count ធាតុ';
  }

  @override
  String get categoryResultsNoProducts => 'រកមិនឃើញផលិតផលទេ';

  @override
  String get categoryResultsFilterSheetTitle => 'ត្រងតាមប្រភេទ';

  @override
  String get categoryResultsClearAll => 'សម្អាតទាំងអស់';

  @override
  String get categoryResultsApplyFilters => 'អនុវត្តតម្រង';

  @override
  String get searchScreenTitle => 'ស្វែងរក';

  @override
  String get searchHint => 'ស្វែងរកផលិតផល ឬអ្នកលក់...';

  @override
  String get searchRecentSearchesTitle => 'ការស្វែងរកថ្មីៗ';

  @override
  String get searchClearAll => 'សម្អាតទាំងអស់';

  @override
  String get searchTrendingSearchesTitle => 'ការស្វែងរកពេញនិយម';

  @override
  String get searchSuggestedCategoriesTitle => 'ប្រភេទដែលបានស្នើ';

  @override
  String get searchRecommendedForYouTitle => 'ណែនាំសម្រាប់អ្នក';

  @override
  String searchNoResults(String query) {
    return 'រកមិនឃើញផលិតផលសម្រាប់ \"$query\" ទេ';
  }

  @override
  String get ordersScreenTitle => 'មើលការបញ្ជាទិញ';

  @override
  String get ordersEmptyStateMessage => 'មិនមានការបញ្ជាទិញនៅក្នុងប្រភេទនេះទេ';

  @override
  String ordersFilterAllLabel(int count) {
    return 'ទាំងអស់ ($count)';
  }

  @override
  String ordersItemCountLabel(int count) {
    return '$count ធាតុ';
  }

  @override
  String ordersOrderNumberLabel(String orderId) {
    return 'លេខបញ្ជាទិញ #$orderId';
  }

  @override
  String get ordersRateReviewButton => 'វាយតម្លៃ និងផ្តល់មតិ';

  @override
  String get ordersReportButton => 'រាយការណ៍';

  @override
  String get ordersReportLabel => 'រាយការណ៍បញ្ជាទិញ';

  @override
  String get ordersReportSheetTitle => 'រាយការណ៍បញ្ជាទិញ';

  @override
  String get ordersReportReasonLabel => 'តើមានបញ្ហាអ្វី?';

  @override
  String get ordersReportReasonWrongItem => 'ទទួលបានទំនិញខុស';

  @override
  String get ordersReportReasonDamaged => 'ទំនិញខូច';

  @override
  String get ordersReportReasonMissing => 'ទំនិញបាត់';

  @override
  String get ordersReportReasonLateDelivery => 'ដឹកជញ្ជូនយឺត';

  @override
  String get ordersReportReasonOther => 'ផ្សេងទៀត';

  @override
  String get ordersReportNoteLabel => 'ព័ត៌មានលម្អិតបន្ថែម (មិនចាំបាច់)';

  @override
  String get ordersReportNoteHint => 'ប្រាប់យើងបន្ថែមអំពីបញ្ហានេះ...';

  @override
  String get ordersReportSubmitButton => 'ដាក់ស្នើរបាយការណ៍';

  @override
  String get ordersReportSubmittedSnackbar =>
      'របាយការណ៍របស់អ្នកត្រូវបានដាក់ស្នើ';

  @override
  String ordersReportFailedSnackbar(String error) {
    return 'មិនអាចដាក់ស្នើរបាយការណ៍បានទេ: $error';
  }

  @override
  String get ordersViewDetailsButton => 'មើលព័ត៌មានលម្អិត';

  @override
  String get ordersTrackOrderButton => 'តាមដានការបញ្ជាទិញ';

  @override
  String get orderDetailScreenTitle => 'ព័ត៌មានលម្អិតបញ្ជាទិញ';

  @override
  String get orderDetailItemsAddedSnackbar => 'បានបន្ថែមទំនិញទៅកន្ត្រករបស់អ្នក';

  @override
  String get orderDetailItemsOrderedSection => 'ទំនិញដែលបានបញ្ជាទិញ';

  @override
  String orderDetailOrderNumberLabel(String orderId) {
    return 'លេខបញ្ជាទិញ #$orderId';
  }

  @override
  String get orderDetailDeliveryMethodSection => 'វិធីសាស្ត្រដឹកជញ្ជូន';

  @override
  String get orderDetailCarrierLabel => 'ក្រុមហ៊ុនដឹកជញ្ជូន';

  @override
  String get orderDetailPaymentSummarySection => 'សេចក្តីសង្ខេបការទូទាត់';

  @override
  String orderDetailPhoneLabel(String phone) {
    return 'ទូរស័ព្ទ៖ $phone';
  }

  @override
  String orderDetailPlacedOnLabel(String date) {
    return 'បានបញ្ជាទិញនៅថ្ងៃទី $date';
  }

  @override
  String orderDetailReceiptSaveFailedSnackbar(String error) {
    return 'រក្សាទុកបង្កាន់ដៃមិនបានសម្រេច៖ $error';
  }

  @override
  String get orderDetailReceiptSavedSnackbar =>
      'បានរក្សាទុកបង្កាន់ដៃទៅឧបករណ៍របស់អ្នក';

  @override
  String get orderDetailReorderButton => 'បញ្ជាទិញឡើងវិញនូវទំនិញលក់ដុំ';

  @override
  String get orderDetailSaveReceiptButton => 'រក្សាទុកបង្កាន់ដៃជា PDF';

  @override
  String get orderDetailSavingLabel => 'កំពុងរក្សាទុក...';

  @override
  String get orderDetailShippingFeeLabel => 'ថ្លៃដឹកជញ្ជូន';

  @override
  String get orderDetailShippingSection => 'ការដឹកជញ្ជូន និងការចែកចាយ';

  @override
  String get orderDetailSubtotalLabel => 'សរុបរង';

  @override
  String get orderDetailTotalAmountLabel => 'ចំនួនទឹកប្រាក់សរុប';

  @override
  String get orderDetailTrackDeliveryButton => 'តាមដានការដឹកជញ្ជូន';

  @override
  String get orderDetailWholesaleDiscountLabel => 'បញ្ចុះតម្លៃលក់ដុំ';

  @override
  String get deliveryScreenTitle => 'តាមដានការដឹកជញ្ជូន';

  @override
  String get deliveryCurrentStatusLabel => 'ស្ថានភាពបច្ចុប្បន្ន';

  @override
  String get deliveryEscrowNoteText =>
      'ថវិកាត្រូវបានរក្សាទុកយ៉ាងសុវត្ថិភាពក្នុងគណនីអេស្គ្រូ រហូតដល់អ្នកបញ្ជាក់ការទទួល។';

  @override
  String get deliveryInProgressLabel => 'កំពុងដំណើរការ';

  @override
  String get deliveryPendingLabel => 'កំពុងរង់ចាំ';

  @override
  String deliveryPlacedOnLabel(String date) {
    return 'បានបញ្ជាទិញនៅថ្ងៃទី $date';
  }

  @override
  String get deliveryStatusSectionTitle => 'ស្ថានភាពការដឹកជញ្ជូន';

  @override
  String get deliveryStepDelivered => 'បានដឹកជញ្ជូនរួច';

  @override
  String get deliveryStepOrderCancelled => 'បញ្ជាទិញត្រូវបានលុបចោល';

  @override
  String get deliveryStepOrderPlaced => 'បានធ្វើការបញ្ជាទិញ';

  @override
  String get deliveryStepOutForDelivery => 'កំពុងដឹកជញ្ជូន';

  @override
  String get deliveryStepPackedAtWarehouse => 'បានវេចខ្ចប់នៅឃ្លាំង';

  @override
  String get reviewSheetTitle => 'វាយតម្លៃ និងផ្តល់មតិ';

  @override
  String get reviewAddPhotosButton => 'បន្ថែមរូបភាព';

  @override
  String get reviewAddPhotosLabel => 'បន្ថែមរូបភាពទំនិញដែលបានទទួល';

  @override
  String get reviewHintText => 'ចែករំលែកបទពិសោធន៍របស់អ្នកអំពីការបញ្ជាទិញនេះ...';

  @override
  String reviewMaxPhotosSnackbar(int count) {
    return 'អ្នកអាចបន្ថែមរូបភាពបានច្រើនបំផុត $count សន្លឹក';
  }

  @override
  String get reviewOfficialBadge => 'ផ្លូវការ';

  @override
  String reviewPhotoLibraryErrorSnackbar(String error) {
    return 'មិនអាចបើកបណ្ណាល័យរូបភាពបានទេ៖ $error';
  }

  @override
  String get reviewRateProductLabel => 'វាយតម្លៃផលិតផល';

  @override
  String get reviewRateStoreLabel => 'វាយតម្លៃហាង';

  @override
  String get reviewSubmitButton => 'ដាក់ស្នើមតិវាយតម្លៃ';

  @override
  String get reviewSubmittedSnackbar =>
      'សូមអរគុណ! មតិវាយតម្លៃរបស់អ្នកត្រូវបានដាក់ស្នើ។';

  @override
  String get reviewWriteReviewLabel => 'សរសេរមតិវាយតម្លៃ';

  @override
  String get paymentScreenTitle => 'វិធីទូទាត់ប្រាក់';

  @override
  String get paymentAbaMethodTitle => 'ABA Pay';

  @override
  String get paymentAbaNotAvailableSnackbar =>
      'ABA Pay មិនទាន់អាចប្រើប្រាស់បានទេ';

  @override
  String get paymentAmountToPayLabel => 'ចំនួនទឹកប្រាក់ត្រូវទូទាត់';

  @override
  String get paymentCardDetailsSubtitle =>
      'បញ្ចូលព័ត៌មានប័ណ្ណរបស់អ្នកយ៉ាងសុវត្ថិភាព';

  @override
  String get paymentCardMethodTitle => 'កាតឥណទាន/កាតឥណពន្ធ';

  @override
  String get paymentCardNumberLabel => 'លេខកាត';

  @override
  String get paymentConfirmedSubtitle =>
      'ការបញ្ជាទិញរបស់អ្នកត្រូវបានធ្វើ និងបានទូទាត់ប្រាក់រួចរាល់។';

  @override
  String get paymentConfirmedTitle => 'អ្នកត្រូវបានបញ្ជាក់ហើយ!';

  @override
  String get paymentConfirmingSubtitle => 'កំពុងបញ្ជាក់ការបញ្ជាទិញរបស់អ្នក...';

  @override
  String get paymentConfirmingTitle => 'សូមរង់ចាំមួយភ្លែត';

  @override
  String get paymentContinueShoppingButton => 'បន្តទិញឥវ៉ាន់';

  @override
  String get paymentCvvLabel => 'CVV';

  @override
  String get paymentExpiryDateLabel => 'កាលបរិច្ឆេទផុតកំណត់';

  @override
  String paymentFailedSnackbar(String error) {
    return 'ការទូទាត់មិនបានសម្រេច៖ $error';
  }

  @override
  String paymentItemsPurchasedLabel(int count) {
    return 'បានទិញ $count ធាតុ';
  }

  @override
  String get paymentMethodSubtitleVisaMastercard => 'Visa, Mastercard ជាដើម';

  @override
  String paymentPayAmountLabel(String amount) {
    return 'ទូទាត់ $amount';
  }

  @override
  String get paymentPayNowButton => 'ទូទាត់ឥឡូវនេះ';

  @override
  String get paymentSecureEncryptionNote =>
      'ព័ត៌មានទូទាត់របស់អ្នកត្រូវបានអ៊ិនគ្រីបយ៉ាងសុវត្ថិភាព';

  @override
  String get paymentSelectMethodLabel => 'ជ្រើសរើសវិធីទូទាត់ប្រាក់';

  @override
  String get paymentTotalPaidLabel => 'ចំនួនទឹកប្រាក់ដែលបានទូទាត់សរុប';

  @override
  String get paymentViewOrdersButton => 'មើលការបញ្ជាទិញ';

  @override
  String get paymentWholesaleItemsFallbackLabel => 'ទំនិញលក់ដុំ';

  @override
  String get escrowScreenTitle => 'អេស្គ្រូ និងការទូទាត់';

  @override
  String get escrowPlaceholderText =>
      'ការទូទាត់ប្រាក់ ការបញ្ជាក់ QR ភស្តុតាងវិវាទ. UI នឹងមកដល់នៅដំណាក់កាលទី ៨';

  @override
  String get profileMenuMyOrders => 'ការបញ្ជាទិញរបស់ខ្ញុំ';

  @override
  String get profileMenuCoBuyInvites => 'ការអញ្ជើញទិញរួម';

  @override
  String get profileMenuAddressBook => 'សៀវភៅអាសយដ្ឋាន';

  @override
  String get profileMenuAddressStore => 'អាសយដ្ឋានហាង';

  @override
  String get profileMenuBuyerChat => 'ជជែកជាមួយអ្នកទិញ';

  @override
  String get profileMenuNotifications => 'ការជូនដំណឹង';

  @override
  String get profileMenuPaymentCurrency => 'រូបិយប័ណ្ណទូទាត់';

  @override
  String get profileMenuLanguage => 'ភាសា';

  @override
  String get profileMenuDataPrivacy => 'ភាពឯកជនទិន្នន័យ';

  @override
  String get profileMenuMarketingEmails => 'អ៊ីមែលទីផ្សារ';

  @override
  String get profileMenuPersonalizedAds => 'ការផ្សាយពាណិជ្ជកម្មផ្ទាល់ខ្លួន';

  @override
  String get profileMenuHelpSupport => 'ជំនួយ និងគាំទ្រ';

  @override
  String get profileMenuTermsConditions => 'លក្ខខណ្ឌប្រើប្រាស់';

  @override
  String get profileMenuPrivacyPolicy => 'គោលការណ៍ភាពឯកជន';

  @override
  String get profileMenuAbout => 'អំពី';

  @override
  String get profileMenuSellerDashboard => 'ផ្ទាំងគ្រប់គ្រងអ្នកលក់';

  @override
  String get profileMenuMyInventory => 'ស្តុកទំនិញរបស់ខ្ញុំ';

  @override
  String get profileMenuAddListing => 'បន្ថែមទំនិញ';

  @override
  String get profileMenuCoBuyDeals => 'កិច្ចព្រមព្រៀងទិញរួម';

  @override
  String get profileMenuShopProfile => 'ប្រវត្តិរូបហាង';

  @override
  String get profileSectionShopping => 'ការទិញទំនិញ';

  @override
  String get profileSectionSelling => 'ការលក់';

  @override
  String get profileSectionAccount => 'គណនី';

  @override
  String get profileSectionSettings => 'ការកំណត់';

  @override
  String get profileSectionSupport => 'ជំនួយ';

  @override
  String get profileSectionAbout => 'អំពី';

  @override
  String get profileStatTotalOrders => 'ការបញ្ជាទិញសរុប';

  @override
  String get profileStatActiveOrders => 'ការបញ្ជាទិញសកម្ម';

  @override
  String get profileStatSavedItems => 'ទំនិញដែលបានរក្សាទុក';

  @override
  String get profileStatTotalProducts => 'ទំនិញសរុប';

  @override
  String get profileStatRevenue => 'ចំណូល';

  @override
  String get profileSellerProgramBadge => 'កម្មវិធីអ្នកលក់';

  @override
  String get profileSellerTitle => 'ចាប់ផ្តើមលក់នៅលើ Bosdom';

  @override
  String get profileSellerSubtitle =>
      'ចូលរួមជាមួយអ្នកលក់ដុំរាប់ពាន់នាក់ និងទាក់ទងទៅអ្នកលក់រាយកាន់តែច្រើននៅទូទាំងកម្ពុជា';

  @override
  String get profileSellerCta => 'ក្លាយជាអ្នកលក់';

  @override
  String get profileSellerOnboardingLabel => 'ការចុះឈ្មោះជាអ្នកលក់';

  @override
  String get profileSellerActiveBadge => 'អ្នកលក់សកម្ម';

  @override
  String get profileSellerActiveTitle => 'អ្នកគឺជាអ្នកលក់ម្នាក់';

  @override
  String get profileSellerActiveSubtitle =>
      'គ្រប់គ្រងផលិតផល និងការបញ្ជាទិញរបស់អ្នកពីផ្ទាំងទីផ្សារ';

  @override
  String get profileSellerActivatedSnackbar =>
      'ឥឡូវនេះអ្នកគឺជាផ្នែកមួយនៃកម្មវិធីអ្នកលក់!';

  @override
  String get profileSellerGoToMarketplace => 'ទៅកាន់ទីផ្សារ';

  @override
  String get profileEditProfileLabel => 'កែសម្រួលប្រវត្តិរូប';

  @override
  String get sellerDashboardScreenTitle => 'ផ្ទាំងគ្រប់គ្រង';

  @override
  String get sellerDashboardVerifiedBadge => 'បានផ្ទៀងផ្ទាត់';

  @override
  String get sellerDashboardWelcomeMessage =>
      'សូមស្វាគមន៍! នេះជាសង្ខេបការអនុវត្តការងារហាងលក់ដុំរបស់អ្នកថ្ងៃនេះ។';

  @override
  String get sellerDashboardRevenueLabel => 'ចំណូល';

  @override
  String get sellerDashboardPendingLabel => 'កំពុងរង់ចាំ';

  @override
  String sellerDashboardPendingOrdersLabel(int count) {
    return 'ការបញ្ជាទិញ $count';
  }

  @override
  String get sellerDashboardProductsLabel => 'ផលិតផល';

  @override
  String sellerDashboardProductsCountLabel(int count) {
    return 'ទំនិញ $count';
  }

  @override
  String get sellerDashboardQuickActionsTitle => 'សកម្មភាពរហ័ស';

  @override
  String get sellerDashboardAddListingAction => 'បន្ថែមទំនិញ';

  @override
  String get sellerDashboardMyInventoryAction => 'ស្តុកទំនិញរបស់ខ្ញុំ';

  @override
  String get sellerDashboardOrdersAction => 'ការបញ្ជាទិញ';

  @override
  String get sellerDashboardEarningsAction => 'ចំណូល';

  @override
  String get sellerDashboardBuyerToolsTitle => 'ទិញទំនិញជាអ្នកទិញ';

  @override
  String get sellerDashboardMarketplaceAction => 'ទីផ្សារ';

  @override
  String get sellerDashboardWishlistAction => 'ចំណូលចិត្ត';

  @override
  String get sellerDashboardCartAction => 'រទេះទំនិញ';

  @override
  String get sellerDashboardCoBuyingAction => 'ទិញរួម';

  @override
  String get sellerDashboardPerformanceTitle => 'ការអនុវត្តការងារ';

  @override
  String get sellerDashboardRatingLabel => 'ការវាយតម្លៃ';

  @override
  String get sellerDashboardCompletionLabel => 'បញ្ចប់';

  @override
  String get sellerDashboardAvgDeliveryLabel => 'រយៈពេលដឹកជញ្ជូន';

  @override
  String get sellerDashboardRecentOrdersTitle => 'ការបញ្ជាទិញថ្មីៗ';

  @override
  String get sellerDashboardViewAllLabel => 'មើលទាំងអស់';

  @override
  String get sellerEarningsScreenTitle => 'ចំណូល';

  @override
  String get sellerEarningsAvailableBalanceLabel => 'សមតុល្យដែលអាចដកបាន';

  @override
  String sellerEarningsCompletedSalesPercentLabel(int percent) {
    return '$percent% នៃការលក់ដែលបានបញ្ចប់';
  }

  @override
  String get sellerEarningsWithdrawButton => 'ដកប្រាក់';

  @override
  String get sellerEarningsReleasedLabel => 'បានផ្តល់ជូន';

  @override
  String get sellerEarningsInEscrowLabel => 'កំពុងរក្សាទុក';

  @override
  String get sellerEarningsRefundedLabel => 'បានសងវិញ';

  @override
  String get sellerEarningsFilterAllLabel => 'ទាំងអស់';

  @override
  String get sellerEarningsFilterReleasedLabel => 'បានផ្តល់ជូន';

  @override
  String get sellerEarningsFilterInEscrowLabel => 'កំពុងរក្សាទុក';

  @override
  String get sellerEarningsFilterDisputedLabel => 'ជាប់វិវាទ';

  @override
  String sellerEarningsTransactionsCountLabel(int count) {
    return '$count ប្រតិបត្តិការ';
  }

  @override
  String sellerEarningsOrderBuyerLabel(String id, String buyer) {
    return '#$id • $buyer';
  }

  @override
  String get sellerEarningsSaleAmountLabel => 'ចំនួនលក់';

  @override
  String sellerEarningsPlatformFeeLabel(int rate) {
    return 'ថ្លៃសេវាវេទិកា ($rate%)';
  }

  @override
  String get sellerEarningsYourEarningsLabel => 'ចំណូលរបស់អ្នក';

  @override
  String get sellerEarningsWithdrawalLabel => 'ការដកប្រាក់';

  @override
  String get sellerEarningsStatusPending => 'កំពុងរង់ចាំ';

  @override
  String get sellerEarningsStatusInEscrow => 'កំពុងរក្សាទុក';

  @override
  String get sellerEarningsStatusReleased => 'បានផ្តល់ជូន';

  @override
  String get sellerEarningsStatusDisputed => 'បានសងវិញ';

  @override
  String get sellerEarningsStatusWithdrawn => 'បានដក';

  @override
  String get sellerEarningsEscrowNoticeText =>
      'ប្រាក់ត្រូវបានរក្សាទុករយៈពេល 48 ម៉ោងបន្ទាប់ពីការទិញ។ នៅពេលបានផ្តល់ជូន សូមចុច \"ដកប្រាក់\" ដើម្បីផ្ទេរចំណូលទៅគណនីធនាគាររបស់អ្នក។';

  @override
  String get sellerEarningsEmptyStateMessage =>
      'មិនមានប្រតិបត្តិការនៅក្នុងប្រភេទនេះទេ';

  @override
  String get sellerEarningsWithdrawSheetTitle => 'ដកប្រាក់';

  @override
  String get sellerEarningsWithdrawPoweredByLabel => 'ដំណើរការដោយ ABA Pay';

  @override
  String get sellerEarningsWithdrawAmountLabel => 'ចំនួនទឹកប្រាក់ដក (\$)';

  @override
  String get sellerEarningsAccountHolderNameLabel => 'ឈ្មោះម្ចាស់គណនី';

  @override
  String get sellerEarningsAccountHolderNameHint => 'ឈ្មោះពេញលើគណនី';

  @override
  String get sellerEarningsRoutingNumberLabel => 'លេខ Routing';

  @override
  String get sellerEarningsRoutingNumberHint =>
      'បញ្ចូលលេខ Routing របស់ ABA (ឧ. 020001)';

  @override
  String get sellerEarningsAccountNumberLabel => 'លេខគណនី';

  @override
  String get sellerEarningsAccountNumberHint => 'បញ្ចូលលេខគណនី ABA';

  @override
  String get sellerEarningsWithdrawNoticeText =>
      'ប្រាក់នឹងត្រូវផ្ទេរភ្លាមទៅគណនី ABA Pay ដែលអ្នកបានកំណត់។ ការពិនិត្យសុវត្ថិភាពស្តង់ដារអាចនឹងអនុវត្ត។';

  @override
  String get sellerEarningsWithdrawContinueButton => 'បន្ត';

  @override
  String get sellerEarningsWithdrawFieldRequiredError =>
      'ត្រូវការបំពេញព័ត៌មាននេះ';

  @override
  String get sellerEarningsWithdrawAmountInvalidError =>
      'សូមបញ្ចូលចំនួនទឹកប្រាក់ត្រឹមត្រូវ';

  @override
  String get sellerEarningsWithdrawAmountExceedsError =>
      'ចំនួនទឹកប្រាក់លើសសមតុល្យដែលមាន';

  @override
  String get sellerEarningsWithdrawJustNowLabel => 'ទើបតែឥឡូវនេះ';

  @override
  String sellerEarningsWithdrawSuccessSnackbar(String amount) {
    return 'ការដកប្រាក់ចំនួន \$$amount ត្រូវបានដាក់ស្នើ';
  }

  @override
  String get sellerEarningsWithdrawSuccessTitle => 'ជោគជ័យ';

  @override
  String sellerEarningsWithdrawSuccessMessage(String amount) {
    return 'ការដកប្រាក់ចំនួន \$$amount ត្រូវបានចាប់ផ្តើម។ ប្រាក់នឹងចូលក្នុងរយៈពេល 2-3 ថ្ងៃធ្វើការ។';
  }

  @override
  String get sellerEarningsWithdrawSuccessOkButton => 'យល់ព្រម';

  @override
  String get sellerOrdersScreenTitle => 'ការបញ្ជាទិញ';

  @override
  String get sellerOrdersEmptyStateMessage =>
      'មិនមានការបញ្ជាទិញនៅក្នុងប្រភេទនេះទេ';

  @override
  String sellerOrdersFilterAllLabel(int count) {
    return 'ទាំងអស់ ($count)';
  }

  @override
  String sellerOrdersFilterPendingLabel(int count) {
    return 'កំពុងរង់ចាំ ($count)';
  }

  @override
  String sellerOrdersQuantityProductLabel(String quantity, String product) {
    return '$quantity • $product';
  }

  @override
  String get sellerOrdersCoBuyBadgeLabel => 'ទិញរួម';

  @override
  String get sellerOrderDetailBuyerInfoSection => 'ព័ត៌មានអ្នកទិញ';

  @override
  String sellerOrderDetailPlatformFeeLabel(int rate) {
    return 'ថ្លៃសេវាវេទិកា ($rate%)';
  }

  @override
  String get sellerOrderDetailYourEarningsLabel => 'ចំណូលរបស់អ្នក';

  @override
  String get sellerOrderDetailAcceptButton => 'ទទួលយកការបញ្ជាទិញ';

  @override
  String get sellerOrderDetailDeclineButton => 'បដិសេធការបញ្ជាទិញ';

  @override
  String get sellerOrderDetailOrderAcceptedSnackbar => 'បានទទួលយកការបញ្ជាទិញ';

  @override
  String get sellerOrderDetailOrderDeclinedSnackbar => 'បានបដិសេធការបញ្ជាទិញ';

  @override
  String get sellerOrderDetailDeclineConfirmTitle => 'បដិសេធការបញ្ជាទិញនេះ?';

  @override
  String get sellerOrderDetailDeclineConfirmMessage =>
      'អ្នកទិញនឹងទទួលបានការជូនដំណឹងថាអ្នកមិនអាចបំពេញការបញ្ជាទិញនេះបានទេ។';

  @override
  String get sellerOrderDetailDeclineConfirmCancel => 'បោះបង់';

  @override
  String get sellerOrderDetailDeclineConfirmConfirm => 'បដិសេធ';

  @override
  String get myInventoryScreenTitle => 'ស្តុកទំនិញរបស់ខ្ញុំ';

  @override
  String get myInventorySearchHint => 'ស្វែងរកទំនិញ...';

  @override
  String get myInventoryFilterAll => 'ទាំងអស់';

  @override
  String get myInventoryFilterActive => 'កំពុងលក់';

  @override
  String get myInventoryFilterInactive => 'បានផ្អាក';

  @override
  String myInventoryStockLabel(String stock) {
    return 'ស្តុក៖ $stock';
  }

  @override
  String get myInventoryEmptyStateMessage => 'រកមិនឃើញទំនិញទេ។';

  @override
  String myInventoryListingActivatedSnackbar(String product) {
    return '$product កំពុងលក់ហើយ';
  }

  @override
  String myInventoryListingDeactivatedSnackbar(String product) {
    return '$product ត្រូវបានផ្អាក';
  }

  @override
  String get profileEditProfileRoleLabel => 'តួនាទីគណនី';

  @override
  String get profileEditProfileRoleSheetTitle => 'ជ្រើសរើសតួនាទីគណនី';

  @override
  String get profileEditProfileChangePhoto => 'ប្តូររូបភាព';

  @override
  String get profileEditProfileNameLabel => 'ឈ្មោះពេញ';

  @override
  String get profileEditProfileNameHint => 'បញ្ចូលឈ្មោះពេញរបស់អ្នក';

  @override
  String get profileEditProfileNameRequired => 'សូមបញ្ចូលឈ្មោះរបស់អ្នក';

  @override
  String get profileEditProfilePhoneLabel => 'លេខទូរស័ព្ទ';

  @override
  String get profileEditProfilePhoneHint => 'បញ្ចូលលេខទូរស័ព្ទរបស់អ្នក';

  @override
  String get profileEditProfilePhoneRequired => 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក';

  @override
  String get profileEditProfileEmailLabel => 'អាសយដ្ឋានអ៊ីមែល';

  @override
  String get profileEditProfileEmailHint => 'បញ្ចូលអាសយដ្ឋានអ៊ីមែលរបស់អ្នក';

  @override
  String get profileEditProfileEmailRequired =>
      'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលរបស់អ្នក';

  @override
  String get profileEditProfileEmailInvalid =>
      'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលដែលត្រឹមត្រូវ';

  @override
  String get profileEditProfileSaveButton => 'រក្សាទុកការផ្លាស់ប្តូរ';

  @override
  String get profileEditProfileSavedSnackbar =>
      'បានធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូបដោយជោគជ័យ';

  @override
  String get profileEditProfileSaveErrorSnackbar =>
      'មិនអាចរក្សាទុកប្រវត្តិរូបរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get profileEditProfileLoadErrorSnackbar =>
      'មិនអាចផ្ទុកប្រវត្តិរូបរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get shopProfileScreenTitle => 'ប្រវត្តិរូបហាង';

  @override
  String get shopProfileChangeLogo => 'ប្តូរឡូហ្គោហាង';

  @override
  String get shopProfileShopNameLabel => 'ឈ្មោះហាង';

  @override
  String get shopProfileShopNameHint => 'បញ្ចូលឈ្មោះហាងរបស់អ្នក';

  @override
  String get shopProfileShopNameRequired => 'សូមបញ្ចូលឈ្មោះហាងរបស់អ្នក';

  @override
  String get shopProfileBusinessTypeLabel => 'ប្រភេទអាជីវកម្ម';

  @override
  String get shopProfileBusinessTypeHint => 'ឧ. អ្នកផលិត និងចែកចាយ';

  @override
  String get shopProfileBusinessTypeRequired =>
      'សូមបញ្ចូលប្រភេទអាជីវកម្មរបស់អ្នក';

  @override
  String get shopProfileYearEstablishedLabel => 'ឆ្នាំបង្កើត';

  @override
  String get shopProfileYearEstablishedHint => 'ឧ. ២០១៨';

  @override
  String get shopProfileLocationLabel => 'ទីតាំង';

  @override
  String get shopProfileLocationHint => 'ឧ. ភ្នំពេញ';

  @override
  String get shopProfileLocationRequired => 'សូមបញ្ចូលទីតាំងរបស់អ្នក';

  @override
  String get shopProfilePhoneLabel => 'លេខទូរស័ព្ទ';

  @override
  String get shopProfilePhoneHint => 'បញ្ចូលលេខទូរស័ព្ទរបស់អ្នក';

  @override
  String get shopProfilePhoneRequired => 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក';

  @override
  String get shopProfileEmailLabel => 'អាសយដ្ឋានអ៊ីមែល';

  @override
  String get shopProfileEmailHint => 'បញ្ចូលអាសយដ្ឋានអ៊ីមែលរបស់អ្នក';

  @override
  String get shopProfileEmailRequired => 'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលរបស់អ្នក';

  @override
  String get shopProfileEmailInvalid => 'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលដែលត្រឹមត្រូវ';

  @override
  String get shopProfileDescriptionLabel => 'ការពិពណ៌នាអាជីវកម្ម';

  @override
  String get shopProfileDescriptionHint => 'ប្រាប់អ្នកទិញអំពីអាជីវកម្មរបស់អ្នក';

  @override
  String get shopProfileSaveButton => 'រក្សាទុកការផ្លាស់ប្តូរ';

  @override
  String get shopProfileSavedSnackbar =>
      'បានធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូបហាងដោយជោគជ័យ';

  @override
  String get shopProfileSaveErrorSnackbar =>
      'មិនអាចរក្សាទុកប្រវត្តិរូបហាងរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get addListingScreenTitle => 'បន្ថែមទំនិញ';

  @override
  String get addListingProductNameLabel => 'ឈ្មោះផលិតផល';

  @override
  String get addListingProductNameHint => 'ឧ. គ្រាប់ស្វាយចន្ទីគុណភាពខ្ពស់';

  @override
  String get addListingProductNameRequired => 'សូមបញ្ចូលឈ្មោះផលិតផល';

  @override
  String get addListingCategoryLabel => 'ប្រភេទ';

  @override
  String get addListingCategoryHint => 'ជ្រើសរើសប្រភេទ';

  @override
  String get addListingCategoryRequired => 'សូមជ្រើសរើសប្រភេទ';

  @override
  String get addListingPriceLabel => 'តម្លៃគិតជាដុល្លារ';

  @override
  String get addListingPriceRequired => 'សូមបញ្ចូលតម្លៃ';

  @override
  String get addListingPriceInvalid => 'សូមបញ្ចូលតម្លៃដែលត្រឹមត្រូវ';

  @override
  String get addListingMoqLabel => 'ចំនួនបញ្ជាទិញអប្បបរមា';

  @override
  String get addListingMoqHint => 'ឧ. ១០០ បាវ';

  @override
  String get addListingMoqRequired => 'សូមបញ្ចូលចំនួនបញ្ជាទិញអប្បបរមា';

  @override
  String get addListingMoqInvalid => 'សូមបញ្ចូលចំនួនដែលត្រឹមត្រូវ';

  @override
  String get addListingStockLabel => 'ចំនួនស្តុក';

  @override
  String get addListingStockHint => 'ឧ. ៥០០';

  @override
  String get addListingStockRequired => 'សូមបញ្ចូលចំនួនស្តុក';

  @override
  String get addListingStockInvalid => 'សូមបញ្ចូលចំនួនដែលត្រឹមត្រូវ';

  @override
  String get addListingPhotosLabel => 'រូបភាពផលិតផល';

  @override
  String get addListingCoverPhotoCta => 'ចុចដើម្បីបន្ថែមរូបភាពគម្រប';

  @override
  String get addListingPhotosFormatHint => 'JPG, PNG រហូតដល់ 5MB';

  @override
  String get addListingPhotosHelper =>
      'អាប់ឡូតរូបភាពបានរហូតដល់ ៥សន្លឹក។ រូបភាពដំបូងគឺជារូបគម្រប។';

  @override
  String get addListingCoverPhotoRequired => 'សូមបន្ថែមរូបភាពគម្រប';

  @override
  String get addListingDescriptionLabel => 'ការពិពណ៌នា';

  @override
  String get addListingDescriptionHint =>
      'ឧ. អាវយឺតកជុំ ១០០% កប្បាស ថ្នាក់គុណភាព A លក់ជាដុំចាប់ពី ៥០ បំណែក ដឹកជញ្ជូនក្នុងរយៈពេល ៣-៥ ថ្ងៃធ្វើការ។';

  @override
  String get addListingSampleTestingLabel => 'ការសាកល្បងគំរូ';

  @override
  String get addListingSampleTestingToggleTitle => 'បើកការសាកល្បងគំរូ';

  @override
  String get addListingSampleTestingToggleSubtitle =>
      'កំណត់ ១ ទំនិញក្នុងមួយអ្នកទិញ';

  @override
  String get addListingSamplePriceLabel => 'តម្លៃគំរូគិតជាដុល្លារ';

  @override
  String get addListingSamplePriceRequired => 'សូមបញ្ចូលតម្លៃគំរូ';

  @override
  String get addListingSamplePriceInvalid => 'សូមបញ្ចូលតម្លៃគំរូដែលត្រឹមត្រូវ';

  @override
  String get addListingVariantsLabel => 'ទំហំ និងពណ៌';

  @override
  String get addListingVariantsHelper =>
      'អនុញ្ញាតឱ្យអ្នកទិញជ្រើសរើសពីជម្រើសដែលអ្នកមាន';

  @override
  String get addListingAddSizeChip => 'បន្ថែមទំហំ';

  @override
  String get addListingAddSizeDialogTitle => 'បន្ថែមទំហំ';

  @override
  String get addListingAddSizeDialogHint => 'ឧ. កុមារ, ៤២, ទំហំទូទៅ';

  @override
  String get addListingAddSizeConfirm => 'បន្ថែម';

  @override
  String get addListingAddColorDialogTitle => 'ជ្រើសរើសពណ៌';

  @override
  String get addListingCreateButton => 'បង្កើតទំនិញ';

  @override
  String get addListingCreatedSnackbar => 'បានបង្កើតទំនិញដោយជោគជ័យ';

  @override
  String get addListingCreateErrorSnackbar =>
      'មិនអាចបង្កើតទំនិញរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get profileLogout => 'ចេញពីប្រព័ន្ធ';

  @override
  String get profileRefreshFailedSnackbar =>
      'មិនអាចធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូបរបស់អ្នកបានទេ។ សូមពិនិត្យការតភ្ជាប់របស់អ្នក ហើយព្យាយាមម្តងទៀត។';

  @override
  String get currencyScreenTitle => 'រូបិយប័ណ្ណទូទាត់';

  @override
  String get currencyScreenIntro =>
      'ជ្រើសរើសរូបិយប័ណ្ណដែលអ្នកចង់ប្រើសម្រាប់ប្រតិបត្តិការទាំងអស់នៅលើ Bosdom។ តម្លៃនឹងត្រូវបានបង្ហាញជារូបិយប័ណ្ណដែលអ្នកបានជ្រើសរើស។';

  @override
  String get currencySectionSelect => 'ជ្រើសរើសរូបិយប័ណ្ណ';

  @override
  String get currencySectionDisplaySettings => 'ការកំណត់ការបង្ហាញរូបិយប័ណ្ណ';

  @override
  String get currencyUsdName => 'ដុល្លារអាមេរិក (USD)';

  @override
  String get currencyKhrName => 'រៀលខ្មែរ (KHR)';

  @override
  String get currencyExchangeRateLabel => 'អត្រាប្តូរប្រាក់';

  @override
  String get currencyRateDisclaimer =>
      'អត្រាប្តូរប្រាក់ត្រូវបានធ្វើបច្ចុប្បន្នភាពជារៀងរាល់ថ្ងៃ។ អត្រាប្តូរប្រាក់ចុងក្រោយនឹងត្រូវអនុវត្តនៅពេលទូទាត់ប្រាក់។';

  @override
  String currencyLastUpdatedLabel(String date) {
    return 'បានធ្វើបច្ចុប្បន្នភាពចុងក្រោយ៖ $date';
  }

  @override
  String get currencyActiveStatus => 'សកម្ម';

  @override
  String get currencyDailyUpdateChip => 'ការធ្វើបច្ចុប្បន្នភាពប្រចាំថ្ងៃ';

  @override
  String get currencyShowBothToggleLabel => 'បង្ហាញតម្លៃជាទាំងពីររូបិយប័ណ្ណ';

  @override
  String get currencySavedSnackbar => 'ចំណូលចិត្តរូបិយប័ណ្ណត្រូវបានរក្សាទុក';

  @override
  String get helpSupportScreenTitle => 'ជំនួយ និងគាំទ្រ';

  @override
  String get helpSupportSearchHint => 'ស្វែងរកសំណួរញឹកញាប់ ឬអត្ថបទ...';

  @override
  String get helpSupportCategoriesLabel => 'ប្រភេទសំណួរញឹកញាប់';

  @override
  String get helpSupportCategoryGettingStarted => 'ការចាប់ផ្តើមប្រើប្រាស់';

  @override
  String get helpSupportCategoryOrdersPayments => 'ការបញ្ជាទិញ និងការទូទាត់';

  @override
  String get helpSupportCategoryShippingDelivery => 'ការដឹកជញ្ជូន';

  @override
  String get helpSupportCategoryAccountVerification => 'គណនី និងការផ្ទៀងផ្ទាត់';

  @override
  String get helpSupportCategoryReturnsDisputes => 'ការត្រឡប់ និងវិវាទ';

  @override
  String get helpSupportAssistanceTitle => 'ត្រូវការជំនួយផ្ទាល់ខ្លួនមែនទេ?';

  @override
  String get helpSupportAssistanceBody =>
      'ក្រុមជំនួយ B2B របស់យើងអាចទាក់ទងបានពីថ្ងៃច័ន្ទ-សុក្រ ម៉ោង ៨ព្រឹក-៦ល្ងាច (ម៉ោងកម្ពុជា) សម្រាប់ដោះស្រាយវិវាទការបញ្ជាទិញ ឬសំណួរអំពីវេទិកា។';

  @override
  String get helpSupportLiveChat => 'ជជែកផ្ទាល់';

  @override
  String get helpSupportCallUs => 'ទូរស័ព្ទមកយើង';

  @override
  String get helpSupportReportIssue => 'រាយការណ៍បញ្ហា / កំហុស';

  @override
  String get reportIssueScreenTitle => 'រាយការណ៍បញ្ហា';

  @override
  String get reportIssueTypeLabel => 'ប្រភេទបញ្ហា';

  @override
  String get reportIssueTypeOrderProblem => 'បញ្ហាការបញ្ជាទិញ';

  @override
  String get reportIssueTypePaymentIssue => 'បញ្ហាការទូទាត់';

  @override
  String get reportIssueTypeAppBug => 'កំហុសកម្មវិធី';

  @override
  String get reportIssueTypeDeliveryIssue => 'បញ្ហាការដឹកជញ្ជូន';

  @override
  String get reportIssueTypeAccountProblem => 'បញ្ហាគណនី';

  @override
  String get reportIssueTypeOther => 'ផ្សេងទៀត';

  @override
  String get reportIssueSubjectLabel => 'ចំណងជើង';

  @override
  String get reportIssueSubjectHint => 'សរសេរសង្ខេបអំពីបញ្ហា';

  @override
  String get reportIssueSubjectRequired => 'សូមបញ្ចូលចំណងជើង';

  @override
  String get reportIssueDescriptionLabel => 'ការពិពណ៌នា';

  @override
  String get reportIssueDescriptionHint => 'ពិពណ៌នាអំពីបញ្ហាដោយលម្អិត...';

  @override
  String get reportIssueDescriptionRequired => 'សូមពិពណ៌នាអំពីបញ្ហា';

  @override
  String get reportIssueAttachLabel => 'ភ្ជាប់រូបភាពថតអេក្រង់';

  @override
  String get reportIssueAttachTapToUpload => 'ចុចដើម្បីបញ្ចូលរូបភាព';

  @override
  String reportIssueAttachSupports(int max) {
    return 'គាំទ្រ PNG, JPG រហូតដល់ 5MB (អតិបរមា $max ឯកសារ)';
  }

  @override
  String reportIssueMaxFilesSnackbar(int max) {
    return 'អ្នកអាចភ្ជាប់បានរហូតដល់ $max ឯកសារ';
  }

  @override
  String reportIssuePhotoLibraryErrorSnackbar(String error) {
    return 'មិនអាចបើកបណ្ណាល័យរូបភាពបានទេ៖ $error';
  }

  @override
  String get reportIssueOrderRefLabel => 'លេខយោងការបញ្ជាទិញ';

  @override
  String get reportIssueOrderRefOptional => '(ស្រេចចិត្ត)';

  @override
  String get reportIssueOrderRefHint => 'ឧ. #B2B-98741';

  @override
  String get reportIssueResponseNote =>
      'ក្រុមជំនួយលក់ដុំរបស់យើងជាធម្មតានឹងឆ្លើយតបចំពោះកំហុសកម្មវិធី និងសំណួរបច្ចេកទេសអំពីការបញ្ជាទិញក្នុងរយៈពេល ២ម៉ោង។';

  @override
  String get reportIssueSubmitButton => 'ដាក់ស្នើរបាយការណ៍';

  @override
  String get reportIssueSubmittedSnackbar =>
      'របាយការណ៍របស់អ្នកត្រូវបានដាក់ស្នើ។ យើងនឹងឆ្លើយតបទៅអ្នកឆាប់ៗនេះ។';

  @override
  String get callUsPopupBody =>
      'ខ្សែទូរស័ព្ទជំនួយអតិថិជន B2B ជំនាញរបស់យើងអាចជួយអ្នកក្នុងការដោះស្រាយការបញ្ជាទិញ វិវាទ និងជំនួយបន្ទាន់។';

  @override
  String get callUsPopupHours => 'ចន្ទ-សុក្រ ម៉ោង ៨ព្រឹក-៦ល្ងាច (ម៉ោងកម្ពុជា)';

  @override
  String get callUsPopupSupportLabel => 'ជំនួយលក់ដុំ B2B';

  @override
  String get callUsPopupPhoneNumber => '+855 23 456 789';

  @override
  String get callUsPopupCallNow => 'ហៅឥឡូវនេះ';

  @override
  String get callUsPopupLaunchError => 'មិនអាចបើកកម្មវិធីទូរស័ព្ទបានទេ';

  @override
  String get termsConditionsScreenTitle => 'លក្ខខណ្ឌប្រើប្រាស់';

  @override
  String get termsConditionsLastUpdated =>
      'ធ្វើបច្ចុប្បន្នភាពចុងក្រោយ៖ ខែសីហា ២០២៦';

  @override
  String get termsConditionsSection1Title =>
      '១. ទិដ្ឋភាពទូទៅនិងការទទួលយកលក្ខខណ្ឌប្រើប្រាស់វេទិកា';

  @override
  String get termsConditionsSection1Point1 =>
      'Bosdom គឺជាទីផ្សារលក់ដុំបែប B2B ដែលបង្កើតឡើងសម្រាប់អ្នកលក់រាយ និងអ្នកផ្គត់ផ្គង់កម្ពុជាដែលបានផ្ទៀងផ្ទាត់។ វេទិកានេះភ្ជាប់អ្នកលក់រាយឯករាជ្យជាមួយអ្នកផ្គត់ផ្គង់ដែលអាចទុកចិត្តបានតាមរយៈប្រព័ន្ធទូទាត់ប្រាក់ដាក់ជាកក់ (Escrow) ដែលមានសុវត្ថិភាព ដោយមានមុខងារផ្ទៀងផ្ទាត់គំរូ ការទិញរួមគ្នាជាក្រុម និងការការពារប្រាក់ដាក់ជាកក់ដោយស្វ័យប្រវត្តិ។';

  @override
  String get termsConditionsSection1Point2 =>
      'តាមរយៈការបង្កើតគណនី អ្នកបញ្ជាក់ថា៖';

  @override
  String get termsConditionsSection1Point3 => 'អ្នកមានអាយុយ៉ាងតិច ១៨ ឆ្នាំ។';

  @override
  String get termsConditionsSection1Point4 =>
      'អ្នកកំពុងដំណើរការអាជីវកម្មស្របច្បាប់នៅកម្ពុជា។';

  @override
  String get termsConditionsSection1Point5 =>
      'ព័ត៌មានទាំងអស់ដែលបានផ្តល់ក្នុងអំឡុងពេលចុះឈ្មោះមានភាពត្រឹមត្រូវ ទាន់សម័យ និងពេញលេញ។';

  @override
  String get termsConditionsSection1Point6 =>
      'អ្នកយល់ព្រមអនុវត្តតាមលក្ខខណ្ឌទាំងនេះ ព្រមទាំងច្បាប់ និងបទប្បញ្ញត្តិមូលដ្ឋានទាំងអស់ដែលពាក់ព័ន្ធ។';

  @override
  String get termsConditionsSection2Title => '២. ការចុះឈ្មោះនិងផ្ទៀងផ្ទាត់គណនី';

  @override
  String get termsConditionsSection2Point1 =>
      'អ្នកប្រើប្រាស់ទាំងអស់ត្រូវចុះឈ្មោះជាមួយព័ត៌មានអាជីវកម្ម និងអត្តសញ្ញាណដែលត្រឹមត្រូវ មុននឹងបញ្ចប់ប្រតិបត្តិការណាមួយនៅលើវេទិកា។';

  @override
  String get termsConditionsSection2Point2 =>
      'Bosdom រក្សាសិទ្ធិក្នុងការបដិសេធ ឬផ្អាកការចុះឈ្មោះគណនីណាដែលមិនអាចផ្ទៀងផ្ទាត់អត្តសញ្ញាណបាន ឬមានព័ត៌មានមិនពិត។';

  @override
  String get termsConditionsSection2Point3 =>
      'អ្នកប្រើប្រាស់ម្នាក់ៗត្រូវបានកំណត់ត្រឹមប្រវត្តិរូបជាអ្នកជំនួញដែលបានផ្ទៀងផ្ទាត់មួយប៉ុណ្ណោះក្នុងមួយអាជីវកម្ម។';

  @override
  String get termsConditionsSection2Point4 =>
      'អ្នកផ្គត់ផ្គង់ត្រូវផ្តល់ព័ត៌មានផលិតផល តម្លៃ និងស្តុកទំនិញឱ្យបានត្រឹមត្រូវជានិច្ច។';

  @override
  String get termsConditionsSection2Point5 =>
      'អ្នកទិញមានទំនួលខុសត្រូវក្នុងការធ្វើបច្ចុប្បន្នភាពព័ត៌មានគណនី និងអាជីវកម្មរបស់ខ្លួនជានិច្ច។';

  @override
  String get termsConditionsSection3Title => '៣. មុខងារសាកល្បងគំរូមុនទិញលក់ដុំ';

  @override
  String get termsConditionsSection3Point1 =>
      'មុខងារសាកល្បងគំរូរបស់ Bosdom អនុញ្ញាតឱ្យអ្នកទិញបញ្ជាទិញផលិតផលមួយឯកតាក្នុងតម្លៃអ្នកប្រើប្រាស់ មុននឹងសម្រេចចិត្តទិញលក់ដុំ។';

  @override
  String get termsConditionsSection3Point2 =>
      'អ្នកទិញម្នាក់ៗអាចបញ្ជាទិញគំរូបានតែម្តងគត់ក្នុងមួយផលិតផល ដើម្បីទប់ស្កាត់ការប្រើប្រាស់មុខងារនេះខុសគោលបំណង។';

  @override
  String get termsConditionsSection3Point3 =>
      'ការបញ្ជាទិញគំរូមិនអនុវត្តតម្លៃលក់ដុំទេ ហើយត្រូវបង់ថ្លៃដឹកជញ្ជូន និងការចាត់ចែងតាមស្តង់ដារ។';

  @override
  String get termsConditionsSection3Point4 =>
      'អ្នកផ្គត់ផ្គង់ត្រូវផ្តល់គំរូដែលមានគុណភាពដូចគ្នានឹងអ្វីដែលបានផ្សព្វផ្សាយក្នុងបញ្ជីផលិតផល។ ការធ្វើឱ្យខុសពីការពិតអំពីគុណភាពគំរូ ត្រូវចាត់ទុកជាការបំពានលក្ខខណ្ឌទាំងនេះ។';

  @override
  String get termsConditionsSection4Title => '៤. ការទិញរួមគ្នាតាមសង្គម';

  @override
  String get termsConditionsSection4Point1 =>
      'មុខងារទិញរួមគ្នារបស់ Bosdom អនុញ្ញាតឱ្យអ្នកទិញរួមបញ្ចូលការបញ្ជាទិញជាមួយអ្នកជំនួញផ្សេងទៀត ដើម្បីទទួលបានតម្លៃលក់ដុំ។';

  @override
  String get termsConditionsSection4Point2 =>
      'អ្នកទិញដែលបានចុះឈ្មោះណាមួយអាចបង្កើតក្រុមទិញរួមគ្នា ដោយចុច \"អញ្ជើញទិញរួមគ្នា\" លើផលិតផលដែលមានលក្ខណៈគ្រប់គ្រាន់ ហើយចែករំលែកតំណអញ្ជើញដែលបានបង្កើត។';

  @override
  String get termsConditionsSection4Point3 =>
      'នៅពេលក្រុមឈានដល់ចំនួនគោលដៅ អ្នកផ្គត់ផ្គង់នឹងចាត់ចែងការបញ្ជាទិញតាមថ្នាក់តម្លៃលក់ដុំដែលអនុវត្ត។';

  @override
  String get termsConditionsSection4Point4 =>
      'សមាជិកនីមួយៗចែករំលែកថ្លៃដឹកជញ្ជូនតាមសមាមាត្រនៃចំណែកបញ្ជាទិញរបស់ខ្លួន។';

  @override
  String get termsConditionsSection4Point5 =>
      'ប្រសិនបើក្រុមទិញរួមគ្នាមិនឈានដល់ចំនួនតម្រូវការក្នុងរយៈពេលកំណត់ទេ ប្រាក់ទាំងអស់នឹងត្រូវសងវិញដោយស្វ័យប្រវត្តិទៅសមាជិកគ្រប់រូប។';

  @override
  String get termsConditionsSection5Title =>
      '៥. ប្រព័ន្ធទូទាត់ប្រាក់ដាក់ជាកក់ និងផ្ទៀងផ្ទាត់តាមកូដ QR';

  @override
  String get termsConditionsSection5Point1 =>
      'ប្រតិបត្តិការហិរញ្ញវត្ថុទាំងអស់នៅលើ Bosdom ត្រូវធ្វើឡើងតាមរយៈប្រព័ន្ធប្រាក់ដាក់ជាកក់របស់វេទិកា។';

  @override
  String get termsConditionsSection5Point2 =>
      'វិធីទូទាត់ដែលអាចប្រើបានរួមមាន Bakong (ធនាគារជាតិនៃកម្ពុជា) និងច្រកទូទាត់ផ្សេងទៀតដែលបានអនុម័ត។';

  @override
  String get termsConditionsSection5Point3 =>
      'ប្រាក់ត្រូវបានរក្សាទុកជាកក់រហូតដល់ការដឹកជញ្ជូនត្រូវបានបញ្ជាក់។';

  @override
  String get termsConditionsSection5Point4 =>
      'នៅពេលទទួលទំនិញ អ្នកទទួលត្រូវស្កេនកូដ QR ដែលអ្នកផ្គត់ផ្គង់ ឬអ្នកដឹកជញ្ជូនបង្ហាញ ដើម្បីបញ្ជាក់ការទទួល។';

  @override
  String get termsConditionsSection5Point5 =>
      'នៅពេលការដឹកជញ្ជូនត្រូវបានបញ្ជាក់តាមការស្កេនកូដ QR ប្រាក់ដាក់ជាកក់នឹងត្រូវផ្ញើទៅអ្នកផ្គត់ផ្គង់។ បញ្ហាទាក់ទងនឹងការដឹកជញ្ជូនអាចលើកឡើងតាមដំណើរការដោះស្រាយវិវាទដែលបានរៀបរាប់នៅផ្នែកទី ៨។';

  @override
  String get termsConditionsSection6Title =>
      '៦. គោលការណ៍ជជែក និងវិធានទំនាក់ទំនង';

  @override
  String get termsConditionsSection6Point1 =>
      'Bosdom ផ្តល់មុខងារជជែកក្នុងកម្មវិធីសម្រាប់ការទំនាក់ទំនងផ្ទាល់រវាងអ្នកទិញ និងអ្នកផ្គត់ផ្គង់។';

  @override
  String get termsConditionsSection6Point2 =>
      'មុននឹងចូលប្រើមុខងារជជែក អ្នកប្រើប្រាស់ត្រូវពិនិត្យ និងទទួលយក \"គោលការណ៍ជជែក និងជួញដូរ\" ព្រមទាំង \"សេចក្តីប្រកាសទំនួលខុសត្រូវ\"។';

  @override
  String get termsConditionsSection6Point3 =>
      'ការធ្វើដូចខាងក្រោមត្រូវបានហាមឃាត់ក្នុងការទំនាក់ទំនងលើវេទិកា៖';

  @override
  String get termsConditionsSection6Point4 => 'រៀបចំការទូទាត់ប្រាក់ក្រៅវេទិកា។';

  @override
  String get termsConditionsSection6Point5 =>
      'ចែករំលែកព័ត៌មានគណនីធនាគារផ្ទាល់ខ្លួនសម្រាប់ការទូទាត់ក្រៅវេទិកា។';

  @override
  String get termsConditionsSection6Point6 =>
      'ផ្ញើមាតិកាដែលបំពានច្បាប់ ក្លែងបន្លំ ឬមិនសមរម្យ។';

  @override
  String get termsConditionsSection6Point7 =>
      'Bosdom មិនទទួលខុសត្រូវចំពោះការខាតបង់ណាមួយដែលកើតឡើងពីការទូទាត់ ឬការជួញដូរក្រៅវេទិកាដែលបំពានគោលការណ៍នេះទេ។ ការបំពានអាចនាំឱ្យមានការព្រមាន ការផ្អាកគណនី ឬការហាមឃាត់ជាអចិន្ត្រៃយ៍ អាស្រ័យលើកម្រិតធ្ងន់ធ្ងរ ដោយស្ថិតនៅក្រោមការសម្រេចចិត្តតែមួយគត់របស់ Bosdom។';

  @override
  String get termsConditionsSection7Title => '៧. តម្លៃ និងថ្នាក់បរិមាណ';

  @override
  String get termsConditionsSection7Point1 =>
      'អ្នកផ្គត់ផ្គង់កំណត់តម្លៃរបស់ខ្លួនផ្ទាល់សម្រាប់ទាំងគំរូ និងការទិញលក់ដុំ។';

  @override
  String get termsConditionsSection7Point2 =>
      'តម្លៃលក់ដុំត្រូវបានរៀបចំជាថ្នាក់បរិមាណ ដែលនឹងបើកឱ្យប្រើនៅពេលក្រុមទិញរួមគ្នា ឬការបញ្ជាទិញលក់ដុំកើនឡើង។';

  @override
  String get termsConditionsSection7Point3 =>
      'ថ្នាក់តម្លៃដែលអនុវត្តត្រូវបានបង្ហាញនៅលើបញ្ជីផលិតផលនីមួយៗ ហើយនឹងធ្វើបច្ចុប្បន្នភាពដោយស្វ័យប្រវត្តិតាមចំនួនការបញ្ជាទិញ។';

  @override
  String get termsConditionsSection7Point4 =>
      'Bosdom មិនកាន់កាប់ រក្សាទុក ឬចាត់ចែងស្តុកទំនិញផ្ទាល់ខ្លួនឡើយ។ អ្នកផ្គត់ផ្គង់ទទួលខុសត្រូវទាំងស្រុងចំពោះគុណភាពផលិតផល ការវេចខ្ចប់ និងភាពត្រឹមត្រូវនៃស្តុកទំនិញ។ តម្លៃអាចបង្ហាញជារូបិយប័ណ្ណរៀល (KHR) ឬដុល្លារអាមេរិក (USD)។';

  @override
  String get termsConditionsSection8Title => '៨. ការដោះស្រាយវិវាទ';

  @override
  String get termsConditionsSection8Point1 =>
      'ក្នុងករណីមានវិវាទកើតឡើង ដូចជាទំនិញខូចខាត មិនបានដឹកជញ្ជូន ឬគុណភាពមិនត្រូវគ្នា Bosdom ផ្តល់ដំណើរការដោះស្រាយវិវាទដែលមានរចនាសម្ព័ន្ធច្បាស់លាស់។';

  @override
  String get termsConditionsSection8Point2 =>
      'ប្រាក់ដាក់ជាកក់ដែលទាក់ទងនឹងការបញ្ជាទិញមានវិវាទនឹងនៅតែជាប់កក់ រហូតដល់វិវាទត្រូវបានដោះស្រាយ។';

  @override
  String get termsConditionsSection8Point3 =>
      'អ្នកទិញមានរយៈពេល ៥ថ្ងៃ បន្ទាប់ពីការបញ្ជាក់ការដឹកជញ្ជូន ដើម្បីដាក់ពាក្យបណ្តឹង និងផ្តល់ភស្តុតាងគាំទ្រ។';

  @override
  String get termsConditionsSection8Point4 =>
      'Bosdom រក្សាសិទ្ធិក្នុងការត្រួតពិនិត្យភស្តុតាង និងកែសម្រួលការចេញប្រាក់ពីគណនីកក់ ក្នុងករណីមានការក្លែងបន្លំ មិនដឹកជញ្ជូន ឬបំពានលក្ខខណ្ឌទាំងនេះ។';

  @override
  String get termsConditionsSection9Title => '៩. សកម្មភាពហាមឃាត់';

  @override
  String get termsConditionsSection9Point1 => 'អ្នកប្រើប្រាស់វេទិកាមិនត្រូវ៖';

  @override
  String get termsConditionsSection9Point2 =>
      'លក់ទំនិញក្លែងក្លាយ ខុសច្បាប់ ឬគ្រោះថ្នាក់។';

  @override
  String get termsConditionsSection9Point3 =>
      'បង្កើតគណនីច្រើនដើម្បីគេចវេសពីដែនកំណត់មុខងារសាកល្បងគំរូ។';

  @override
  String get termsConditionsSection9Point4 =>
      'រៀបចំក្រុមទិញរួមគ្នាដោយប្រើសមាជិកក្លែងក្លាយ ឬតម្លៃមិនពិត។';

  @override
  String get termsConditionsSection9Point5 =>
      'ចូលរួមក្នុងការកំណត់តម្លៃរួម ការផ្សព្វផ្សាយបញ្ឆោត ឬការចុះបញ្ជីផលិតផលមិនពិត។';

  @override
  String get termsConditionsSection9Point6 =>
      'ប្រើកម្មវិធីស្វ័យប្រវត្តិ ឬស្គ្រីបដើម្បីធ្វើអន្តរកម្មជាមួយវេទិកា។';

  @override
  String get termsConditionsSection9Point7 =>
      'ការបំពានលើចំណុចណាមួយខាងលើអាចនាំឱ្យមានការផ្អាកគណនីភ្លាមៗ ការបាត់បង់ប្រាក់កក់ដែលមិនទាន់ចេញ និងករណីចាំបាច់ អាចបញ្ជូនទៅអាជ្ញាធរពាក់ព័ន្ធ។';

  @override
  String get termsConditionsSection10Title => '១០. ដែនកំណត់នៃទំនួលខុសត្រូវ';

  @override
  String get termsConditionsSection10Point1 =>
      'Bosdom ដើរតួជាអន្តរការីទីផ្សារភ្ជាប់អ្នកទិញ និងអ្នកផ្គត់ផ្គង់តែប៉ុណ្ណោះ។ ក្នុងកម្រិតអតិបរមាដែលច្បាប់អនុញ្ញាត Bosdom មិនទទួលខុសត្រូវចំពោះ៖';

  @override
  String get termsConditionsSection10Point2 =>
      'គុណភាពផលិតផល ភាពត្រឹមត្រូវនៃការពិពណ៌នា ឬការអះអាងរបស់អ្នកផ្គត់ផ្គង់។';

  @override
  String get termsConditionsSection10Point3 =>
      'កាលវិភាគដឹកជញ្ជូន ឬដំណើរការរបស់អ្នកដឹកជញ្ជូនដែលនៅក្រៅការគ្រប់គ្រងរបស់វេទិកា។';

  @override
  String get termsConditionsSection10Point4 =>
      'ការខាតបង់ណាមួយដែលបណ្តាលមកពីការបំពានលក្ខខណ្ឌទាំងនេះ ឬច្បាប់កម្ពុជាដែលពាក់ព័ន្ធ។';

  @override
  String get termsConditionsSection10Point5 =>
      'Bosdom មិនទទួលខុសត្រូវចំពោះការខូចខាតដោយប្រយោល ចៃដន្យ ឬជាផលវិបាកដែលកើតចេញពីការប្រើប្រាស់វេទិកានេះឡើយ។';

  @override
  String get termsConditionsSection11Title => '១១. ភាពឯកជននិងការការពារទិន្នន័យ';

  @override
  String get termsConditionsSection11Point1 =>
      'Bosdom ប្រមូល និងដំណើរការទិន្នន័យផ្ទាល់ខ្លួនស្របតាមគោលការណ៍ភាពឯកជនរបស់យើង និងច្បាប់ការពារទិន្នន័យកម្ពុជាដែលពាក់ព័ន្ធ។';

  @override
  String get termsConditionsSection11Point2 =>
      'នេះរួមមានព័ត៌មានចុះបញ្ជីអាជីវកម្ម ឈ្មោះ លេខទូរស័ព្ទ និងអាសយដ្ឋានអ៊ីមែល ដែលប្រមូលសម្រាប់គោលបំណងផ្ទៀងផ្ទាត់អត្តសញ្ញាណ និងប្រតិបត្តិការវេទិកាតែប៉ុណ្ណោះ។';

  @override
  String get termsConditionsSection12Title => '១២. ការកែប្រែលក្ខខណ្ឌ';

  @override
  String get termsConditionsSection12Point1 =>
      'Bosdom រក្សាសិទ្ធិក្នុងការធ្វើបច្ចុប្បន្នភាព ឬកែប្រែលក្ខខណ្ឌទាំងនេះនៅពេលណាមួយ។ ការបន្តប្រើប្រាស់វេទិកាបន្ទាប់ពីមានការផ្លាស់ប្តូរ ចាត់ទុកថាជាការទទួលយកលក្ខខណ្ឌដែលបានធ្វើបច្ចុប្បន្នភាព។';

  @override
  String get termsConditionsSection12Point2 =>
      'អ្នកប្រើប្រាស់ដែលមិនយល់ព្រមនឹងលក្ខខណ្ឌដែលបានធ្វើបច្ចុប្បន្នភាព គួរតែឈប់ប្រើប្រាស់វេទិកានេះ។';

  @override
  String get termsConditionsContactTitle => 'ទាក់ទងមកយើងខ្ញុំ';

  @override
  String get termsConditionsContactIntro =>
      'ប្រសិនបើអ្នកមានសំណួរអំពីលក្ខខណ្ឌប្រើប្រាស់ទាំងនេះ សូមទាក់ទងមកយើងខ្ញុំ៖';

  @override
  String get termsConditionsContactEmail => 'support@bosdom.com';

  @override
  String get termsConditionsContactInApp => 'ក្នុងកម្មវិធី៖ ជំនួយ និងគាំទ្រ';

  @override
  String get privacyPolicyScreenTitle => 'គោលការណ៍ភាពឯកជន';

  @override
  String get privacyPolicyEffectiveDate => 'ថ្ងៃចូលជាធរមាន៖ ខែសីហា ២០២៦';

  @override
  String get privacyPolicySection1Title => '១. ព័ត៌មានដែលយើងប្រមូល';

  @override
  String get privacyPolicySection1Point1 => 'ក) ព័ត៌មានគណនី';

  @override
  String get privacyPolicySection1Point2 => 'ឈ្មោះពេញ លេខទូរស័ព្ទ និងអ៊ីមែល';

  @override
  String get privacyPolicySection1Point3 =>
      'ឈ្មោះអាជីវកម្ម ប្រភេទ និងលេខចុះបញ្ជី';

  @override
  String get privacyPolicySection1Point4 =>
      'ទីតាំងអាជីវកម្ម និងអាសយដ្ឋានដឹកជញ្ជូន';

  @override
  String get privacyPolicySection1Point5 => 'រូបភាពប្រវត្តិរូប (ស្រេចចិត្ត)';

  @override
  String get privacyPolicySection1Point6 => 'ខ) ព័ត៌មានផ្ទៀងផ្ទាត់អត្តសញ្ញាណ';

  @override
  String get privacyPolicySection1Point7 =>
      'អត្តសញ្ញាណប័ណ្ណចេញដោយរដ្ឋាភិបាល (សម្រាប់ការផ្ទៀងផ្ទាត់អ្នកទិញ)';

  @override
  String get privacyPolicySection1Point8 =>
      'វិញ្ញាបនបត្រចុះបញ្ជីអាជីវកម្ម (សម្រាប់ការផ្ទៀងផ្ទាត់អ្នកផ្គត់ផ្គង់)';

  @override
  String get privacyPolicySection1Point9 =>
      'ព័ត៌មានគណនីធនាគារ/កាបូបអេឡិចត្រូនិក (Bakong QR) សម្រាប់ការទូទាត់';

  @override
  String get privacyPolicySection1Point10 => 'គ) ទិន្នន័យប្រតិបត្តិការ';

  @override
  String get privacyPolicySection1Point11 =>
      'ប្រវត្តិការបញ្ជាទិញ ចំនួនទឹកប្រាក់ទិញ និងវិធីទូទាត់';

  @override
  String get privacyPolicySection1Point12 =>
      'ការចូលរួមក្នុងការបញ្ជាទិញគំរូ និងក្រុមទិញរួម';

  @override
  String get privacyPolicySection1Point13 => 'ឃ) ទិន្នន័យទំនាក់ទំនង';

  @override
  String get privacyPolicySection1Point14 =>
      'សារជជែកក្នុងកម្មវិធី និងប្រវត្តិការសន្ទនា';

  @override
  String get privacyPolicySection1Point15 =>
      'ឯកសារភ្ជាប់ដែលបានចែករំលែករវាងអ្នកចូលរួមជជែក';

  @override
  String get privacyPolicySection1Point16 =>
      'ង) ការផ្ទៀងផ្ទាត់ និងការរកឃើញការក្លែងបន្លំ';

  @override
  String get privacyPolicySection1Point17 =>
      'ការស្កេនកូដ QR ដែលប្រើសម្រាប់បញ្ជាក់ការដឹកជញ្ជូន';

  @override
  String get privacyPolicySection1Point18 =>
      'ភស្តុតាងវីដេអូដែលបានដាក់ស្នើជាមួយការដោះស្រាយវិវាទ';

  @override
  String get privacyPolicySection1Point19 =>
      'ច) ទិន្នន័យឧបករណ៍ និងការប្រើប្រាស់';

  @override
  String get privacyPolicySection1Point20 =>
      'ប្រភេទឧបករណ៍ ប្រព័ន្ធប្រតិបត្តិការ និងកំណែកម្មវិធី';

  @override
  String get privacyPolicySection1Point21 =>
      'ទិន្នន័យទីតាំងប្រើសម្រាប់ការដឹកជញ្ជូន និងផ្គូផ្គងអ្នកដឹកជញ្ជូន';

  @override
  String get privacyPolicySection1Point22 =>
      'អាសយដ្ឋាន IP និងព័ត៌មានសម័យ/កំណត់ហេតុទូទៅ';

  @override
  String get privacyPolicySection1Point23 => 'ឆ) ទិន្នន័យទិញរួម និងសង្គម';

  @override
  String get privacyPolicySection1Point24 =>
      'ការបង្កើត និងការចូលរួមអញ្ជើញទិញរួម';

  @override
  String get privacyPolicySection1Point25 =>
      'ការចុចលើតំណអញ្ជើញ និងសកម្មភាពចូលរួមក្រុមទិញរួម';

  @override
  String get privacyPolicySection2Title =>
      '២. របៀបយើងប្រើប្រាស់ព័ត៌មានរបស់អ្នក';

  @override
  String get privacyPolicySection2Point1 =>
      'យើងប្រើប្រាស់ទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នកសម្រាប់គោលបំណងដូចខាងក្រោម៖';

  @override
  String get privacyPolicySection2Point2 => 'ក) ប្រតិបត្តិការវេទិកា';

  @override
  String get privacyPolicySection2Point3 =>
      'ដើម្បីបង្កើត និងគ្រប់គ្រងគណនីអ្នកទិញ ឬអ្នកលក់របស់អ្នក';

  @override
  String get privacyPolicySection2Point4 =>
      'ដើម្បីដំណើរការការបញ្ជាទិញ ការទូទាត់ និងការតាមដានការដឹកជញ្ជូន';

  @override
  String get privacyPolicySection2Point5 =>
      'ដើម្បីសម្រួលមុខងារសាកល្បងគំរូមុនទិញលក់ដុំ';

  @override
  String get privacyPolicySection2Point6 =>
      'ដើម្បីអនុញ្ញាតការបង្កើតវគ្គទិញរួម និងការប្រមូលការបញ្ជាទិញ';

  @override
  String get privacyPolicySection2Point7 => 'ខ) ទំនុកចិត្ត និងសុវត្ថិភាព';

  @override
  String get privacyPolicySection2Point8 =>
      'ដើម្បីផ្ទៀងផ្ទាត់អត្តសញ្ញាណសម្រាប់អ្នកផ្គត់ផ្គង់ និងអ្នកទិញ';

  @override
  String get privacyPolicySection2Point9 =>
      'ដើម្បីបញ្ជាក់ការដឹកជញ្ជូនតាមរយៈការស្កេនកូដ QR';

  @override
  String get privacyPolicySection2Point10 =>
      'ដើម្បីរកឃើញ និងទប់ស្កាត់ការទូទាត់ ឬការទាក់ទងក្រៅវេទិកា';

  @override
  String get privacyPolicySection2Point11 =>
      'ដើម្បីដំណើរការវិវាទ ការដាក់ស្នើភស្តុតាង និងសំណើសំណង';

  @override
  String get privacyPolicySection2Point12 => 'គ) ការដំណើរការទូទាត់ និងការវិភាគ';

  @override
  String get privacyPolicySection2Point13 =>
      'ដើម្បីដំណើរការការទូទាត់ដោយសុវត្ថិភាពតាមរយៈ Bakong និងអ្នកផ្តល់សេវាទូទាត់ផ្សេងទៀត';

  @override
  String get privacyPolicySection2Point14 =>
      'ដើម្បីរក្សាទុកប្រាក់ជាកក់រហូតដល់មានការបញ្ជាក់ការដឹកជញ្ជូន';

  @override
  String get privacyPolicySection2Point15 =>
      'ដើម្បីវិភាគទម្លាប់ការប្រើប្រាស់ និងកែលម្អមុខងារ និងដំណើរការកម្មវិធី';

  @override
  String get privacyPolicySection2Point16 =>
      'ដើម្បីធ្វើឱ្យផលិតផលដែលបានណែនាំ និងការស្វែងរកសមស្របទៅនឹងអ្នក';

  @override
  String get privacyPolicySection2Point17 => 'ឃ) ការជូនដំណឹងរុញ';

  @override
  String get privacyPolicySection2Point18 =>
      'ដើម្បីជូនដំណឹងអ្នកអំពីស្ថានភាពការបញ្ជាទិញ សារជជែក វឌ្ឍនភាពទិញរួម និងសកម្មភាពគណនីសំខាន់ៗ';

  @override
  String get privacyPolicySection2Point19 => 'ង) ការអនុលោមតាមច្បាប់';

  @override
  String get privacyPolicySection2Point20 =>
      'ដើម្បីអនុលោមតាមតម្រូវការច្បាប់ដែលពាក់ព័ន្ធ';

  @override
  String get privacyPolicySection2Point21 =>
      'ដើម្បីឆ្លើយតបទៅនឹងសំណើស្របច្បាប់ពីអាជ្ញាធរ';

  @override
  String get privacyPolicySection2Point22 => 'ច) ការផ្ទេរអាជីវកម្ម';

  @override
  String get privacyPolicySection2Point23 =>
      'ក្នុងករណីមានការរួមបញ្ចូល ការទិញយក ឬការលក់ទ្រព្យសកម្ម ព័ត៌មានអាចត្រូវបានផ្ទេរជាផ្នែកនៃទ្រព្យសកម្មអាជីវកម្ម ដោយអនុលោមតាមការការពារភាពឯកជនស្មើគ្នា';

  @override
  String get privacyPolicySection3Title => '៣. របៀបយើងចែករំលែកព័ត៌មានរបស់អ្នក';

  @override
  String get privacyPolicySection3Point1 =>
      'យើងមិនលក់ទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នកឡើយ។ យើងចែករំលែកព័ត៌មានក្នុងករណីដូចខាងក្រោមតែប៉ុណ្ណោះ៖';

  @override
  String get privacyPolicySection3Point2 => 'ក) រវាងអ្នកទិញ និងអ្នកលក់';

  @override
  String get privacyPolicySection3Point3 =>
      'ឈ្មោះអាជីវកម្ម ការវាយតម្លៃ និងបញ្ជីផលិតផលដែលចែករំលែកដើម្បីអនុញ្ញាតការជួញដូរ';

  @override
  String get privacyPolicySection3Point4 =>
      'សារជជែកចែករំលែកយ៉ាងតឹងរ៉ឹងតែរវាងអ្នកចូលរួមជជែកប៉ុណ្ណោះ';

  @override
  String get privacyPolicySection3Point5 => 'ខ) អ្នកផ្តល់សេវាទូទាត់';

  @override
  String get privacyPolicySection3Point6 =>
      'ទិន្នន័យប្រតិបត្តិការចែករំលែកជាមួយ Bakong និងច្រកទូទាត់ដែលបានអនុម័តផ្សេងទៀត ដើម្បីបំពេញការទូទាត់';

  @override
  String get privacyPolicySection3Point7 => 'គ) អ្នកផ្តល់សេវា';

  @override
  String get privacyPolicySection3Point8 =>
      'ការផ្ទុកលើពពក និងការផ្ទុកទិន្នន័យ (ហេដ្ឋារចនាសម្ព័ន្ធ Supabase)';

  @override
  String get privacyPolicySection3Point9 =>
      'សេវាវិភាគសម្រាប់កែលម្អដំណើរការកម្មវិធី និងបទពិសោធន៍អ្នកប្រើប្រាស់';

  @override
  String get privacyPolicySection3Point10 => 'ឃ) តម្រូវការច្បាប់';

  @override
  String get privacyPolicySection3Point11 => 'នៅពេលតម្រូវដោយច្បាប់ដែលពាក់ព័ន្ធ';

  @override
  String get privacyPolicySection3Point12 =>
      'ដើម្បីការពារសិទ្ធិស្របច្បាប់របស់ Bosdom ឬស៊ើបអង្កេតការក្លែងបន្លំ';

  @override
  String get privacyPolicySection3Point13 => 'ង) ការផ្ទេរអាជីវកម្ម';

  @override
  String get privacyPolicySection3Point14 =>
      'ក្នុងករណីមានការរួមបញ្ចូល ការទិញយក ឬការរៀបចំរចនាសម្ព័ន្ធឡើងវិញរបស់ Bosdom ទិន្នន័យអ្នកប្រើប្រាស់អាចត្រូវបានផ្ទេរដោយមានការប្តេជ្ញាការពារភាពឯកជនស្មើគ្នា';

  @override
  String get privacyPolicySection4Title => '៤. ការផ្ទុក និងសុវត្ថិភាពទិន្នន័យ';

  @override
  String get privacyPolicySection4Point1 =>
      'ទិន្នន័យរបស់អ្នកត្រូវបានផ្ទុកដោយសុវត្ថិភាពដោយប្រើហេដ្ឋារចនាសម្ព័ន្ធ Supabase ដែលផ្តល់៖';

  @override
  String get privacyPolicySection4Point2 =>
      'ការអ៊ិនគ្រីបទិន្នន័យក្នុងការបញ្ជូន (TLS/SSL) និងនៅពេលផ្ទុក';

  @override
  String get privacyPolicySection4Point3 =>
      'ការផ្ទៀងផ្ទាត់ និងការគ្រប់គ្រងសម័យប្រើប្រាស់ដោយសុវត្ថិភាព';

  @override
  String get privacyPolicySection4Point4 =>
      'ការគ្រប់គ្រងសិទ្ធិចូលប្រើ និងការត្រួតពិនិត្យសុវត្ថិភាព ព្រមទាំងវាយតម្លៃភាពងាយរងគ្រោះជាប្រចាំ';

  @override
  String get privacyPolicySection4Point5 =>
      'ព័ត៌មានការទូទាត់ប្រាក់ជាកក់ត្រូវបានការពារដោយប្រើស្តង់ដារច្រកទូទាត់ដែលអនុលោមតាម PCI។';

  @override
  String get privacyPolicySection4Point6 =>
      'ការសន្ទនាជជែក និងភស្តុតាងវិវាទត្រូវបានអ៊ិនគ្រីប និងកំណត់សិទ្ធិចូលប្រើសម្រាប់តែភាគីពាក់ព័ន្ធប៉ុណ្ណោះ។';

  @override
  String get privacyPolicySection4Point7 =>
      'ទោះបីជាយើងអនុវត្តវិធានការសុវត្ថិភាពតាមស្តង់ដារឧស្សាហកម្មក៏ដោយ គ្មានវិធីនៃការបញ្ជូន ឬការផ្ទុកតាមអេឡិចត្រូនិកណាមួយមានសុវត្ថិភាព ១០០% ឡើយ។';

  @override
  String get privacyPolicySection5Title => '៥. រយៈពេលរក្សាទុកទិន្នន័យ';

  @override
  String get privacyPolicySection5Point1 =>
      'យើងរក្សាទុកទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នកតែក្នុងរយៈពេលចាំបាច់ដើម្បីបំពេញគោលបំណងដែលបានរៀបរាប់ក្នុងគោលការណ៍នេះប៉ុណ្ណោះ៖';

  @override
  String get privacyPolicySection5Point2 =>
      'ទិន្នន័យគណនី៖ រក្សាទុកខណៈពេលគណនីរបស់អ្នកនៅសកម្ម និងរហូតដល់ ១២ ខែក្រោយការលុប';

  @override
  String get privacyPolicySection5Point3 =>
      'កំណត់ត្រាប្រតិបត្តិការ៖ រក្សាទុករយៈពេល ៥ ឆ្នាំសម្រាប់គណនេយ្យ និងការអនុលោមតាមច្បាប់';

  @override
  String get privacyPolicySection5Point4 => 'សារជជែក៖ រក្សាទុករយៈពេល ១២ ខែ';

  @override
  String get privacyPolicySection5Point5 =>
      'ភស្តុតាងវិវាទ៖ រក្សាទុករយៈពេល ១២ ខែក្រោយពេលដោះស្រាយ';

  @override
  String get privacyPolicySection5Point6 =>
      'អ្នកអាចស្នើសុំលុបគណនីនៅពេលណាមួយដោយទាក់ទងផ្នែកជំនួយ ឬប្រើមុខងារជំនួយក្នុងកម្មវិធី។';

  @override
  String get privacyPolicySection6Title => '៦. សិទ្ធិភាពឯកជនរបស់អ្នក';

  @override
  String get privacyPolicySection6Point1 =>
      'ក្នុងនាមជាអ្នកប្រើប្រាស់ Bosdom អ្នកមានសិទ្ធិ៖';

  @override
  String get privacyPolicySection6Point2 =>
      'ចូលមើល៖ ស្នើសុំច្បាប់ចម្លងទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នកដែលយើងកាន់កាប់';

  @override
  String get privacyPolicySection6Point3 =>
      'កែតម្រូវ៖ ធ្វើបច្ចុប្បន្នភាពព័ត៌មានមិនត្រឹមត្រូវ ឬហួសសម័យ';

  @override
  String get privacyPolicySection6Point4 =>
      'លុប៖ ស្នើសុំលុបទិន្នន័យផ្ទាល់ខ្លួនរបស់អ្នក ដោយអនុលោមតាមតម្រូវការរក្សាទុកតាមច្បាប់';

  @override
  String get privacyPolicySection6Point5 =>
      'ការផ្ទេរទិន្នន័យ៖ ស្នើសុំទិន្នន័យរបស់អ្នកជាទម្រង់ដែលអានបានដោយម៉ាស៊ីន';

  @override
  String get privacyPolicySection6Point6 =>
      'ចំណូលចិត្តការជូនដំណឹង៖ គ្រប់គ្រងការកំណត់ការជូនដំណឹងក្នុងកម្មវិធី';

  @override
  String get privacyPolicySection6Point7 =>
      'ដកខ្លួន៖ ដកខ្លួនចេញពីការទំនាក់ទំនងទីផ្សារនៅពេលណាមួយ';

  @override
  String get privacyPolicySection6Point8 =>
      'ដើម្បីអនុវត្តសិទ្ធិទាំងនេះ សូមទាក់ទងមកយើងខ្ញុំតាមអ៊ីមែល privacy@bosdom.com ឬតាមរយៈផ្នែកជំនួយក្នុងកម្មវិធី។';

  @override
  String get privacyPolicySection7Title => '៧. ភាពឯកជននៃការជជែក និងទំនាក់ទំនង';

  @override
  String get privacyPolicySection7Point1 =>
      'សារជជែកទាំងអស់ក្នុងកម្មវិធីត្រូវបានផ្ទុកដោយសុវត្ថិភាព និងអាចចូលមើលបានតែដោយអ្នកចូលរួមក្នុងការសន្ទនាប៉ុណ្ណោះ។';

  @override
  String get privacyPolicySection7Point2 =>
      'Bosdom ត្រួតពិនិត្យមាតិកាជជែកដោយស្វ័យប្រវត្តិសម្រាប់តែគោលបំណងរកឃើញការទាក់ទងក្រៅវេទិកា និងការទប់ស្កាត់ការក្លែងបន្លំប៉ុណ្ណោះ។';

  @override
  String get privacyPolicySection7Point3 =>
      'សារដែលត្រូវបានដាក់ទង់អាចត្រូវបានត្រួតពិនិត្យដោយផ្ទាល់ដៃដោយក្រុមទំនុកចិត្ត និងសុវត្ថិភាពរបស់យើង។';

  @override
  String get privacyPolicySection7Point4 =>
      'ការស្នើសុំព័ត៌មានទាក់ទងផ្ទាល់តាមរយៈការជជែកអាចនាំឱ្យមានការដាក់កំហិត ឬហាមឃាត់គណនី ដូចមានចែងក្នុងលក្ខខណ្ឌប្រើប្រាស់របស់យើង។';

  @override
  String get privacyPolicySection8Title => '៨. ភាពឯកជនរបស់កុមារ';

  @override
  String get privacyPolicySection8Point1 =>
      'Bosdom ជាទីផ្សារលក់ដុំបែប B2B ដែលមានបំណងសម្រាប់អ្នកជំនួញដែលបានផ្ទៀងផ្ទាត់ដែលមានអាយុ ១៨ ឆ្នាំឡើងទៅ។ យើងមិនប្រមូលទិន្នន័យពីអនីតិជនដោយចេតនាឡើយ។';

  @override
  String get privacyPolicySection9Title => '៩. ការផ្លាស់ប្តូរគោលការណ៍នេះ';

  @override
  String get privacyPolicySection9Point1 =>
      'យើងអាចធ្វើបច្ចុប្បន្នភាពគោលការណ៍ភាពឯកជននេះជាទៀងទាត់ ដើម្បីឆ្លុះបញ្ចាំងពីការផ្លាស់ប្តូរការអនុវត្ត តម្រូវការច្បាប់ ឬមុខងារវេទិកា។ ការផ្លាស់ប្តូរសំខាន់ៗនឹងត្រូវជូនដំណឹងតាមរយៈ៖';

  @override
  String get privacyPolicySection9Point2 =>
      'ការជូនដំណឹងគួរឱ្យកត់សម្គាល់ក្នុងកម្មវិធី';

  @override
  String get privacyPolicySection9Point3 =>
      'ការជូនដំណឹងតាមអ៊ីមែលទៅកាន់អ្នកប្រើប្រាស់ដែលបានចុះឈ្មោះ';

  @override
  String get privacyPolicySection9Point4 =>
      'កាលបរិច្ឆេទ \"ធ្វើបច្ចុប្បន្នភាពចុងក្រោយ\" ដែលបានធ្វើបច្ចុប្បន្នភាព';

  @override
  String get privacyPolicyContactTitle => 'ទាក់ទងមកយើងខ្ញុំ';

  @override
  String get privacyPolicyContactIntro =>
      'សម្រាប់សំណួរ ឬកង្វល់ទាក់ទងនឹងភាពឯកជន សូមទាក់ទង៖';

  @override
  String get privacyPolicyContactEmail => 'privacy@bosdom.com';

  @override
  String get privacyPolicyContactInApp =>
      'ក្នុងកម្មវិធី៖ ជំនួយ និងរាយការណ៍បញ្ហា';

  @override
  String get privacyPolicyContactLocation => 'កម្ពុជា';

  @override
  String get aboutScreenTitle => 'អំពី Bosdom';

  @override
  String get aboutAppTagline =>
      'ទីផ្សារជំនឿទុកចិត្តលក់ដុំ B2B ស្វ័យប្រវត្តិ និងបណ្តាញទិញរួមសង្គម';

  @override
  String aboutVersionLabel(String version) {
    return 'កំណែ $version';
  }

  @override
  String get aboutMissionTitle => 'បេសកកម្មរបស់យើង';

  @override
  String get aboutMissionBody =>
      'Bosdom ភ្ជាប់អ្នកលក់រាយកម្ពុជាដែលបានផ្ទៀងផ្ទាត់ជាមួយអ្នកលក់ដុំដែលអាចទុកចិត្តបាន តាមរយៈប្រព័ន្ធអេកូឡូស៊ីលទិញឌីជីថលដ៏សុវត្ថិភាព ដែលមានលក្ខណៈពិសេសដូចជា ការសាកល្បងគំរូ ការទិញរួមសង្គម អេស្គ្រូស្វ័យប្រវត្តិ និងការជជែកភ្លាមៗ។';

  @override
  String get aboutWhyChooseTitle => 'ហេតុអ្វីជ្រើសរើស Bosdom?';

  @override
  String get aboutFeatureSampleTestingTitle => 'ការសាកល្បងគំរូ';

  @override
  String get aboutFeatureSampleTestingBody =>
      'សាកល្បងមុននឹងទិញច្រើន ដើម្បីធានាគុណភាព។';

  @override
  String get aboutFeatureCoBuyTitle => 'បណ្តាញទិញរួម';

  @override
  String get aboutFeatureCoBuyBody =>
      'ដាក់បញ្ចូលការបញ្ជាទិញ ដើម្បីទទួលបានតម្លៃបញ្ចុះតម្លៃដោយផ្ទាល់។';

  @override
  String get aboutFeatureEscrowTitle => 'ការការពារអេស្គ្រូ';

  @override
  String get aboutFeatureEscrowBody =>
      'ការទូទាត់ស្វ័យប្រវត្តិដ៏សុវត្ថិភាពនៅពេលដឹកជញ្ជូន។';

  @override
  String get aboutFeatureChatTitle => 'ជជែកភ្លាមៗ';

  @override
  String get aboutFeatureChatBody =>
      'ប៉ុស្តិ៍ទំនាក់ទំនងផ្ទាល់ជាមួយអ្នកផ្គត់ផ្គង់ភ្លាមៗ។';

  @override
  String get aboutOfferTitle => 'អ្វីដែលយើងផ្តល់ជូន';

  @override
  String get aboutOfferItem1 => 'ទីផ្សារលក់ដុំ';

  @override
  String get aboutOfferItem2 => 'គំរូតម្លៃតាមបរិមាណ';

  @override
  String get aboutOfferItem3 => 'ប្រព័ន្ធផ្ទៀងផ្ទាត់ QR ដ៏សុវត្ថិភាព';

  @override
  String get aboutOfferItem4 => 'ថតកម្មសិទ្ធិភស្តុតាងប្រឆាំងការបោកបញ្ឆោត';

  @override
  String get aboutOfferItem5 => 'តំណភ្ជាប់អញ្ជើញសង្គម';

  @override
  String get aboutOfferItem6 => 'ការជូនដំណឹងភ្លាមៗ';

  @override
  String get aboutCompanyInfoTitle => 'ព័ត៌មានក្រុមហ៊ុន';

  @override
  String get aboutCompanyHeadquartersLabel => 'ការិយាល័យកណ្តាល';

  @override
  String get aboutCompanyHeadquartersValue => 'ភ្នំពេញ កម្ពុជា';

  @override
  String get aboutCompanyEmailLabel => 'អ៊ីមែលទំនាក់ទំនង';

  @override
  String get aboutCompanyEmailValue => 'support@bosdom.com';

  @override
  String get aboutCompanyWebsiteLabel => 'គេហទំព័រ';

  @override
  String get aboutCompanyWebsiteValue => 'www.bosdom.com';

  @override
  String get aboutStoryTitle => 'រឿងរបស់យើង';

  @override
  String get aboutStoryBody =>
      'បង្កើតឡើងដើម្បីដោះស្រាយកង្វះទំនុកចិត្តនៅក្នុងខ្សែសង្វាក់ផ្គត់ផ្គង់លក់រាយ B2B របស់កម្ពុជា Bosdom ដាក់ឱ្យប្រើប្រាស់នូវប្រព័ន្ធអេកូឡូស៊ីលទិញឌីជីថលដ៏សុវត្ថិភាពឯករាជ្យ ដើម្បីផ្តល់អំណាចដល់ម្ចាស់អាជីវកម្មលក់រាយខ្នាតតូច និងមធ្យម។';

  @override
  String get aboutStatRetailers => 'អ្នកលក់រាយ';

  @override
  String get aboutStatSuppliers => 'អ្នកផ្គត់ផ្គង់';

  @override
  String get aboutStatSuccessRate => 'អត្រាជោគជ័យ';

  @override
  String get aboutValuesTitle => 'គុណតម្លៃរបស់យើង';

  @override
  String get aboutValueTrustTitle => 'ទំនុកចិត្ត និងតម្លាភាព';

  @override
  String get aboutValueRetailerFirstTitle => 'អ្នកលក់រាយជាមុន';

  @override
  String get aboutValueInnovationTitle => 'ការច្នៃប្រឌិត';

  @override
  String get aboutFooterCopyright =>
      '© 2024-2026 Bosdom។ រក្សាសិទ្ធិគ្រប់យ៉ាង។';

  @override
  String get variantSelectOptionsTitle => 'ជ្រើសរើសជម្រើស';

  @override
  String get variantSizeLabel => 'ទំហំ';

  @override
  String get variantColorLabel => 'ពណ៌';
}
