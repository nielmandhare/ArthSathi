import pandas as pd
from ml.relevance import evaluate_relevance
from ml.calibration import classify_relevance, TIER_ORDER

def profile(business, purpose, social="SC"):
    return {"age":25,"income":300000,"location":"Maharashtra","social_category":social,"education":"Graduate","business_type":business,"loan_purpose":purpose,"project_cost":500000,"required_loan_amount":300000}

def row(category, purpose, text=""):
    return {"scheme_name":text,"official_scheme_name":text,"category":category,"subcategory":"","tags":"","short_description":text,"detailed_description":text,"supported_purposes":purpose,"social_categories":"SC","state":"Maharashtra"}

def test_gst_transport_structured_noise_is_not_exact():
    result = evaluate_relevance(profile("Transport", "Transport"), row("Transport & Infrastructure", None, "GST Exemption Certificate for disability car concession"))
    assert result["relevance_score"] < 50
    assert all(item["strength"] != "exact structured domain" for item in result["relevance_evidence"])

def test_corroborated_domain_beats_structured_only():
    corroborated = evaluate_relevance(profile("Agriculture", "Agriculture"), row("Agriculture", "Agriculture", "Agriculture farming support"))
    structured_only = evaluate_relevance(profile("Agriculture", "Agriculture"), row("Agriculture", "Agriculture", "General assistance"))
    assert corroborated["relevance_score"] > structured_only["relevance_score"]
    assert any(item["corroborated"] for item in corroborated["relevance_evidence"])

def test_score_tier_consistency_and_generic_conservatism():
    generic = evaluate_relevance(profile("Small Business", "Business"), row("Business & Entrepreneurship", "Business", "Business loan scheme"))
    assert generic["relevance_score"] < 85
    tier = classify_relevance(generic["relevance_score"], generic["relevance_evaluated"], 55.56)
    assert tier != "strongly_relevant" and TIER_ORDER[tier] >= 0

def test_social_category_does_not_inflate_semantic_evidence():
    sc = evaluate_relevance(profile("Small Business", "Business", "SC"), row("Agriculture", "Agriculture", "Agriculture farming"))
    general = evaluate_relevance(profile("Small Business", "Business", "General"), row("Agriculture", "Agriculture", "Agriculture farming"))
    assert sc["relevance_score"] == general["relevance_score"]
