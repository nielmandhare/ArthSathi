import json
from pathlib import Path
import pytest
from ml.inference import recommend_schemes
from ml.phase5_validation import validate_master_dataset
from ml.recommender import evaluate_scheme

MASTER = Path(__file__).parents[1] / "data" / "schemes_master.csv"

def profile(**changes):
    value = {"age":30,"income":200000,"location":"Maharashtra","social_category":"OBC","education":"graduate","business_type":"tailoring","loan_purpose":"working_capital","project_cost":100000,"required_loan_amount":50000}
    value.update(changes); return value

def test_real_dataset_validation_findings():
    report = validate_master_dataset(MASTER)
    assert report["rows"] == 3397 and report["columns"] == 60
    assert report["duplicate_scheme_ids"] == 0
    assert report["numeric_invalid"]["age_reversed"] == 0

@pytest.mark.parametrize("changes,expected", [(dict(age=0), "further_verification_required"), (dict(income=None), "further_verification_required"), (dict(location=None), "further_verification_required"), (dict(social_category=None), "further_verification_required"), (dict(education=None), "further_verification_required"), (dict(business_type=None), "further_verification_required"), (dict(loan_purpose=None), "further_verification_required")])
def test_sparse_profiles_do_not_upgrade_uncertainty(changes, expected):
    response = recommend_schemes(profile(**changes), top_k=1, data_path=MASTER)
    assert all(item["eligibility_status"] == expected for item in response["results"])

def test_invalid_numeric_profile_rejected_by_api_contract():
    from api import RecommendationRequest
    with pytest.raises(Exception): RecommendationRequest(age=-1)

def test_unknown_values_are_deterministic_and_json_safe():
    response = recommend_schemes(profile(location="Unknown-State", income=10**100, required_loan_amount=10**100), top_k=3, data_path=MASTER)
    json.dumps(response)
    assert response == recommend_schemes(profile(location="Unknown-State", income=10**100, required_loan_amount=10**100), top_k=3, data_path=MASTER)

def test_evidence_adjusted_score_prevents_sparse_perfect_ranking():
    complete = {"scheme_id":"complete","scheme_name":"Complete","min_age":18,"max_age":60,"max_income":500000,"locations":"Maharashtra","social_categories":"OBC","education_requirements":"graduate","business_types":"tailoring","loan_purposes":"working_capital","project_cost_min":1,"project_cost_max":500000,"min_loan_amount":1,"max_loan_amount":500000}
    sparse = {"scheme_id":"sparse","scheme_name":"Sparse","min_loan_amount":1,"max_loan_amount":500000}
    full = evaluate_scheme(profile(), complete); thin = evaluate_scheme(profile(), sparse)
    assert full["compatibility_score"] == thin["compatibility_score"] == 100.0
    assert thin["evidence_coverage"] < full["evidence_coverage"]
    assert thin["ranking_score"] < full["ranking_score"]

def test_definitive_failure_remains_excluded():
    result = evaluate_scheme(profile(location="Delhi"), {"scheme_id":"x","scheme_name":"X","locations":"Karnataka","min_loan_amount":1,"max_loan_amount":500000})
    assert result["eligibility_status"] == "criteria_not_met"
    assert "location" in result["unmet_criteria"]
