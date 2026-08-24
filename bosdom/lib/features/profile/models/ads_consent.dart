class AdsConsent {
  const AdsConsent({
    required this.adsEnabled,
    required this.browsingData,
    required this.purchaseHistory,
  });

  factory AdsConsent.fromJson(Map<String, dynamic> json) => AdsConsent(
    adsEnabled: json['ads_enabled'] as bool,
    browsingData: json['browsing_data'] as bool,
    purchaseHistory: json['purchase_history'] as bool,
  );

  final bool adsEnabled;
  final bool browsingData;
  final bool purchaseHistory;

  Map<String, dynamic> toJson() => {
    'ads_enabled': adsEnabled,
    'browsing_data': browsingData,
    'purchase_history': purchaseHistory,
  };

  AdsConsent copyWith({
    bool? adsEnabled,
    bool? browsingData,
    bool? purchaseHistory,
  }) => AdsConsent(
    adsEnabled: adsEnabled ?? this.adsEnabled,
    browsingData: browsingData ?? this.browsingData,
    purchaseHistory: purchaseHistory ?? this.purchaseHistory,
  );
}
