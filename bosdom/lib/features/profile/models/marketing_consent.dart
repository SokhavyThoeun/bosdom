class MarketingConsent {
  const MarketingConsent({required this.marketingEmails, this.consentedAt});

  factory MarketingConsent.fromJson(Map<String, dynamic> json) =>
      MarketingConsent(
        marketingEmails: json['marketing_emails'] as bool,
        consentedAt: json['consented_at'] as String?,
      );

  final bool marketingEmails;
  final String? consentedAt;

  Map<String, dynamic> toJson() => {
    'marketing_emails': marketingEmails,
    'consented_at': consentedAt,
  };

  MarketingConsent copyWith({bool? marketingEmails, String? consentedAt}) =>
      MarketingConsent(
        marketingEmails: marketingEmails ?? this.marketingEmails,
        consentedAt: consentedAt ?? this.consentedAt,
      );
}
