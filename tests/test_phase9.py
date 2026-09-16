from ml.calibration import classify_relevance
from ml.relevance import evaluate_relevance


def profile(business, purpose, social="SC"):
    return {"age": 25, "income": 300000, "location": "Maharashtra", "social_category": social,
            "education": "Graduate", "business_type": business, "loan_purpose": purpose,
            "project_cost": 500000, "required_loan_amount": 300000}


def row(name, category, purpose, description="", target="SC"):
    return {"scheme_name": name, "official_scheme_name": name, "category": category,
            "subcategory": "", "tags": "", "supported_purposes": purpose,
            "short_description": description, "detailed_description": description,
            "social_categories": target}


def test_near_domain_vocabulary_is_typed_and_explainable():
    result = evaluate_relevance(profile("Transport", "Transport"), row("Commercial Vehicle Support", "Mobility", "", "SC"))
    assert result["relevance_score"] > 0
    assert any(item["group"] == "business_domain" for item in result["relevance_evidence"])


def test_generic_and_incidental_text_remain_conservative():
    result = evaluate_relevance(profile("Small Business", "Business"), row("Agricultural Extension", "Agriculture", "Agriculture", "education and training for students"))
    assert result["relevance_score"] < 50
    assert "education_domain" not in result["matched_relevance_groups"]


def test_target_group_does_not_change_semantic_score():
    p = profile("Transport", "Transport", "SC")
    assert evaluate_relevance(p, row("Transport Scheme", "Transport", "Transport", target="SC"))["relevance_score"] == evaluate_relevance(p, row("Transport Scheme", "Transport", "Transport", target="General"))["relevance_score"]


def test_sparse_and_unrelated_scores_have_consistent_tiers():
    result = evaluate_relevance(profile("Transport", "Transport"), row("General Support", "", "", "vehicle mentioned incidentally"))
    assert classify_relevance(result["relevance_score"], result["relevance_evaluated"], 11.11) != "strongly_relevant"
    assert result == evaluate_relevance(profile("Transport", "Transport"), row("General Support", "", "", "vehicle mentioned incidentally"))
