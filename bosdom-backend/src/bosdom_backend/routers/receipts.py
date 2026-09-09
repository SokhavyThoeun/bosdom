import io
from pathlib import Path

from fastapi import APIRouter, Response
from fpdf import FPDF
from pydantic import BaseModel, Field

router = APIRouter(prefix="/receipts", tags=["receipts"])

ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets"
LOGO_BADGE_PATH = ASSETS_DIR / "bosdom-logo-badge.png"
WATERMARK_PATH = ASSETS_DIR / "bosdom-logo-watermark.png"
BRAND_RED = (155, 44, 44)


class ReceiptItem(BaseModel):
    name: str
    qty_label: str
    line_total: float


class ReceiptRequest(BaseModel):
    order_id: str
    date: str
    items: list[ReceiptItem]
    shipping_name: str
    shipping_address: str
    shipping_phone: str
    delivery_method: str = "Standard Delivery"
    subtotal: float
    discount: float = 0
    discount_label: str = "Wholesale Discount"
    shipping_fee: float = 0
    shipping_fee_label: str = "Free"
    total: float = Field(gt=0)


def _build_receipt_pdf(receipt: ReceiptRequest) -> bytes:
    pdf = FPDF(format="A4")
    pdf.set_margins(18, 18, 18)
    pdf.set_auto_page_break(auto=True, margin=20)
    pdf.add_page()

    page_w = pdf.w
    page_h = pdf.h
    content_w = page_w - 36

    # Centered watermark logo, behind all content.
    if WATERMARK_PATH.exists():
        mark_w = 130
        pdf.image(
            str(WATERMARK_PATH),
            x=(page_w - mark_w) / 2,
            y=(page_h - mark_w) / 2,
            w=mark_w,
        )

    # Outer frame to give the receipt a printed, professional feel.
    pdf.set_draw_color(*BRAND_RED)
    pdf.set_line_width(0.6)
    pdf.rect(10, 10, page_w - 20, page_h - 20)
    pdf.set_line_width(0.2)

    header_top = 18
    logo_w = 20

    if LOGO_BADGE_PATH.exists():
        pdf.image(str(LOGO_BADGE_PATH), x=18, y=header_top, w=logo_w)

    text_x = 18 + logo_w + 6
    text_w = page_w - 18 - text_x

    pdf.set_xy(text_x, header_top + 1)
    pdf.set_font("Helvetica", "B", 18)
    pdf.set_text_color(*BRAND_RED)
    pdf.cell(text_w, 8, "BosDom", new_x="LEFT", new_y="NEXT")

    pdf.set_x(text_x)
    pdf.set_font("Helvetica", "", 9)
    pdf.set_text_color(150, 150, 150)
    pdf.cell(text_w, 5, "OFFICIAL RECEIPT", new_x="LMARGIN", new_y="NEXT")

    pdf.set_y(header_top + logo_w + 5)

    pdf.set_draw_color(210, 210, 210)
    pdf.line(18, pdf.get_y(), page_w - 18, pdf.get_y())
    pdf.ln(4)

    pdf.set_font("Helvetica", "", 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, f"Order #{receipt.order_id}", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, f"Placed on {receipt.date}", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)

    pdf.set_font("Helvetica", "B", 12)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(0, 8, "Items Ordered", new_x="LMARGIN", new_y="NEXT")
    pdf.set_draw_color(210, 210, 210)
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + content_w, pdf.get_y())
    pdf.ln(2)

    pdf.set_font("Helvetica", "", 10)
    for item in receipt.items:
        pdf.set_text_color(0, 0, 0)
        pdf.cell(content_w - 44, 6, item.name, new_x="RIGHT", new_y="TOP")
        pdf.cell(44, 6, f"${item.line_total:,.2f}", align="R", new_x="LMARGIN", new_y="NEXT")
        pdf.set_text_color(110, 110, 110)
        pdf.set_font("Helvetica", "", 9)
        pdf.cell(0, 5, item.qty_label, new_x="LMARGIN", new_y="NEXT")
        pdf.set_font("Helvetica", "", 10)
        pdf.ln(2)

    pdf.ln(3)
    pdf.set_font("Helvetica", "B", 12)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(0, 8, "Shipping & Delivery", new_x="LMARGIN", new_y="NEXT")
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + content_w, pdf.get_y())
    pdf.ln(2)
    pdf.set_font("Helvetica", "B", 10)
    pdf.cell(0, 6, receipt.shipping_name, new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    pdf.multi_cell(0, 6, receipt.shipping_address, new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, f"Phone: {receipt.shipping_phone}", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, f"Delivery Method: {receipt.delivery_method}", new_x="LMARGIN", new_y="NEXT")

    pdf.ln(3)
    pdf.set_font("Helvetica", "B", 12)
    pdf.cell(0, 8, "Payment Summary", new_x="LMARGIN", new_y="NEXT")
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + content_w, pdf.get_y())
    pdf.ln(2)

    pdf.set_font("Helvetica", "", 10)
    pdf.cell(content_w - 34, 6, "Subtotal", new_x="RIGHT", new_y="TOP")
    pdf.cell(34, 6, f"${receipt.subtotal:,.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

    if receipt.discount > 0:
        pdf.cell(content_w - 34, 6, receipt.discount_label, new_x="RIGHT", new_y="TOP")
        pdf.cell(
            34,
            6,
            f"-${receipt.discount:,.2f}",
            align="R",
            new_x="LMARGIN",
            new_y="NEXT",
        )

    pdf.cell(content_w - 34, 6, "Shipping Fee", new_x="RIGHT", new_y="TOP")
    pdf.cell(
        34, 6, receipt.shipping_fee_label, align="R", new_x="LMARGIN", new_y="NEXT"
    )

    pdf.ln(2)
    pdf.set_draw_color(0, 0, 0)
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + content_w, pdf.get_y())
    pdf.ln(2)

    pdf.set_font("Helvetica", "B", 13)
    pdf.set_text_color(*BRAND_RED)
    pdf.cell(content_w - 34, 9, "Total Amount", new_x="RIGHT", new_y="TOP")
    pdf.cell(34, 9, f"${receipt.total:,.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

    return bytes(pdf.output())


@router.post("")
def create_receipt(receipt: ReceiptRequest) -> Response:
    pdf_bytes = _build_receipt_pdf(receipt)
    filename = f"receipt-{receipt.order_id}.pdf"
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
