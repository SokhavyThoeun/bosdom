import io
import uuid

from fastapi import HTTPException, UploadFile
from PIL import Image, ImageOps
from pillow_heif import register_heif_opener

from .. import storage

# iPhones hand over HEIC when the picker doesn't force JPEG.
register_heif_opener()

# Every photo-upload endpoint (listings, co-buy, reviews, avatars, shop logos,
# chat images) accepts these raster formats and re-encodes them to WebP
# server-side, so stored size doesn't depend on whatever format/resolution a
# phone camera happens to produce.
ALLOWED_IMAGE_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"}

# Sources that are already lossy (camera JPEG/HEIC) get quality 92: visually
# indistinguishable from the original, still far smaller than JPEG/PNG.
_WEBP_QUALITY = 92
# Lossless sources (screenshots, logos, graphics) stay pixel-exact.
_LOSSLESS_FORMATS = {"PNG", "GIF", "BMP", "TIFF"}
# No UI in this app displays a photo larger than this, so anything bigger is
# downscaled instead of paying to store and transfer pixels nobody sees.
_MAX_DIMENSION = 2048


def encode_webp(data: bytes) -> bytes:
    """Re-encodes raw image bytes as WebP without visible quality loss.
    Raises ValueError if `data` isn't a readable image."""
    try:
        image: Image.Image = Image.open(io.BytesIO(data))
        image.load()
    except Exception as exc:
        raise ValueError("Invalid image file") from exc

    source_format = image.format or ""
    # Keep the colour profile, or wide-gamut (Display P3) iPhone photos
    # render washed out.
    icc_profile = image.info.get("icc_profile")
    has_exif = len(image.getexif()) > 0
    too_big = image.width > _MAX_DIMENSION or image.height > _MAX_DIMENSION

    # Already WebP and nothing to fix: keep the original bytes rather than
    # decoding and re-encoding (which would lose a generation of quality).
    # Anything with EXIF is re-encoded so orientation is applied and GPS
    # location etc. never gets published.
    if source_format == "WEBP" and not has_exif and not too_big:
        return data

    image = ImageOps.exif_transpose(image) or image
    if image.mode not in ("RGB", "RGBA"):
        image = image.convert("RGBA" if "A" in image.getbands() else "RGB")
    if too_big:
        image.thumbnail((_MAX_DIMENSION, _MAX_DIMENSION), Image.Resampling.LANCZOS)

    out = io.BytesIO()
    if source_format in _LOSSLESS_FORMATS:
        image.save(
            out, format="WEBP", lossless=True, quality=100, method=6, icc_profile=icc_profile
        )
    else:
        image.save(
            out, format="WEBP", quality=_WEBP_QUALITY, method=6, icc_profile=icc_profile
        )
    return out.getvalue()


def save_image_as_webp(upload: UploadFile, folder: str, name_prefix: str) -> str:
    """Re-encodes an uploaded image as WebP, stores it in the public bucket
    under `folder/`, and returns its public URL."""
    if (upload.content_type or "") not in ALLOWED_IMAGE_CONTENT_TYPES:
        raise HTTPException(status_code=400, detail="Unsupported image type")
    try:
        webp = encode_webp(upload.file.read())
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    filename = f"{name_prefix}-{uuid.uuid4().hex[:8]}.webp"
    return storage.upload_public(f"{folder}/{filename}", webp, "image/webp")
