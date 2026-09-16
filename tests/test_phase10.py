from ml.evaluation import BENCHMARK_CASES, evaluate_benchmark


def test_benchmark_is_machine_readable_and_complete():
    result = evaluate_benchmark()
    assert len(result["cases"]) == 9
    assert result["aggregate"]["case_count"] == 9
    assert all("top_1_domain_hit" in case and "score_tier_consistent" in case for case in result["cases"])


def test_benchmark_has_required_scenarios():
    ids = {case["case_id"] for case in BENCHMARK_CASES}
    assert {"sc_education", "sc_agriculture", "sc_transport", "sc_business", "st_agriculture", "general_business", "underspecified"} <= ids


def test_benchmark_repeated_results_are_deterministic():
    first = evaluate_benchmark()
    second = evaluate_benchmark()
    assert first["cases"] == second["cases"]


def test_benchmark_keeps_unrelated_and_score_tier_checks():
    result = evaluate_benchmark()
    assert all(case["score_tier_consistent"] for case in result["cases"])
    assert result["aggregate"]["unrelated_suppression_rate"] == 1.0
