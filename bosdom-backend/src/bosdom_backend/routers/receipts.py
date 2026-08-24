import io

from fastapi import APIRouter, Response
from fpdf import FPDF
from pydantic import BaseModel, Field

router = APIRouter(prefix="/receipts", tags=["receipts"])


class ReceiptItem(BaseModel):
    name: str
    qty_label: str
    line_total: float


class ReceiptRequest(BaseModel):
    order_id: str
    date: str
    status: str
    items: list[ReceiptItem]
    shipping_name: str
    shipping_address: str
    shipping_phone: str
    subtotal: float
    discount: float = 0
    shipping_fee: float = 0
    shipping_fee_label: str = "Free"
    total: float = Field(gt=0)


def _build_receipt_pdf(receipt: ReceiptRequest) -> bytes:
    pdf = FPDF(format="A4")
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()

    pdf.set_font("Helvetica", "B", 18)
    pdf.set_text_color(155, 44, 44)
    pdf.cell(0, 10, "Bosdom", new_x="LMARGIN", new_y="NEXT")

    pdf.set_font("Helvetica", "", 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, f"Order #{receipt.order_id}", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(
        0,
        6,
        f"Placed on {receipt.date}  -  Status: {receipt.status}",
        new_x="LMARGIN",
        new_y="NEXT",
    )
    pdf.ln(4)

    pdf.set_font("Helvetica", "B", 12)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(0, 8, "Items Ordered", new_x="LMARGIN", new_y="NEXT")
    pdf.set_draw_color(210, 210, 210)
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + 180, pdf.get_y())
    pdf.ln(2)

    pdf.set_font("Helvetica", "", 10)
    for item in receipt.items:
        pdf.set_text_color(0, 0, 0)
        pdf.cell(130, 6, item.name, new_x="RIGHT", new_y="TOP")
        pdf.cell(50, 6, f"${item.line_total:,.2f}", align="R", new_x="LMARGIN", new_y="NEXT")
        pdf.set_text_color(110, 110, 110)
        pdf.set_font("Helvetica", "", 9)
        pdf.cell(0, 5, item.qty_label, new_x="LMARGIN", new_y="NEXT")
        pdf.set_font("Helvetica", "", 10)
        pdf.ln(2)

    pdf.ln(3)
    pdf.set_font("Helvetica", "B", 12)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(0, 8, "Shipping & Delivery", new_x="LMARGIN", new_y="NEXT")
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + 180, pdf.get_y())
    pdf.ln(2)
    pdf.set_font("Helvetica", "B", 10)
    pdf.cell(0, 6, receipt.shipping_name, new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 10)
    pdf.multi_cell(0, 6, receipt.shipping_address, new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 6, f"Phone: {receipt.shipping_phone}", new_x="LMARGIN", new_y="NEXT")

    pdf.ln(3)
    pdf.set_font("Helvetica", "B", 12)
    pdf.cell(0, 8, "Payment Summary", new_x="LMARGIN", new_y="NEXT")
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + 180, pdf.get_y())
    pdf.ln(2)

    pdf.set_font("Helvetica", "", 10)
    pdf.cell(140, 6, "Subtotal", new_x="RIGHT", new_y="TOP")
    pdf.cell(40, 6, f"${receipt.subtotal:,.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

    if receipt.discount > 0:
        pdf.cell(140, 6, "Wholesale Discount", new_x="RIGHT", new_y="TOP")
        pdf.cell(
            40,
            6,
            f"-${receipt.discount:,.2f}",
            align="R",
            new_x="LMARGIN",
            new_y="NEXT",
        )

    pdf.cell(140, 6, "Shipping Fee", new_x="RIGHT", new_y="TOP")
    pdf.cell(
        40, 6, receipt.shipping_fee_label, align="R", new_x="LMARGIN", new_y="NEXT"
    )

    pdf.ln(2)
    pdf.set_draw_color(0, 0, 0)
    pdf.line(pdf.get_x(), pdf.get_y(), pdf.get_x() + 180, pdf.get_y())
    pdf.ln(2)

    pdf.set_font("Helvetica", "B", 13)
    pdf.set_text_color(155, 44, 44)
    pdf.cell(140, 9, "Total Amount", new_x="RIGHT", new_y="TOP")
    pdf.cell(40, 9, f"${receipt.total:,.2f}", align="R", new_x="LMARGIN", new_y="NEXT")

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
