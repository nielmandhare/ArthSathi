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
    matched = 0; evaluated = 0; reasons = []; unknown = []
    for name, intent, reason in groups:
        if not document and name != "location": unknown.append(name); continue
        if name == "location":
            states = _tokens(scheme.get("state")) | _tokens(scheme.get("state_requirement"))
            if not states: unknown.append(name)
            elif states & intent: matched += 1; evaluated += 1; reasons.append(reason)
            else: evaluated += 1
        elif name == "business" and not _business_domain_supports(scheme, intent):
            evaluated += 1
        elif name == "social":
            social = _tokens(scheme.get("social_categories"))
            if social and social & intent: matched += 1; reasons.append(reason)
            if social: evaluated += 1
            elif not social: unknown.append(name)
        elif intent & document:
            matched += 1; evaluated += 1; reasons.append(reason)
        else:
            # A populated descriptive record with no overlap is a relevance mismatch,
            # not an eligibility failure.
            evaluated += 1
    score = round(100 * matched / evaluated, 2) if evaluated else 0.0
    return {"relevance_score": score, "relevance_reasons": reasons, "relevance_unknown": unknown}

def _business_domain_supports(row, intent):
    """Use populated category fields to avoid broad description word matches."""
    category = _tokens(row.get("category")) | _tokens(row.get("subcategory")) | _tokens(row.get("tags"))
    business_intent = {"business", "enterprise", "entrepreneurship", "entrepreneur", "startup", "msme", "commercial", "finance", "banking"}
    agriculture_intent = {"agriculture", "farmer", "farming", "fishery", "fisherman", "animal", "dairy"}
    if intent & agriculture_intent: return bool(category & agriculture_intent)
    if intent & {"small", "business", "enterprise", "entrepreneurship", "entrepreneur", "startup", "msme"}:
        return bool(category & business_intent)
    return bool(intent & category)
