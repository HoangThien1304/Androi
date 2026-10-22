"""Quản trị (chỉ admin): CRUD phòng ban, ca làm việc, nhân viên; phân quyền người dùng."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..core import get_db, get_or_404, require_roles
from ..models import Department, Employee, Shift, User
from ..schemas import (DepartmentIn, DepartmentOut, EmployeeIn, EmployeeOut, RoleIn,
                       ShiftIn, ShiftOut, UserOut)

router = APIRouter(prefix="/admin", tags=["Quản trị"],
                   dependencies=[Depends(require_roles("admin"))])


def _commit(db: Session, conflict_msg: str) -> None:
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, conflict_msg)


def make_crud(resource: str, model, schema_in, schema_out):
    """Tạo 5 endpoint CRUD (danh sách, chi tiết, thêm, sửa, xóa) cho một bảng."""

    @router.get(f"/{resource}", response_model=list[schema_out])
    def list_items(db: Session = Depends(get_db)):
        return db.query(model).order_by(model.id).all()

    @router.get(f"/{resource}/{{item_id}}", response_model=schema_out)
    def get_item(item_id: int, db: Session = Depends(get_db)):
        return get_or_404(db, model, item_id)

    @router.post(f"/{resource}", response_model=schema_out, status_code=201)
    def create_item(body: schema_in, db: Session = Depends(get_db)):
        obj = model(**body.model_dump())
        db.add(obj)
        _commit(db, "Dữ liệu bị trùng hoặc không hợp lệ")
        db.refresh(obj)
        return obj

    @router.put(f"/{resource}/{{item_id}}", response_model=schema_out)
    def update_item(item_id: int, body: schema_in, db: Session = Depends(get_db)):
        obj = get_or_404(db, model, item_id)
        for key, value in body.model_dump().items():
            setattr(obj, key, value)
        _commit(db, "Dữ liệu bị trùng hoặc không hợp lệ")
        db.refresh(obj)
        return obj

    @router.delete(f"/{resource}/{{item_id}}", status_code=204)
    def delete_item(item_id: int, db: Session = Depends(get_db)):
        db.delete(get_or_404(db, model, item_id))
        _commit(db, "Không thể xóa vì còn dữ liệu liên quan")


make_crud("departments", Department, DepartmentIn, DepartmentOut)
make_crud("shifts", Shift, ShiftIn, ShiftOut)
make_crud("employees", Employee, EmployeeIn, EmployeeOut)


@router.get("/users", response_model=list[UserOut])
def list_users(db: Session = Depends(get_db)):
    return db.query(User).order_by(User.id).all()


@router.patch("/users/{user_id}/role", response_model=UserOut)
def set_role(user_id: int, body: RoleIn, db: Session = Depends(get_db)):
    """Phân quyền: đổi vai trò admin / employee / customer."""
    user = get_or_404(db, User, user_id)
    user.role = body.role
    db.commit()
    db.refresh(user)
    return user
