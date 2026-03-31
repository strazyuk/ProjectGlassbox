from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Any
from app.crud.user import user as user_crud
from app.schemas.user import User, UserCreate
from app.api.deps import get_db

router = APIRouter()

@router.post("/", response_model=User)
async def create_user(
    *,
    db: AsyncSession = Depends(get_db),
    user_in: UserCreate
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
