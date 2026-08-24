final _kOffPlatformKeywords = [
  'whatsapp',
  'telegram',
  'wechat',
  'viber',
  'line id',
  'zalo',
  'call me',
  'my number',
  'outside the app',
  'outside bosdom',
  'cash only',
  'bank transfer',
];

final _kPhoneNumberPattern = RegExp(r'(\+?\d[\d\-\s]{7,}\d)');

/// True when [text] looks like an attempt to move a deal off-platform:
/// sharing a phone number or naming a third-party contact channel.
bool detectsOffPlatformAttempt(String? text) {
  if (text == null || text.trim().isEmpty) return false;
  final lower = text.toLowerCase();
  if (_kOffPlatformKeywords.any(lower.contains)) return true;
  return _kPhoneNumberPattern.hasMatch(text);
}
