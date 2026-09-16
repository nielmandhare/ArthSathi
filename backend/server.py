from fastapi import FastAPI, APIRouter, HTTPException
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import httpx
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import Any, List, Optional
import uuid
from datetime import datetime, timezone


ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection is optional; only the status routes require it.
mongo_url = os.environ.get('MONGO_URL')
_db_client = AsyncIOMotorClient(mongo_url) if mongo_url else None
db = _db_client[os.environ['DB_NAME']] if _db_client and os.environ.get('DB_NAME') else None

# Create the main app without a prefix
app = FastAPI()

ML_SERVICE_URL = os.environ.get("ML_SERVICE_URL", "").rstrip("/")
ML_SERVICE_TIMEOUT_SECONDS = float(os.environ.get("ML_SERVICE_TIMEOUT_SECONDS", "15"))

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")


# Define Models
class StatusCheck(BaseModel):
    model_config = ConfigDict(extra="ignore")  # Ignore MongoDB's _id field
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class StatusCheckCreate(BaseModel):
    client_name: str


class RecommendationRequest(BaseModel):
    age: Optional[float] = Field(default=None, ge=0)
    income: Optional[float] = Field(default=None, ge=0)
    location: Optional[str] = None
    social_category: Optional[str] = None
    education: Optional[str] = None
    business_type: Optional[str] = None
    loan_purpose: Optional[str] = None
    project_cost: Optional[float] = Field(default=None, ge=0)
    required_loan_amount: Optional[float] = Field(default=None, ge=0)


class RecommendationResponse(BaseModel):
    model_config = ConfigDict(extra="allow")

    profile: dict[str, Any]
    results: list[dict[str, Any]]
    total_candidates: int

# Add your routes to the router instead of directly to app
@api_router.get("/")
async def root():
    return {"message": "Hello World"}

@api_router.post("/status", response_model=StatusCheck)
async def create_status_check(input: StatusCheckCreate):
    if db is None:
        raise HTTPException(status_code=503, detail="Database not configured")
    status_dict = input.model_dump()
    status_obj = StatusCheck(**status_dict)
    
    # Convert to dict and serialize datetime to ISO string for MongoDB
    doc = status_obj.model_dump()
    doc['timestamp'] = doc['timestamp'].isoformat()
    
    _ = await db.status_checks.insert_one(doc)
    return status_obj

@api_router.get("/status", response_model=List[StatusCheck])
async def get_status_checks():
    if db is None:
        raise HTTPException(status_code=503, detail="Database not configured")
    # Exclude MongoDB's _id field from the query results
    status_checks = await db.status_checks.find({}, {"_id": 0}).to_list(1000)
    
    # Convert ISO string timestamps back to datetime objects
    for check in status_checks:
        if isinstance(check['timestamp'], str):
            check['timestamp'] = datetime.fromisoformat(check['timestamp'])
    
    return status_checks


@api_router.post("/recommendations", response_model=RecommendationResponse)
async def recommendations(input: RecommendationRequest):
    if not ML_SERVICE_URL:
        raise HTTPException(status_code=503, detail="ML recommendation service is not configured")

    payload = input.model_dump(exclude_none=False)
    try:
        async with httpx.AsyncClient(timeout=ML_SERVICE_TIMEOUT_SECONDS) as client:
            response = await client.post(f"{ML_SERVICE_URL}/api/recommendations", json=payload)
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="ML recommendation service timed out") from exc
    except httpx.RequestError as exc:
        raise HTTPException(status_code=503, detail="ML recommendation service is unavailable") from exc

    if response.status_code >= 400:
        detail = "ML recommendation service returned an error"
        try:
            upstream_detail = response.json().get("detail")
            if upstream_detail:
                detail = str(upstream_detail)
        except (ValueError, TypeError):
            pass
        status = 422 if 400 <= response.status_code < 500 else 502
        raise HTTPException(status_code=status, detail=detail)

    try:
        data = response.json()
        return RecommendationResponse.model_validate(data)
    except (ValueError, TypeError) as exc:
        raise HTTPException(status_code=502, detail="ML recommendation service returned malformed data") from exc

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    if _db_client:
        _db_client.close()
