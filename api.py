"""Minimal FastAPI adapter for deterministic inference."""
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from typing import Optional
from ml.inference import recommend_schemes

app = FastAPI(title="ArthSathi Scheme Recommendations", version="4.0")

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

@app.post("/api/recommendations")
def recommendations(request: RecommendationRequest, top_k: int = Query(default=10, ge=0, le=100)):
    try:
        payload = request.model_dump() if hasattr(request, "model_dump") else request.dict()
        return recommend_schemes(payload, top_k=top_k)
    except (ValueError, TypeError) as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
