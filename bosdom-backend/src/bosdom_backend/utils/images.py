import uuid
from pathlib import Path

from fastapi import HTTPException, UploadFile
from PIL import Image, ImageOps

# Every photo-upload endpoint (listings, co-buy, reviews, avatars, shop logos,
# chat images) accepts these raster formats and re-encodes them to WebP
# server-side, so stored size doesn't depend on whatever format/resolution a
# phone camera happens to produce.
ALLOWED_IMAGE_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"}

# Quality 80 is libwebp's own recommended default for photos - visually
# near-lossless while typically cutting file size well below JPEG/PNG.
_WEBP_QUALITY = 80
# No UI in this app displays a photo larger than this, so anything bigger is
# downscaled instead of paying to store and transfer pixels nobody sees.
_MAX_DIMENSION = 2048


def save_image_as_webp(upload: UploadFile, dest_dir: Path, name_prefix: str) -> str:
    """Reads an uploaded image, re-encodes it as WebP, and writes it into
    dest_dir. Returns the generated filename (not a full path or URL)."""
    if (upload.content_type or "") not in ALLOWED_IMAGE_CONTENT_TYPES:
        raise HTTPException(status_code=400, detail="Unsupported image type")

    try:
        image = Image.open(upload.file)
        image.load()
    except Exception as exc:
        raise HTTPException(status_code=400, detail="Invalid image file") from exc

    image = ImageOps.exif_transpose(image) or image
    if image.mode not in ("RGB", "RGBA"):
        image = image.convert("RGBA" if "A" in image.getbands() else "RGB")

    if image.width > _MAX_DIMENSION or image.height > _MAX_DIMENSION:
        image.thumbnail((_MAX_DIMENSION, _MAX_DIMENSION), Image.Resampling.LANCZOS)

    dest_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{name_prefix}-{uuid.uuid4().hex[:8]}.webp"
    image.save(dest_dir / filename, format="WEBP", quality=_WEBP_QUALITY, method=6)
    return filename
