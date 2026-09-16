import json
from ml.relevance import evaluate_relevance
from ml.inference import recommend_schemes

PROFILE = {"age":25,"income":300000,"location":"Maharashtra","social_category":"General","education":"Graduate","business_type":"Small Business","loan_purpose":"Business","project_cost":500000,"required_loan_amount":300000}

def scheme(category, purpose="Business", state="Maharashtra"):
    return {"scheme_id":category,"scheme_name":category,"category":category,"tags":"", "supported_purposes":purpose,"state":state}

def test_business_domain_relevance_beats_unrelated_domain_signal():
    relevant = evaluate_relevance(PROFILE, scheme("Business & Entrepreneurship"))
    unrelated = evaluate_relevance(PROFILE, scheme("Agriculture,Rural & Environment"))
    assert relevant["relevance_score"] > unrelated["relevance_score"]

def test_relevance_does_not_change_eligibility_semantics():
    from ml.recommender import evaluate_scheme
    row = scheme("Business & Entrepreneurship"); row.update({"min_age":40,"max_age":60,"min_loan_amount":1,"max_loan_amount":500000})
    assert evaluate_scheme(PROFILE, row)["eligibility_status"] == "criteria_not_met"

def test_real_profile_response_has_separate_scores_and_is_stable():
    from pathlib import Path
    path = Path(__file__).parents[1] / "data" / "schemes_master.csv"
    first = recommend_schemes(PROFILE, top_k=10, data_path=path)
    second = recommend_schemes(PROFILE, top_k=10, data_path=path)
    assert first == second and len(first["results"]) <= 10
    assert all("relevance_score" in row and "ranking_score" in row for row in first["results"])
    json.dumps(first)
