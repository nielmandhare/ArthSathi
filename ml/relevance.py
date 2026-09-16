"""Deterministic semantic/domain relevance signals, separate from eligibility."""
import re
from .recommender import BeneficiaryProfile, _missing

TEXT_FIELDS = ("scheme_name", "official_scheme_name", "short_description", "detailed_description", "category", "subcategory", "tags", "supported_purposes", "eligibility_raw")

def _tokens(value):
    if _missing(value): return set()
    return set(re.findall(r"[a-z0-9]+", str(value).casefold()))

def _text(row):
    return set().union(*(_tokens(row.get(field)) for field in TEXT_FIELDS))

def evaluate_relevance(profile, scheme):
    """Return relevance only; no result here implies eligibility."""
    p = profile if isinstance(profile, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(profile)
    document = _text(scheme)
    groups = []
    if not _missing(p.business_type): groups.append(("business", _tokens(p.business_type), "Scheme activity is relevant to the stated business type."))
    if not _missing(p.loan_purpose): groups.append(("purpose", _tokens(p.loan_purpose), "Scheme information is relevant to the stated loan purpose."))
    if not _missing(p.location):
        states = _tokens(scheme.get("state")) | _tokens(scheme.get("state_requirement"))
        groups.append(("location", _tokens(p.location), "Scheme location matches the beneficiary location." if states & _tokens(p.location) else ""))
    if not _missing(p.social_category): groups.append(("social", _tokens(p.social_category), "Scheme information mentions the stated social category."))
    matched = 0; reasons = []; unknown = []
    for name, intent, reason in groups:
        if not document and name != "location": unknown.append(name); continue
        if name == "location":
            states = _tokens(scheme.get("state")) | _tokens(scheme.get("state_requirement"))
            if not states: unknown.append(name)
            elif states & intent: matched += 1; reasons.append(reason)
        elif intent & document:
            matched += 1; reasons.append(reason)
        else:
            # A populated descriptive record with no overlap is a relevance mismatch,
            # not an eligibility failure.
            pass
    score = round(100 * matched / len(groups), 2) if groups else 0.0
    return {"relevance_score": score, "relevance_reasons": reasons, "relevance_unknown": unknown}
