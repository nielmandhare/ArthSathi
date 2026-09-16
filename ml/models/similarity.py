"""A no-label structured similarity ranking experiment."""
from ..features import build_feature_matrix

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
        ranked = features.sort_values(["match_score", "scheme_id"], ascending=[False, True], kind="mergesort")
        return ranked.head(self.top_k if top_k is None else top_k).reset_index(drop=True)

    def predict(self, profile, schemes=None):
        return self.rank(profile, schemes)
