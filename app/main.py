"""Điểm khởi chạy API. Chạy: uvicorn app.main:app --reload"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models  # noqa: F401
from .core import Base, engine
from .routers import admin, attendance, auth

Base.metadata.create_all(bind=engine)

app = FastAPI(title="tuonghoangthien-attendance-api — Chấm công nhân viên", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

app.include_router(auth.router)
app.include_router(admin.router)
app.include_router(attendance.router)
app.include_router(attendance.records_router)


@app.get("/health", tags=["Hệ thống"])
def health():
    return {"status": "ok"}
