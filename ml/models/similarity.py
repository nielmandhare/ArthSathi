"""A no-label structured similarity ranking experiment."""
from ..features import build_feature_matrix
from ..calibration import TIER_ORDER

class StructuredSimilarityRanker:
    """Ranks schemes by explicit structured compatibility features.

    This has no fit-to-outcomes step and must not be interpreted as approval
    prediction. Phase 2 remains the production-compatible fallback baseline.
    """
    def __init__(self, top_k=10):
        if top_k < 0: raise ValueError("top_k must be non-negative")
        self.top_k = top_k
        self._schemes = None

    def fit(self, schemes):
        self._schemes = schemes.copy()
        return self

    def rank(self, profile, schemes=None, top_k=None):
        frame = schemes if schemes is not None else self._schemes
        if frame is None: raise ValueError("fit must be called or schemes supplied")
        features = build_feature_matrix(profile, frame)
        features = features[features["eligibility_status"] != "criteria_not_met"]
        priority = {"matched": 2, "unknown": 1, "not_matched": 0}
        features = features.assign(_target_priority=features["target_group_match"].map(priority).fillna(1))
        # Target evidence is conditional on the relevance tier. It cannot
        # rescue a weak or unrelated scheme with sparse evidence.
        features = features.assign(_relevance_priority=features["relevance_tier"].map(TIER_ORDER).fillna(0))
        ranked = features.sort_values(["_relevance_priority", "_target_priority", "ranking_score", "evidence_coverage", "match_score", "scheme_id"], ascending=[False, False, False, False, False, True], kind="mergesort")
        return ranked.head(self.top_k if top_k is None else top_k).reset_index(drop=True)

    def predict(self, profile, schemes=None):
        return self.rank(profile, schemes)
