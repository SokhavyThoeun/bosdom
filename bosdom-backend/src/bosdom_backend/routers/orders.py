from datetime import datetime

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import OrderReport

router = APIRouter(prefix="/orders", tags=["orders"])


class ReportRequest(BaseModel):
    reason: str
    note: str = ""


class ReportOut(BaseModel):
    id: str
    order_id: str
    reason: str
    note: str
    created_at: datetime

    model_config = {"from_attributes": True}


@router.post("/{order_id}/report", response_model=ReportOut)
def report_order(order_id: str, payload: ReportRequest, db: Session = Depends(get_db)) -> OrderReport:
    report = OrderReport(order_id=order_id, reason=payload.reason, note=payload.note)
    db.add(report)
    db.commit()
    db.refresh(report)
    return report
