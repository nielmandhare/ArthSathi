"""Deterministic weighted domain/purpose relevance."""
import re
from .recommender import BeneficiaryProfile, _missing

TEXT_FIELDS = ("scheme_name", "official_scheme_name", "short_description", "detailed_description", "category", "subcategory", "tags", "supported_purposes", "sectors", "activities_supported")
TEXT_ONLY_FIELDS = ("scheme_name", "official_scheme_name", "short_description", "detailed_description")
GENERIC = {"business", "loan", "scheme", "support", "assistance", "financial", "finance", "benefit", "benefits", "general", "small", "enterprise", "employment", "development", "program", "programme", "india", "sc", "st"}
DOMAIN_SETS = {
    "agriculture": {"agriculture", "agricultural", "farmer", "farming", "fishery", "fisherman", "animal", "dairy"},
    "transport": {"transport", "transportation", "logistics", "vehicle", "automobile"},
    "education": {"education", "school", "student", "training", "academic"},
    "business": {"business", "enterprise", "entrepreneurship", "entrepreneur", "startup", "msme", "commercial", "banking"},
}

def _tokens(value):
    if _missing(value): return set()
    return set(re.findall(r"[a-z0-9]+", str(value).casefold()))

def _specific(value):
    return {token for token in _tokens(value) if token not in GENERIC and len(token) > 2}

def _overlap(left, right):
    return any(a == b or (len(a) >= 6 and len(b) >= 6 and (a.startswith(b[:6]) or b.startswith(a[:6]))) for a in left for b in right)

def _domain_for(intent):
    for name, tokens in DOMAIN_SETS.items():
        if intent & tokens: return name, tokens
    return None, set()

def _business_domain_supports(row, intent):
    domain, tokens = _domain_for(intent)
    category = _specific(row.get("category")) | _specific(row.get("subcategory")) | _specific(row.get("tags"))
    return bool(category & tokens) if domain else bool(intent & category)

def _evidence_strength(name, intent, raw, row, document, text_document):
    """Return strength and provenance; structured-only is never exact."""
    if not intent:
        if name == "business_domain" and "business" in raw and _business_domain_supports(row, {"business"}): return .25, "generic structured category", ("category",), False, False
        if name == "loan_purpose" and "business" in raw and _business_domain_supports(row, {"business"}) and "business" in _tokens(row.get("supported_purposes")): return .25, "generic structured purpose", ("supported_purposes",), False, False
        return 0.0, "unknown", (), False, False
    domain, domain_tokens = _domain_for(intent)
    category = _specific(row.get("category")) | _specific(row.get("subcategory")) | _specific(row.get("tags"))
    supported = _specific(row.get("supported_purposes"))
    structured = _overlap(intent, category) if name == "business_domain" else _overlap(intent, supported)
    textual = _overlap(intent, text_document)
    if structured and textual: return 1.0, "corroborated structured and textual evidence", (("category",) if name == "business_domain" else ("supported_purposes",)) + ("name_or_description",), True, False
    if structured: return .55, "structured-only evidence; not corroborated", (("category",) if name == "business_domain" else ("supported_purposes",)), False, False
    if textual: return .45, "textual/domain evidence without structured confirmation", ("name_or_description",), False, False
    contradiction = bool(domain and category & set().union(*(DOMAIN_SETS[k] for k in DOMAIN_SETS if k != domain)))
    return 0.0, "contradictory domain evidence" if contradiction else "no matching domain evidence", (), False, contradiction

def evaluate_relevance(profile, scheme):
    """Return weighted domain/purpose relevance; target groups are excluded."""
    p = profile if isinstance(profile, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(profile)
    document = set().union(*(_specific(scheme.get(field)) for field in TEXT_FIELDS))
    text_document = set().union(*(_specific(scheme.get(field)) for field in TEXT_ONLY_FIELDS))
    groups = []
    if not _missing(p.business_type): groups.append(("business_domain", _specific(p.business_type), _tokens(p.business_type), "Scheme domain is relevant to the stated business type."))
    if not _missing(p.loan_purpose): groups.append(("loan_purpose", _specific(p.loan_purpose), _tokens(p.loan_purpose), "Scheme purpose is relevant to the stated loan purpose."))
    if not _missing(p.education) and _specific(p.education) & DOMAIN_SETS["education"]:
        groups.append(("education_domain", _specific(p.education), _tokens(p.education), "Scheme domain is relevant to the education intent."))
    strengths = []; reasons = []; matched_groups = []; unknown = []; evidence = []
    for name, intent, raw, reason in groups:
        strength, label, sources, corroborated, contradiction = _evidence_strength(name, intent, raw, scheme, document, text_document)
        if not intent and label == "unknown": unknown.append(name); continue
        strengths.append(strength)
        evidence.append({"group": name, "source": sources, "strength": label, "value": strength, "corroborated": corroborated, "contradiction": contradiction})
        if strength > 0:
            matched_groups.append(name); reasons.append(reason)
    score = round(100 * sum(strengths) / len(strengths), 2) if strengths else 0.0
    return {"relevance_score": score, "relevance_evaluated": len(strengths), "relevance_matched": len(matched_groups), "matched_relevance_groups": matched_groups, "relevance_evidence": evidence, "relevance_reasons": reasons, "relevance_unknown": unknown}
