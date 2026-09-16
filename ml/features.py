"""Structured beneficiary-scheme feature generation for unlabeled experiments."""
import numpy as np
import pandas as pd

from .recommender import BeneficiaryProfile, CRITERIA, evaluate_scheme

def _profile(value):
    return value if isinstance(value, BeneficiaryProfile) else BeneficiaryProfile.from_mapping(value)

def generate_pair_features(profile, scheme):
    """Create deterministic features from explicit structured compatibility only."""
    result = evaluate_scheme(_profile(profile), scheme)
    unmet = set(result["unmet_criteria"])
    unknown = set(result["verification_required"])
    features = {"scheme_id": result["scheme_id"], "scheme_name": result["scheme_name"], "eligibility_status": result["eligibility_status"]}
    for criterion in CRITERIA:
        features[f"{criterion}_match"] = np.nan if criterion in unknown else int(criterion not in unmet)
        features[f"{criterion}_known"] = int(criterion not in unknown)
    features["match_score"] = result["match_score"]
    features["compatibility_score"] = result["compatibility_score"]
    features["evidence_coverage"] = result["evidence_coverage"]
    features["ranking_score"] = result["ranking_score"]
    return features

def build_feature_matrix(profile, schemes):
    """Return one row per scheme; input row order is preserved."""
    return pd.DataFrame([generate_pair_features(profile, row) for _, row in schemes.iterrows()])
