"""Deterministic, manually curated quality benchmark for recommendations.

This is a heuristic retrieval evaluation, not supervised evaluation and not a
measure of approval, selection, or model accuracy.
"""
from pathlib import Path
import time

from .pipeline import load_scheme_data, validate_scheme_data
from .models import StructuredSimilarityRanker

DEFAULT_PATH = Path(__file__).resolve().parents[1] / "data" / "schemes_master.csv"


def _profile(social, business, purpose, **overrides):
    value = {"age": 25, "income": 300000, "location": "Maharashtra",
             "social_category": social, "education": "Graduate",
             "business_type": business, "loan_purpose": purpose,
             "project_cost": 500000, "required_loan_amount": 300000}
    value.update(overrides)
    return value


BENCHMARK_CASES = [
    {"case_id": "sc_education", "profile": _profile("SC", "Student", "Education"), "expected_domain": "education", "expected_target": "matched"},
    {"case_id": "sc_agriculture", "profile": _profile("SC", "Agriculture", "Agriculture"), "expected_domain": "agriculture", "expected_target": "matched"},
    {"case_id": "sc_transport", "profile": _profile("SC", "Transport", "Transport"), "expected_domain": "transport", "expected_target": "matched"},
    {"case_id": "sc_business", "profile": _profile("SC", "Small Business", "Business"), "expected_domain": "business", "expected_target": "matched"},
    {"case_id": "st_agriculture", "profile": _profile("ST", "Agriculture", "Agriculture"), "expected_domain": "agriculture", "expected_target": "matched"},
    {"case_id": "general_business", "profile": _profile("General", "Small Business", "Business"), "expected_domain": "business", "expected_target": "not_matched_or_unknown"},
    {"case_id": "underspecified", "profile": _profile(None, None, None, age=None, income=None, location=None, education=None, business_type=None, loan_purpose=None, project_cost=None, required_loan_amount=None), "expected_domain": None, "expected_target": "not_matched_or_unknown"},
    {"case_id": "missing_purpose", "profile": _profile("SC", "Small Business", None, loan_purpose=None), "expected_domain": "business", "expected_target": "matched"},
    {"case_id": "invalid_amount", "profile": _profile("ST", "Transport", "Transport", required_loan_amount=-1), "expected_domain": "transport", "expected_target": "matched"},
]


def _domain_hit(row, expected):
    if expected is None:
        return float(row.get("relevance_score", 0)) == 0
    groups = set(row.get("matched_relevance_groups", []))
    return ((expected == "education" and "education_domain" in groups) or
            (expected in {"agriculture", "transport", "business"} and "business_domain" in groups))


def _target_hit(value, expected):
    return value == "matched" if expected == "matched" else value in {"not_matched", "unknown"}


def evaluate_benchmark(data_path=None, cases=None):
    """Return JSON-safe per-case and aggregate heuristic benchmark results."""
    frame = load_scheme_data(data_path or DEFAULT_PATH)
    validate_scheme_data(frame)
    ranker = StructuredSimilarityRanker(top_k=5).fit(frame)
    rows = []
    started = time.perf_counter()
    for case in cases or BENCHMARK_CASES:
        ranked = ranker.rank(case["profile"], top_k=5)
        records = ranked.to_dict("records")
        domain_hits = [_domain_hit(record, case["expected_domain"]) for record in records]
        target_hits = [_target_hit(record.get("target_group_match"), case["expected_target"]) for record in records]
        consistency = all(record.get("relevance_tier") in {"unrelated", "weakly_relevant", "relevant", "strongly_relevant"} and 0 <= float(record.get("relevance_score", 0)) <= 100 for record in records)
        rows.append({"case_id": case["case_id"], "expected_domain": case["expected_domain"],
                     "top_scheme_ids": [str(r.get("scheme_id")) for r in records],
                     "top_1_domain_hit": bool(domain_hits[:1] and domain_hits[0]),
                     "top_3_domain_hit": any(domain_hits[:3]), "top_5_domain_hit": any(domain_hits),
                     "target_group_hit": any(target_hits),
                     "unrelated_suppressed": all(r.get("relevance_tier") != "strongly_relevant" for r in records) if case["expected_domain"] is None else True,
                     "eligibility_statuses": [r.get("eligibility_status") for r in records],
                     "score_tier_consistent": consistency})
    elapsed = round(time.perf_counter() - started, 3)
    total = len(rows)
    return {"cases": rows, "aggregate": {
        "case_count": total,
        "top_1_domain_hit_rate": round(sum(r["top_1_domain_hit"] for r in rows) / total, 4),
        "top_3_domain_hit_rate": round(sum(r["top_3_domain_hit"] for r in rows) / total, 4),
        "top_5_domain_hit_rate": round(sum(r["top_5_domain_hit"] for r in rows) / total, 4),
        "target_group_result_rate": round(sum(r["target_group_hit"] for r in rows) / total, 4),
        "unrelated_suppression_rate": round(sum(r["unrelated_suppressed"] for r in rows) / total, 4),
        "score_tier_consistency_rate": round(sum(r["score_tier_consistent"] for r in rows) / total, 4),
        "elapsed_seconds": elapsed,
    }}
