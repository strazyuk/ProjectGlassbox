from fastapi import FastAPI, APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Any

from .database import settings, get_db
from .schemas import User, UserCreate
from .crud import user as user_crud

app = FastAPI(title=settings.PROJECT_NAME)


@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    # Prevent MIME-type sniffing
    response.headers["X-Content-Type-Options"] = "nosniff"
    # Prevent Clickjacking
    response.headers["X-Frame-Options"] = "DENY"
    # Harden Cross-Origin Resource Policy
    response.headers["Cross-Origin-Resource-Policy"] = "same-origin"
    # Address storable/cacheable content for sensitive API data
    if "Cache-Control" not in response.headers:
        response.headers["Cache-Control"] = (
            "no-store, no-cache, must-revalidate, max-age=0"
        )
    return response


api_router = APIRouter()


@api_router.post("/users/", response_model=User)
async def create_user(
    *, db: AsyncSession = Depends(get_db), user_in: UserCreate
) -> Any:
    """
    Create new user.
    """
    user = await user_crud.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system.",
        )
    return await user_crud.create(db, obj_in=user_in)


app.include_router(api_router, prefix="/api/v1", tags=["users"])


@app.get("/")
async def root():
    return {"message": f"Welcome to {settings.PROJECT_NAME}"}
