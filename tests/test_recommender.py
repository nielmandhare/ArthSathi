import pandas as pd
from ml.recommender import *

def schemes():
    return pd.DataFrame([
        {"scheme_id":"A","scheme_name":"Alpha","min_age":18,"max_age":60,"max_income":500000,"locations":"Maharashtra","social_categories":"OBC","education_requirements":"graduate","business_types":"tailoring","loan_purposes":"working_capital","project_cost_min":50000,"project_cost_max":500000,"min_loan_amount":50000,"max_loan_amount":500000},
        {"scheme_id":"B","scheme_name":"Beta","min_age":21,"max_age":35,"max_income":100000,"locations":"Karnataka","social_categories":"SC","education_requirements":"graduate","business_types":"dairy","loan_purposes":"asset_purchase","project_cost_min":50000,"project_cost_max":200000,"min_loan_amount":100000,"max_loan_amount":200000},
    ])

def profile(**changes):
    base = dict(age=30,income=200000,location="Maharashtra",social_category="OBC",education="graduate",business_type="tailoring",loan_purpose="working_capital",project_cost=100000,required_loan_amount=100000)
    base.update(changes); return base

def test_eligible_profile_and_reasons():
    result = recommend(profile(), schemes())[0]
    assert result["eligibility_status"] == STATUS_LIKELY
    assert result["match_score"] == 100.0
    assert "Loan amount is within supported range" in result["reasons"]

def test_clearly_ineligible_is_excluded():
    assert recommend(profile(location="Delhi", business_type="farming"), schemes()) == []

def test_missing_information_requires_verification():
    result = recommend(profile(income=None), schemes())[0]
    assert result["eligibility_status"] == STATUS_VERIFY
    assert "income" in result["verification_required"]

def test_deterministic_ranking_and_top_k():
    first = recommend(profile(), schemes(), top_k=1)
    second = recommend(profile(), schemes(), top_k=1)
    assert first == second and len(first) == 1

def test_boundary_values_are_inclusive():
    result = recommend(profile(age=18, required_loan_amount=50000), schemes())[0]
    assert result["eligibility_status"] == STATUS_LIKELY

def test_empty_compatible_results():
    assert recommend(profile(location="Delhi"), schemes()) == []
