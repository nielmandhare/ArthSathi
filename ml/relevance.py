"""Deterministic weighted domain/purpose relevance."""
import re
from .recommender import BeneficiaryProfile, _missing

TEXT_FIELDS = ("scheme_name", "official_scheme_name", "short_description", "detailed_description", "category", "subcategory", "tags", "supported_purposes", "sectors", "activities_supported")
TITLE_FIELDS = ("scheme_name", "official_scheme_name")
DESCRIPTION_FIELDS = ("short_description", "detailed_description")
TEXT_ONLY_FIELDS = ("scheme_name", "official_scheme_name", "short_description", "detailed_description")
GENERIC = {"business", "loan", "scheme", "support", "assistance", "financial", "finance", "benefit", "benefits", "general", "small", "enterprise", "employment", "development", "program", "programme", "india", "sc", "st"}
DOMAIN_SETS = {
    # These are domain vocabulary, not eligibility rules. They improve typed
    # retrieval for sparse canonical rows while description-only mentions stay
    # non-establishing under the primary-intent policy below.
    "agriculture": {"agriculture", "agricultural", "farmer", "farming", "fishery", "fisherman", "animal", "dairy", "crop", "crops", "irrigation", "horticulture", "livestock", "poultry", "fisheries"},
    "transport": {"transport", "transportation", "logistics", "vehicle", "automobile", "mobility", "freight", "cargo", "taxi", "truck", "bus", "roadway", "roadways"},
    "education": {"education", "school", "student", "training", "academic", "scholarship", "college", "university", "tuition", "study"},
    "business": {"business", "enterprise", "entrepreneurship", "entrepreneur", "startup", "msme", "commercial", "banking", "trade", "retail", "manufacturing"},
}
BUSINESS_INTENT = {"business", "enterprise", "entrepreneurship", "entrepreneur", "startup", "msme", "commercial", "banking", "agriculture", "agricultural", "farmer", "farming", "fishery", "fisherman", "animal", "dairy", "transport", "transportation", "logistics", "vehicle", "automobile"}
EDUCATION_INTENT = {"education", "school", "student", "training", "academic", "scholarship"}

def _tokens(value):
    if _missing(value): return set()
    return set(re.findall(r"[a-z0-9]+", str(value).casefold()))

def _specific(value):
    return {token for token in _tokens(value) if token not in GENERIC and len(token) > 2}

def _title_tokens(value):
    return {token for token in _tokens(value) if token not in GENERIC}

def _overlap(left, right):
    aliases = {"ag": "agriculture", "tr": "transport", "ed": "education"}
    return any(
        a == b or aliases.get(a, a) == aliases.get(b, b)
        or (len(a) >= 6 and len(b) >= 6 and (a.startswith(b[:6]) or b.startswith(a[:6])))
        for a in left for b in right
    )

def _domain_for(intent):
    for name, tokens in DOMAIN_SETS.items():
        if intent & tokens: return name, tokens
    return None, set()

def _business_domain_supports(row, intent):
    domain, tokens = _domain_for(intent)
    category = _specific(row.get("category")) | _specific(row.get("subcategory")) | _specific(row.get("tags"))
    return bool(category & tokens) if domain else bool(intent & category)

def _evidence_strength(name, intent, raw, row, document, title_document, description_document):
    """Return strength and provenance; structured-only is never exact."""
    if not intent:
        if name == "business_domain" and "business" in raw and _business_domain_supports(row, {"business"}): return .25, "generic structured category", ("category",), False, False
        if name == "loan_purpose" and "business" in raw and _business_domain_supports(row, {"business"}) and "business" in _tokens(row.get("supported_purposes")): return .25, "generic structured purpose", ("supported_purposes",), False, False
        return 0.0, "unknown", (), False, False
    domain, domain_tokens = _domain_for(intent)
    category = _specific(row.get("category")) | _specific(row.get("subcategory")) | _specific(row.get("tags"))
    supported = _specific(row.get("supported_purposes"))
    # Match against the typed vocabulary for the beneficiary's inferred
    # domain, allowing reliable near-domain terms such as vehicle/mobility
    # for transport without treating arbitrary text as a domain signal.
    match_tokens = domain_tokens or intent
    structured_domain = _overlap(match_tokens, category)
    structured_purpose = _overlap(match_tokens, supported)
    structured = structured_domain if name == "business_domain" else structured_purpose
    title = _overlap(match_tokens, title_document)
    incidental = _overlap(match_tokens, description_document)
    source = ("category",) if name == "business_domain" and structured_domain else (("supported_purposes",) if structured_purpose else ())
    if title and structured: return 1.0, "corroborated title and structured evidence", source + ("scheme_name",), True, False
    if title: return .9, "primary title evidence", ("scheme_name",), False, False
    if structured: return .65, "structured-only primary evidence; not corroborated", source, False, False
    if incidental: return 0.0, "incidental description text ignored", ("description",), False, False
    contradiction = bool(domain and category & set().union(*(DOMAIN_SETS[k] for k in DOMAIN_SETS if k != domain)))
    return 0.0, "contradictory domain evidence" if contradiction else "no matching domain evidence", (), False, contradiction

def evaluate_relevance(profile, scheme):
    """Return weighted domain/purpose relevance; target groups are excluded."""
    p = profile if isinstance(profile, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(profile)
    document = set().union(*(_specific(scheme.get(field)) for field in TEXT_FIELDS))
    title_document = set().union(*(_title_tokens(scheme.get(field)) for field in TITLE_FIELDS))
    description_document = set().union(*(_specific(scheme.get(field)) for field in DESCRIPTION_FIELDS))
    groups = []
    business_tokens = _specific(p.business_type) if not _missing(p.business_type) else set()
    raw_business_tokens = _tokens(p.business_type) if not _missing(p.business_type) else set()
    if (business_tokens & BUSINESS_INTENT or raw_business_tokens & {"small", "business", "enterprise"}) and not (raw_business_tokens & EDUCATION_INTENT):
        groups.append(("business_domain", business_tokens, raw_business_tokens, "Scheme domain is relevant to the stated business type."))
    if not _missing(p.loan_purpose): groups.append(("loan_purpose", _specific(p.loan_purpose), _tokens(p.loan_purpose), "Scheme purpose is relevant to the stated loan purpose."))
    education_intent = set()
    if not _missing(p.business_type): education_intent |= _specific(p.business_type) & EDUCATION_INTENT
    if not _missing(p.loan_purpose): education_intent |= _specific(p.loan_purpose) & EDUCATION_INTENT
    if not _missing(p.education): education_intent |= _specific(p.education) & EDUCATION_INTENT
    if education_intent:
        groups.append(("education_domain", education_intent, education_intent, "Scheme domain is relevant to the education intent."))
    strengths = []; reasons = []; matched_groups = []; unknown = []; evidence = []
    for name, intent, raw, reason in groups:
        strength, label, sources, corroborated, contradiction = _evidence_strength(name, intent, raw, scheme, document, title_document, description_document)
        if not intent and label == "unknown": unknown.append(name); continue
        strengths.append(strength)
        evidence.append({"group": name, "source": sources, "strength": label, "value": strength, "corroborated": corroborated, "contradiction": contradiction})
        if strength > 0:
            matched_groups.append(name); reasons.append(reason)
    score = round(100 * sum(strengths) / len(strengths), 2) if strengths else 0.0
    return {"relevance_score": score, "relevance_evaluated": len(strengths), "relevance_matched": len(matched_groups), "matched_relevance_groups": matched_groups, "relevance_evidence": evidence, "relevance_reasons": reasons, "relevance_unknown": unknown}
