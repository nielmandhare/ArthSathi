"""Deterministic, explainable scheme compatibility baseline.

This module performs structured compatibility checks only. ``match_score`` is
the percentage of evaluated criteria satisfied; it is not an approval
probability, confidence score, or prediction.
"""
from dataclasses import dataclass
import math
import os
import re
import pandas as pd

from .pipeline import load_scheme_data

STATUS_LIKELY = "likely_eligible"
STATUS_NOT_MET = "criteria_not_met"
STATUS_VERIFY = "further_verification_required"

@dataclass(frozen=True)
class BeneficiaryProfile:
    age: float | None = None
    income: float | None = None
    location: str | None = None
    social_category: str | None = None
    education: str | None = None
    business_type: str | None = None
    loan_purpose: str | None = None
    project_cost: float | None = None
    required_loan_amount: float | None = None

    @classmethod
    def from_mapping(cls, value):
        allowed = {f for f in cls.__dataclass_fields__}
        return cls(**{k: value.get(k) for k in allowed if k in value})

CRITERIA = ("age", "income", "location", "social_category", "education", "business_type", "loan_purpose", "project_cost", "loan_amount")

def _missing(value):
    return value is None or (isinstance(value, float) and math.isnan(value)) or (isinstance(value, str) and not value.strip())

def _number(value):
    if _missing(value): return None
    try: return float(value)
    except (TypeError, ValueError): return None

def _tokens(value):
    if _missing(value): return None
    text = str(value).strip()
    if text.upper() in {"ALL", "ANY", "ALL STATES", "ALL INDIA"}: return {"*"}
    return {re.sub(r"\s+", " ", x.strip().casefold()) for x in re.split(r"[,|;/]", text) if x.strip()}

def _contains(scheme_value, profile_value):
    allowed = _tokens(scheme_value)
    if allowed is None or _missing(profile_value): return None
    return "*" in allowed or str(profile_value).strip().casefold() in allowed

def _bounded(value, lower, upper):
    value, lower, upper = _number(value), _number(lower), _number(upper)
    if value is None or (lower is None and upper is None): return None
    return (lower is None or value >= lower) and (upper is None or value <= upper)

def _check(name, matched, reason, unmet, unknown, reasons):
    if matched is True: reasons.append(reason); return 1, False
    if matched is False: unmet.append(name); return 1, True
    reasons.append(f"{name.replace('_', ' ').capitalize()} could not be verified from available scheme data")
    unknown.append(name); return 0, False

def evaluate_scheme(profile, scheme):
    """Return one structured compatibility result for a profile and row."""
    p = profile if isinstance(profile, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(profile)
    row = scheme
    reasons, unmet, unknown = [], [], []
    evaluated = satisfied = 0

    checks = [
        ("age", _bounded(p.age, row.get("min_age"), row.get("max_age")), "Age falls within scheme range"),
        ("income", _bounded(p.income, None, row.get("max_income")), "Income is within scheme limit"),
        ("location", _contains(row.get("locations"), p.location), "Scheme supports this location/state"),
        ("social_category", _contains(row.get("social_categories"), p.social_category), "Scheme supports this social category"),
        ("education", _contains(row.get("education_requirements"), p.education), "Education meets scheme requirement"),
        ("business_type", _contains(row.get("business_types"), p.business_type), "Scheme supports this business type"),
        ("loan_purpose", _contains(row.get("loan_purposes"), p.loan_purpose), "Scheme supports this loan purpose"),
        ("project_cost", _bounded(p.project_cost, row.get("project_cost_min"), row.get("project_cost_max")), "Project cost is within supported range"),
        ("loan_amount", _bounded(p.required_loan_amount, row.get("min_loan_amount"), row.get("max_loan_amount")), "Loan amount is within supported range"),
    ]
    for name, matched, reason in checks:
        n, failed = _check(name, matched, reason, unmet, unknown, reasons)
        evaluated += n; satisfied += n - int(failed)
    evidence_coverage = round(100 * evaluated / len(CRITERIA), 2)
    compatibility_score = round(100 * satisfied / evaluated, 2) if evaluated else 0.0
    ranking_score = round(compatibility_score * evidence_coverage / 100, 2)
    status = STATUS_NOT_MET if unmet else (STATUS_VERIFY if unknown else STATUS_LIKELY)
    return {
        "scheme_id": row.get("scheme_id"), "scheme_name": row.get("scheme_name"),
        "match_score": compatibility_score, "compatibility_score": compatibility_score,
        "evidence_coverage": evidence_coverage, "ranking_score": ranking_score,
        "eligibility_status": status, "reasons": reasons, "unmet_criteria": unmet,
        "verification_required": unknown,
    }

def recommend(profile, schemes, top_k=10):
    """Rank non-rejected schemes deterministically by score, then stable ID."""
    if top_k < 0: raise ValueError("top_k must be non-negative")
    frame = load_scheme_data(schemes) if isinstance(schemes, (str, bytes, os.PathLike)) else schemes
    results = [evaluate_scheme(profile, row) for _, row in frame.iterrows()]
    results = [r for r in results if r["eligibility_status"] != STATUS_NOT_MET]
    results.sort(key=lambda r: (-r["match_score"], str(r["scheme_id"])))
    return results[:top_k]
