"""Reliable target-group evidence, separate from eligibility evaluation."""
import re
from .recommender import BeneficiaryProfile, _missing

TARGET_GROUPS = {"sc": "SC", "st": "ST", "women": "women"}

def _text(value):
    if _missing(value): return ""
    return re.sub(r"\s+", " ", str(value).casefold()).strip()

def _structured_groups(value):
    text = _text(value)
    groups = set()
    if re.search(r"\b(?:sc|scheduled caste|scheduled castes)\b", text): groups.add("SC")
    if re.search(r"\b(?:st|scheduled tribe|scheduled tribes)\b", text): groups.add("ST")
    if re.search(r"\b(?:women|woman|female)\b", text): groups.add("women")
    return groups

def _explicit_text_groups(row):
    groups = set()
    for field in ("scheme_name", "official_scheme_name", "short_description", "eligibility_raw"):
        text = _text(row.get(field))
        if re.search(r"\b(?:scheduled caste|scheduled castes)\b|\bsc/st\b", text): groups.add("SC")
        if re.search(r"\b(?:scheduled tribe|scheduled tribes)\b|\bsc/st\b", text): groups.add("ST")
        if re.search(r"\b(?:women only|women entrepreneurs|women beneficiaries|female beneficiaries)\b", text): groups.add("women")
    return groups

def evaluate_target_group(profile, scheme):
    """Return target-group match, evidence, and a ranking-only score."""
    raw_gender = profile.get("gender") if isinstance(profile, dict) else None
    p = profile if isinstance(profile, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(profile)
    beneficiary = _text(p.social_category)
    requested = set()
    if re.search(r"\b(?:sc|scheduled caste|scheduled castes)\b", beneficiary): requested.add("SC")
    if re.search(r"\b(?:st|scheduled tribe|scheduled tribes)\b", beneficiary): requested.add("ST")
    if _text(raw_gender) in {"female", "woman", "women"}: requested.add("women")
    structured = _structured_groups(scheme.get("social_categories"))
    text_groups = _explicit_text_groups(scheme)
    gender = _text(scheme.get("gender"))
    if gender == "female": text_groups.add("women")
    supported = structured | text_groups
    evidence = []
    if structured: evidence.append({"source": "social_categories", "groups": sorted(structured), "strength": "strong"})
    if text_groups - structured: evidence.append({"source": "explicit_scheme_text_or_gender", "groups": sorted(text_groups - structured), "strength": "moderate"})
    if _text(raw_gender) in {"male", "man", "men"} and "women" in supported:
        match, score = "not_matched", 0.0
        reason = "Scheme is explicitly restricted to women and the provided beneficiary gender does not match."
    elif requested and supported & requested:
        match, score = "matched", 100.0
        reason = "Scheme explicitly targets the beneficiary social category."
    elif requested and supported and not (supported & requested):
        match, score = "not_matched", 0.0
        reason = "Scheme target group does not match the beneficiary social category."
    elif supported:
        match, score = "unknown", 50.0
        reason = "Scheme has a target-group restriction that cannot be matched to the available beneficiary profile."
    else:
        match, score = "unknown", 50.0
        reason = "Scheme target group could not be verified from available data."
    return {"target_group_match": match, "target_group_score": score, "target_group_evidence": evidence, "target_group_reason": reason}
