import pandas as pd
from ml.relevance import evaluate_relevance
from ml.calibration import classify_relevance
from ml.models import StructuredSimilarityRanker

def profile(business, purpose, social="SC", education="Graduate"):
    return {"age":25,"income":300000,"location":"Maharashtra","social_category":social,"education":education,"business_type":business,"loan_purpose":purpose,"project_cost":500000,"required_loan_amount":300000}

def scheme(name, category, purpose, target=None):
    return {"scheme_id":name,"scheme_name":name,"official_scheme_name":name,"category":category,"subcategory":"","tags":"","short_description":category,"detailed_description":category,"supported_purposes":purpose,"social_categories":target,"state":"Maharashtra","min_age":18,"max_age":60,"max_income":500000,"locations":"Maharashtra","education_requirements":"Graduate","business_types":"","loan_purposes":purpose,"project_cost_min":1,"project_cost_max":1000000,"min_loan_amount":1,"max_loan_amount":500000}

def test_generic_business_does_not_match_agriculture_or_transport():
    p = profile("Small Business", "Business")
    assert evaluate_relevance(p, scheme("ag", "Agriculture,Rural", "Agriculture"))["relevance_score"] < 50
    assert evaluate_relevance(p, scheme("tr", "Transport & Infrastructure", "Transport"))["relevance_score"] < 50

def test_specific_domains_match_their_intent():
    assert evaluate_relevance(profile("Agriculture", "Agriculture"), scheme("ag", "Agriculture,Rural", "Agriculture"))["relevance_score"] == 100
    assert evaluate_relevance(profile("Transport", "Transport"), scheme("tr", "Transport & Infrastructure", "Transport"))["relevance_score"] == 100
    assert evaluate_relevance(profile("Education", "Education"), scheme("ed", "Education & Learning", "Education"))["relevance_score"] == 100

def test_social_category_does_not_create_domain_relevance():
    result = evaluate_relevance(profile("Small Business", "Business", "SC"), scheme("ag", "Agriculture,Rural", "Agriculture", "SC"))
    assert result["relevance_score"] < 50

def test_generic_tokens_and_sparse_evidence_do_not_create_strong_tier():
    result = evaluate_relevance(profile("Small Business", "Business"), scheme("x", "Business", "Business"))
    assert result["relevance_score"] == 0
    assert classify_relevance(result["relevance_score"], result["relevance_evaluated"], 11.11) == "unrelated"

def test_deterministic_domain_tier_ordering():
    p = profile("Agriculture", "Agriculture")
    data = pd.DataFrame([scheme("broad", "Business", "Business"), scheme("specific", "Agriculture,Rural", "Agriculture")])
    first = StructuredSimilarityRanker(top_k=2).fit(data).rank(p)
    second = StructuredSimilarityRanker(top_k=2).fit(data).rank(p)
    assert list(first.scheme_id) == list(second.scheme_id) and first.iloc[0].scheme_id == "specific"
