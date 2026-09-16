import json
from pathlib import Path
from ml.inference import recommend_schemes
from ml.target_groups import evaluate_target_group

def profile(category):
    return {"age":25,"income":300000,"location":"Maharashtra","social_category":category,"education":"Graduate","business_type":"Small Business","loan_purpose":"Business","project_cost":500000,"required_loan_amount":300000}

def row(groups=None, gender=None, name="Scheme"):
    return {"scheme_id":name,"scheme_name":name,"social_categories":groups,"gender":gender,"category":"Business & Entrepreneurship","supported_purposes":"Business","state":"Maharashtra"}

def test_sc_and_st_targeting_matches():
    assert evaluate_target_group(profile("SC"), row("Scheduled Castes"))["target_group_match"] == "matched"
    assert evaluate_target_group(profile("ST"), row("Scheduled Tribes"))["target_group_match"] == "matched"

def test_sc_st_supports_both_and_general_stays_unknown():
    assert evaluate_target_group(profile("SC"), row("SC, ST"))["target_group_match"] == "matched"
    assert evaluate_target_group(profile("ST"), row("SC/ST"))["target_group_match"] == "matched"
    assert evaluate_target_group(profile("SC"), row(None))["target_group_match"] == "unknown"

def test_women_restriction_is_evidence_not_eligibility():
    result = evaluate_target_group(profile("General"), row(None, gender="Female", name="Women scheme"))
    assert result["target_group_match"] == "unknown"
    assert result["target_group_score"] == 50.0

def test_ambiguous_text_does_not_create_sc_support():
    result = evaluate_target_group(profile("SC"), row(None, name="Scheme for school activities"))
    assert result["target_group_match"] == "unknown"

def test_real_sc_and_st_responses_are_stable_and_json_safe():
    path = Path(__file__).parents[1] / "data" / "schemes_master.csv"
    for category in ("SC", "ST"):
        first = recommend_schemes(profile(category), top_k=10, data_path=path)
        assert first == recommend_schemes(profile(category), top_k=10, data_path=path)
        assert len(first["results"]) <= 10
        assert all("target_group_match" in item and "target_group_evidence" in item for item in first["results"])
        json.dumps(first)
