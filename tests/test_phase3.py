import pandas as pd
import pytest
from ml.features import build_feature_matrix
from ml.models import StructuredSimilarityRanker
from ml.evaluate import ranking_diagnostics, evaluate_labeled_predictions

def data():
    schemes = pd.DataFrame([{"scheme_id":"B","scheme_name":"B","min_age":18,"max_age":60,"max_income":500000,"locations":"Maharashtra","social_categories":"OBC","education_requirements":"graduate","business_types":"tailoring","loan_purposes":"working_capital","project_cost_min":1,"project_cost_max":500000,"min_loan_amount":1,"max_loan_amount":500000}, {"scheme_id":"A","scheme_name":"A","min_age":18,"max_age":60,"max_income":100000,"locations":"Karnataka","social_categories":"SC","education_requirements":"graduate","business_types":"dairy","loan_purposes":"asset_purchase","project_cost_min":1,"project_cost_max":100000,"min_loan_amount":1,"max_loan_amount":100000}])
    profile = {"age":30,"income":200000,"location":"Maharashtra","social_category":"OBC","education":"graduate","business_type":"tailoring","loan_purpose":"working_capital","project_cost":100,"required_loan_amount":100}
    return profile, schemes

def test_feature_generation_is_structured_and_deterministic():
    p, s = data(); a = build_feature_matrix(p, s); b = build_feature_matrix(p, s)
    assert a.equals(b) and "age_match" in a and "loan_amount_match" in a

def test_similarity_ranking_and_top_k():
    p, s = data(); model = StructuredSimilarityRanker(top_k=1).fit(s)
    result = model.predict(p)
    assert len(result) == 1 and result.iloc[0].scheme_id == "B"
    assert ranking_diagnostics(result)["scores_non_increasing"]

def test_missing_profile_is_unknown_not_match():
    p, s = data(); p["income"] = None
    row = build_feature_matrix(p, s).iloc[0]
    assert pd.isna(row["income_match"]) and row["income_known"] == 0

def test_supervised_evaluation_requires_real_labels():
    with pytest.raises(ValueError, match="outcome labels"):
        evaluate_labeled_predictions([1], [1])
