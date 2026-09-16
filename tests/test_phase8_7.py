from ml.calibration import classify_relevance
from ml.relevance import evaluate_relevance


def profile(business, purpose, social="SC"):
    return {"age": 25, "income": 300000, "location": "Maharashtra", "social_category": social,
            "education": "Graduate", "business_type": business, "loan_purpose": purpose,
            "project_cost": 500000, "required_loan_amount": 300000}


def scheme(name, category, purpose, description="", target="SC"):
    return {"scheme_name": name, "official_scheme_name": name, "category": category,
            "subcategory": "", "tags": "", "short_description": description,
            "detailed_description": description, "supported_purposes": purpose,
            "social_categories": target, "state": "Maharashtra"}


def test_primary_education_title_and_structured_fields_match():
    result = evaluate_relevance(profile("Student", "Education"), scheme("Education Loan Scheme", "Education", "Education"))
    assert "education_domain" in result["matched_relevance_groups"]
    assert result["relevance_evidence"][-1]["corroborated"] is True


def test_scholarship_matches_education_intent():
    result = evaluate_relevance(profile("Student", "Education"), scheme("Scholarship Scheme", "Scholarship", "Education"))
    assert "education_domain" in result["matched_relevance_groups"]


def test_incidental_education_text_does_not_establish_primary_intent():
    p = profile("Student", "Education")
    for row in (
        scheme("Agricultural Extension", "Agriculture", "Agriculture", "training and education for students"),
        scheme("Agriculture Support", "Agriculture", "Agriculture", "student education and training"),
        scheme("Transport Loan", "Transport", "Transport", "education and student training"),
        scheme("Grant For Organizing Conference", "Grant", "Grant", "students and education may attend"),
    ):
        result = evaluate_relevance(p, row)
        assert "education_domain" not in result["matched_relevance_groups"]
        assert all(e["group"] != "education_domain" or e["value"] == 0 for e in result["relevance_evidence"])


def test_generic_business_and_social_text_do_not_create_education_relevance():
    result = evaluate_relevance(profile("Small Business", "Business"), scheme("General SC Business Support", "Business", "Business", "SC/ST support"))
    assert "education_domain" not in result["matched_relevance_groups"]


def test_score_and_tier_are_consistent_and_deterministic():
    row = scheme("Education Loan Scheme", "Education", "Education")
    first = evaluate_relevance(profile("Student", "Education"), row)
    second = evaluate_relevance(profile("Student", "Education"), row)
    assert first == second
    tier = classify_relevance(first["relevance_score"], first["relevance_evaluated"], 100)
    assert tier in {"strongly_relevant", "relevant", "weakly_relevant"}
