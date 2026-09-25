"""Supabase Storage for every user upload.

Render's disk is wiped on each deploy/restart, so nothing is written locally.
Two buckets:

- `media` (public): photos anyone in the app can see — listings, co-buy,
  shops, avatars, reviews, chat images, parcel/delivery photos. The DB stores
  the full public URL so clients load straight from Supabase's CDN.
- `private-media`: KYC documents and dispute evidence. The DB stores
  `/media/private/<path>`, which main.py redirects to a short-lived signed URL.
"""

import httpx

from .config import settings

PUBLIC_BUCKET = "media"
PRIVATE_BUCKET = "private-media"
PRIVATE_URL_PREFIX = "/media/private/"
_SIGNED_URL_SECONDS = 60 * 60
# Filenames are random, so an object never changes once written.
_CACHE_SECONDS = 60 * 60 * 24 * 365

_client = httpx.Client(timeout=60)


def _headers() -> dict[str, str]:
    key = settings.supabase_service_role_key
    return {"Authorization": f"Bearer {key}", "apikey": key}


def _api(path: str) -> str:
    return f"{settings.supabase_url.rstrip('/')}/storage/v1{path}"


def ensure_buckets() -> None:
    """Creates the two buckets if missing (no-op once they exist)."""
    for bucket, public in ((PUBLIC_BUCKET, True), (PRIVATE_BUCKET, False)):
        res = _client.get(_api(f"/bucket/{bucket}"), headers=_headers())
        if res.status_code == 200:
            continue
        res = _client.post(
            _api("/bucket"),
            headers=_headers(),
            json={"id": bucket, "name": bucket, "public": public},
        )
        # 409 = created concurrently by another worker.
        if res.status_code not in (200, 201, 409):
            res.raise_for_status()


def upload(bucket: str, path: str, data: bytes, content_type: str) -> None:
    res = _client.post(
        _api(f"/object/{bucket}/{path}"),
        headers={
            **_headers(),
            "Content-Type": content_type,
            "Cache-Control": f"max-age={_CACHE_SECONDS}",
            "x-upsert": "true",
        },
        content=data,
    )
    res.raise_for_status()


def upload_public(path: str, data: bytes, content_type: str) -> str:
    """Uploads to the public bucket and returns the URL to store in the DB."""
    upload(PUBLIC_BUCKET, path, data, content_type)
    return public_url(path)


def upload_private(path: str, data: bytes, content_type: str) -> str:
    """Uploads to the private bucket and returns the `/media/private/...`
    path to store in the DB."""
    upload(PRIVATE_BUCKET, path, data, content_type)
    return f"{PRIVATE_URL_PREFIX}{path}"


def public_url(path: str) -> str:
    return _api(f"/object/public/{PUBLIC_BUCKET}/{path}")


def signed_url(path: str) -> str:
    res = _client.post(
        _api(f"/object/sign/{PRIVATE_BUCKET}/{path}"),
        headers=_headers(),
        json={"expiresIn": _SIGNED_URL_SECONDS},
    )
    res.raise_for_status()
    return _api(res.json()["signedURL"])
