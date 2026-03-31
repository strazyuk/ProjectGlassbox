from typing import Generator
from app.db.session import AsyncSessionLocal

async def get_db() -> Generator:
    try:
        db = AsyncSessionLocal()
        yield db
    finally:
        await db.close()
