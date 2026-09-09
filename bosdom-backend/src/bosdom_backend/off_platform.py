import re

# Mirrors bosdom/lib/features/chat/utils/off_platform_detector.dart — keep both in sync.
_OFF_PLATFORM_KEYWORDS = [
    "whatsapp",
    "telegram",
    "wechat",
    "viber",
    "line id",
    "zalo",
    "call me",
    "my number",
    "outside the app",
    "outside bosdom",
    "cash only",
    "bank transfer",
]

_PHONE_PATTERN = re.compile(r"(\+?\d[\d\-\s]{7,}\d)")


def detects_off_platform_attempt(text: str) -> bool:
    """True when `text` looks like an attempt to move a deal off-platform:
    sharing a phone number or naming a third-party contact channel."""
    stripped = text.strip()
    if not stripped:
        return False
    lower = stripped.lower()
    if any(keyword in lower for keyword in _OFF_PLATFORM_KEYWORDS):
        return True
    return bool(_PHONE_PATTERN.search(stripped))
