"""Production inference flow for deterministic scheme recommendations."""
from pathlib import Path
import math

from .pipeline import load_scheme_data, validate_scheme_data
from .recommender import BeneficiaryProfile, evaluate_scheme
from .models import StructuredSimilarityRanker
from .relevance import evaluate_relevance

DEFAULT_SCHEME_PATH = Path(__file__).resolve().parents[1] / "data" / "schemes_master.csv"

def _safe(value):
    if value is None or (isinstance(value, float) and (math.isnan(value) or math.isinf(value))): return None
    if hasattr(value, "item"): return _safe(value.item())
    return value

def _profile_dict(profile):
    p = profile if isinstance(profile, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(profile)
    return {name: _safe(getattr(p, name)) for name in p.__dataclass_fields__}

def recommend_schemes(profile, top_k=10, data_path=None):
    if not isinstance(top_k, int) or top_k < 0: raise ValueError("top_k must be a non-negative integer")
    frame = load_scheme_data(data_path or DEFAULT_SCHEME_PATH)
    validate_scheme_data(frame)
    ranker = StructuredSimilarityRanker(top_k=len(frame)).fit(frame)
    ranked = ranker.rank(profile, top_k=len(frame))
    by_id = {str(row["scheme_id"]): row for _, row in frame.iterrows()}
    results = []
    for _, ranked_row in ranked.iterrows():
        row = by_id[str(ranked_row["scheme_id"])]
        result = evaluate_scheme(profile, row)
        if result["eligibility_status"] == "criteria_not_met": continue
        relevance = evaluate_relevance(profile, row)
        result["relevance_score"] = relevance["relevance_score"]
        result["ranking_score"] = round(result["compatibility_score"] * result["evidence_coverage"] * result["relevance_score"] / 10000, 2)
        result["reasons"].extend(relevance["relevance_reasons"])
        result.update({k: _safe(row.get(k)) for k in ("source_reference", "source_name", "source_url")})
        results.append({k: _safe(v) for k, v in result.items()})
    return {"profile": _profile_dict(profile), "results": results[:top_k], "total_candidates": len(frame)}
