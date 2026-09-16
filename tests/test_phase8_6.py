from pathlib import Path
from ml.inference import recommend_schemes
from ml.relevance import evaluate_relevance

def profile(business, purpose, social="SC"):
    return {"age":25,"income":300000,"location":"Maharashtra","social_category":social,"education":"Graduate","business_type":business,"loan_purpose":purpose,"project_cost":500000,"required_loan_amount":300000}

def scheme(category, purpose, target=None):
    return {"scheme_name":category,"official_scheme_name":category,"category":category,"subcategory":"","tags":"","short_description":category,"detailed_description":category,"supported_purposes":purpose,"social_categories":target,"state":"Maharashtra"}

def test_student_education_has_no_business_domain_evidence():
    result = evaluate_relevance(profile("Student", "Education"), scheme("Education & Learning", "Education", "SC"))
    assert "business_domain" not in result["matched_relevance_groups"]
    assert "education_domain" in result["matched_relevance_groups"]

def test_domain_intents_remain_distinct():
    assert "business_domain" in evaluate_relevance(profile("Agriculture", "Agriculture"), scheme("Agriculture", "Agriculture"))["matched_relevance_groups"]
    assert "business_domain" in evaluate_relevance(profile("Transport", "Transport"), scheme("Transport", "Transport"))["matched_relevance_groups"]
    assert "business_domain" in evaluate_relevance(profile("Small Business", "Business"), scheme("Business & Entrepreneurship", "Business"))["matched_relevance_groups"]

def test_targeting_is_independent_of_education_relevance():
    result = evaluate_relevance(profile("Student", "Education", "SC"), scheme("Education & Learning", "Education", "SC"))
    assert result["relevance_score"] == evaluate_relevance(profile("Student", "Education", "General"), scheme("Education & Learning", "Education", "SC"))["relevance_score"]

def test_repeated_real_inference_is_deterministic():
    path = Path(__file__).parents[1] / "data" / "schemes_master.csv"
    p = profile("Student", "Education")
    assert recommend_schemes(p, top_k=10, data_path=path) == recommend_schemes(p, top_k=10, data_path=path)
