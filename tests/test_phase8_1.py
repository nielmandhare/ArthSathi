from ml.models import StructuredSimilarityRanker
from ml.target_groups import evaluate_target_group

def profile(category="SC"):
    return {"age":25,"income":300000,"location":"Maharashtra","social_category":category,"education":"Graduate","business_type":"Small Business","loan_purpose":"Business","project_cost":500000,"required_loan_amount":300000}

def scheme(scheme_id, category, target=None, purpose="Business"):
    return {"scheme_id":scheme_id,"scheme_name":scheme_id,"min_age":18,"max_age":60,"max_income":500000,"locations":"Maharashtra","social_categories":target,"education_requirements":"Graduate","business_types":"Small Business","loan_purposes":purpose,"project_cost_min":1,"project_cost_max":1000000,"min_loan_amount":1,"max_loan_amount":500000,"category":category,"supported_purposes":purpose,"state":"Maharashtra"}

def test_relevant_targeted_beats_irrelevant_targeted():
    schemes = __import__("pandas").DataFrame([scheme("irrelevant-sc", "Agriculture,Rural & Environment", "SC", "Business"), scheme("relevant-sc", "Business & Entrepreneurship", "SC")])
    ranked = StructuredSimilarityRanker(top_k=2).fit(schemes).rank(profile())
    assert list(ranked.scheme_id) == ["relevant-sc", "irrelevant-sc"]

def test_relevant_general_remains_above_weak_targeted():
    schemes = __import__("pandas").DataFrame([scheme("targeted-weak", "Agriculture,Rural & Environment", "SC", "Business"), scheme("general-relevant", "Business & Entrepreneurship", None)])
    ranked = StructuredSimilarityRanker(top_k=2).fit(schemes).rank(profile())
    assert ranked.iloc[0].scheme_id == "general-relevant"

def test_st_equivalent_and_unknown_are_deterministic():
    schemes = __import__("pandas").DataFrame([scheme("st", "Business & Entrepreneurship", "ST"), scheme("general", "Business & Entrepreneurship", None)])
    first = StructuredSimilarityRanker(top_k=2).fit(schemes).rank(profile("ST"))
    second = StructuredSimilarityRanker(top_k=2).fit(schemes).rank(profile("ST"))
    assert list(first.scheme_id) == list(second.scheme_id) and first.iloc[0].scheme_id == "st"
    assert evaluate_target_group(profile("ST"), scheme("unknown", "Business & Entrepreneurship"))["target_group_match"] == "unknown"

def test_target_group_reason_is_exposed_for_women_restriction():
    result = evaluate_target_group({**profile("General"), "gender":"Male"}, {**scheme("women", "Business & Entrepreneurship"), "gender":"Female"})
    assert result["target_group_match"] == "not_matched"
