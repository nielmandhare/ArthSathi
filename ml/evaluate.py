"""Evaluation utilities that do not invent labels or performance metrics."""
import pandas as pd

def ranking_diagnostics(ranked):
    """Return quality checks for an unlabeled ranking, not model performance."""
    scores = ranked["match_score"].tolist() if "match_score" in ranked else []
    return {"rows": len(ranked), "scores_non_increasing": scores == sorted(scores, reverse=True), "unique_scheme_ids": ranked["scheme_id"].is_unique if "scheme_id" in ranked else True}

def compare_rankings(experimental, baseline, k=None):
    """Compare overlap/order descriptively; requires no outcome labels."""
    k = k or min(len(experimental), len(baseline))
    a, b = list(experimental[:k]), list(baseline[:k])
    return {"k": k, "overlap": len(set(a) & set(b)), "experimental_ids": a, "baseline_ids": b}

def evaluate_labeled_predictions(y_true, y_pred):
    """Explicitly refuse accidental supervised evaluation without a target."""
    raise ValueError("No legitimate beneficiary outcome labels are available; supervised evaluation is disabled")
