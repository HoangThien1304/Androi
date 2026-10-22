
"""Chấm công: nhân viên check-in/check-out; xác nhận đồng nghiệp (buddy check); admin CRUD lịch sử."""

from datetime import datetime, date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import true
from sqlalchemy.orm import Session

from ..core import get_db, get_or_404, require_roles
from ..models import AttendanceRecord, Employee, Shift
from ..schemas import AttendanceIn, AttendanceOut, BuddyConfirmIn


router = APIRouter(prefix="/attendance", tags=["Chấm công"])

records_router = APIRouter(
    prefix="/attendance/records",
    tags=["Lịch sử chấm công (admin)"],
    dependencies=[Depends(require_roles("admin"))],
)


def _active_shift(db: Session) -> Shift:
    """Lấy ca làm việc đang hoạt động, dùng chung cho cả công ty."""
    shift = (
        db.query(Shift)
        .filter(Shift.is_active == true())
        .first()
    )

    if shift is None:
        raise HTTPException(
            status_code=409,
            detail="Chưa có ca làm việc đang hoạt động",
        )

    return shift


def _my_employee(user, db: Session) -> Employee:
    """Lấy hồ sơ nhân viên liên kết với tài khoản hiện tại."""
    emp = (
        db.query(Employee)
        .filter(Employee.user_id == user.id)
        .first()
    )

    if emp is None:
        raise HTTPException(
            status_code=404,
            detail="Tài khoản này chưa được liên kết với hồ sơ nhân viên",
        )

    return emp


def _apply_rules(rec: AttendanceRecord, shift: Shift) -> None:
    """Tự tính ngày làm việc, đi muộn và về sớm theo ca cố định."""
    rec.work_date = rec.check_in.date()
    rec.is_late = rec.check_in.time() > shift.start_time
    rec.is_early_leave = (
        rec.check_out is not None
        and rec.check_out.time() < shift.end_time
    )


@router.post(
    "/check-in",
    response_model=AttendanceOut,
    status_code=201,
)
def check_in(
    user=Depends(require_roles("employee")),
    db: Session = Depends(get_db),
):
    """Nhân viên check-in."""
    emp = _my_employee(user, db)
    now = datetime.now()

    existing = (
        db.query(AttendanceRecord)
        .filter_by(employee_id=emp.id, work_date=now.date())
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=409,
            detail="Hôm nay bạn đã check-in",
        )

    shift = _active_shift(db)

    rec = AttendanceRecord(
        employee_id=emp.id,
        check_in=now,
        is_suspicious=True,
    )

    _apply_rules(rec, shift)

    db.add(rec)
    db.commit()
    db.refresh(rec)

    return rec


@router.post(
    "/check-out",
    response_model=AttendanceOut,
)
def check_out(
    user=Depends(require_roles("employee")),
    db: Session = Depends(get_db),
):
    """Nhân viên check-out."""
    emp = _my_employee(user, db)
    now = datetime.now()

    rec = (
        db.query(AttendanceRecord)
        .filter_by(employee_id=emp.id, work_date=now.date())
        .first()
    )

    if rec is None:
        raise HTTPException(
            status_code=409,
            detail="Hôm nay bạn chưa check-in",
        )

    if rec.check_out is not None:
        raise HTTPException(
            status_code=409,
            detail="Hôm nay bạn đã check-out",
        )

    shift = _active_shift(db)

    rec.check_out = now
    _apply_rules(rec, shift)

    db.commit()
    db.refresh(rec)

    return rec


@router.post(
    "/buddy-confirm",
    response_model=AttendanceOut,
)
def buddy_confirm(
    body: BuddyConfirmIn,
    user=Depends(require_roles("employee")),
    db: Session = Depends(get_db),
):
    """Xác nhận đồng nghiệp có mặt (Buddy Check - QR hoặc Bluetooth)."""
    emp = _my_employee(user, db)

    if (
        (
            body.buddy_employee_id is not None
            and body.buddy_employee_id != emp.id
        )
        or body.employee_id == emp.id
    ):
        raise HTTPException(
            status_code=403,
            detail="Thông tin xác nhận không hợp lệ",
        )

    rec = (
        db.query(AttendanceRecord)
        .filter_by(
            employee_id=body.employee_id,
            work_date=date.today(),
        )
        .first()
    )

    if rec is None:
        raise HTTPException(
            status_code=409,
            detail="Hãy check-in trước khi xác nhận đồng nghiệp",
        )

    rec.buddy_confirmed_by = emp.id
    rec.buddy_method = body.method
    rec.is_suspicious = False

    db.commit()
    db.refresh(rec)

    return rec


@router.get(
    "/me",
    response_model=list[AttendanceOut],
)
def my_history(
    user=Depends(require_roles("employee", "customer")),
    db: Session = Depends(get_db),
):
    """Xem lịch sử chấm công của tài khoản hiện tại."""
    emp = (
        db.query(Employee)
        .filter_by(user_id=user.id)
        .first()
    )

    if emp is None:
        if user.role == "customer":
            return []

        raise HTTPException(
            status_code=404,
            detail="Tài khoản này chưa được liên kết với hồ sơ nhân viên",
        )

    return (
        db.query(AttendanceRecord)
        .filter_by(employee_id=emp.id)
        .order_by(AttendanceRecord.check_in.desc())
        .all()
    )


# ---------- Admin: CRUD lịch sử chấm công ----------

@records_router.get(
    "",
    response_model=list[AttendanceOut],
)
def list_records(
    employee_id: int | None = None,
    db: Session = Depends(get_db),
):
    """Liệt kê lịch sử chấm công, có thể lọc theo nhân viên."""
    query = db.query(AttendanceRecord)

    if employee_id is not None:
        query = query.filter(
            AttendanceRecord.employee_id == employee_id
        )

    return query.order_by(
        AttendanceRecord.check_in.desc()
    ).all()


@records_router.get(
    "/{record_id}",
    response_model=AttendanceOut,
)
def get_record(
    record_id: int,
    db: Session = Depends(get_db),
):
    """Lấy một bản ghi chấm công."""
    return get_or_404(db, AttendanceRecord, record_id)


@records_router.post(
    "",
    response_model=AttendanceOut,
    status_code=201,
)
def create_record(
    body: AttendanceIn,
    db: Session = Depends(get_db),
):
    """Admin tạo bản ghi chấm công."""
    shift = _active_shift(db)

    rec = AttendanceRecord(**body.model_dump())
    _apply_rules(rec, shift)

    db.add(rec)
    db.commit()
    db.refresh(rec)

    return rec


@records_router.put(
    "/{record_id}",
    response_model=AttendanceOut,
)
def update_record(
    record_id: int,
    body: AttendanceIn,
    db: Session = Depends(get_db),
):
    """Admin cập nhật bản ghi chấm công."""
    rec = get_or_404(db, AttendanceRecord, record_id)

    for key, value in body.model_dump().items():
        setattr(rec, key, value)

    shift = _active_shift(db)
    _apply_rules(rec, shift)

    db.commit()
    db.refresh(rec)

    return rec


@records_router.delete(
    "/{record_id}",
    status_code=204,
)
def delete_record(
    record_id: int,
    db: Session = Depends(get_db),
):
    """Admin xóa bản ghi chấm công."""
    rec = get_or_404(db, AttendanceRecord, record_id)

    db.delete(rec)
    db.commit()
