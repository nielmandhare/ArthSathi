import json
import pandas as pd
from pathlib import Path
from ml.inference import recommend_schemes

TEST_DATA_DIR = Path(__file__).parents[1] / "work" / "phase4-tests"

def frame():
    return pd.DataFrame([
        {"scheme_id":"B","scheme_name":"Beta","minimum_age":18,"maximum_age":60,"income_max":500000,"state":"Maharashtra","social_categories":"OBC","education":"graduate","business_type":"tailoring","supported_purposes":"working_capital","project_cost_min":1,"project_cost_max":500000,"loan_amount_min":1,"loan_amount_max":500000,"interest_rate":5,"source_reference":"ref-b"},
        {"scheme_id":"A","scheme_name":"Alpha","minimum_age":18,"maximum_age":60,"income_max":100000,"state":"Karnataka","social_categories":"SC","education":"graduate","business_type":"dairy","supported_purposes":"asset_purchase","project_cost_min":1,"project_cost_max":100000,"loan_amount_min":1,"loan_amount_max":100000,"interest_rate":5,"source_reference":"ref-a"},
    ])

def profile(**extra):
    value = {"age":30,"income":200000,"location":"Maharashtra","social_category":"OBC","education":"graduate","business_type":"tailoring","loan_purpose":"working_capital","project_cost":100,"required_loan_amount":100}
    value.update(extra); return value

def test_response_is_json_safe_and_deterministic():
    TEST_DATA_DIR.mkdir(parents=True, exist_ok=True); path = TEST_DATA_DIR / "schemes.csv"; frame().to_csv(path, index=False)
    first = recommend_schemes(profile(), data_path=path)
    assert first == recommend_schemes(profile(), data_path=path)
    json.dumps(first); assert first["results"][0]["source_reference"] == "ref-b"

def test_top_k_and_missing_information():
    path = __import__("pathlib").Path(__file__).parents[1] / "data" / "schemes_master.csv"
    response = recommend_schemes(profile(income=None), top_k=1, data_path=path)
    assert len(response["results"]) <= 1
    if response["results"]: assert response["results"][0]["eligibility_status"] == "further_verification_required"

def test_empty_result_and_invalid_top_k():
    TEST_DATA_DIR.mkdir(parents=True, exist_ok=True); path = TEST_DATA_DIR / "schemes.csv"; frame().to_csv(path, index=False)
    assert recommend_schemes(profile(location="Delhi"), data_path=path)["results"] == []
    try: recommend_schemes(profile(), top_k=-1, data_path=path)
    except ValueError: pass
    else: raise AssertionError("negative top_k must fail")
