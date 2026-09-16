import pandas as pd
from ml.calibration import classify_relevance
from ml.models import StructuredSimilarityRanker
from tests.test_phase8_1 import profile, scheme

def test_sparse_relevance_is_not_automatically_strong():
    assert classify_relevance(100, 1, 11.11) == "weakly_relevant"
    assert classify_relevance(100, 3, 44.44) == "strongly_relevant"

def test_strong_general_beats_weak_targeted():
    data = pd.DataFrame([scheme("targeted-weak", "Agriculture,Rural & Environment", "SC", "Business"), scheme("general-strong", "Business & Entrepreneurship", None)])
    ranked = StructuredSimilarityRanker(top_k=2).fit(data).rank(profile())
    assert list(ranked.scheme_id) == ["general-strong", "targeted-weak"]

def test_strong_targeted_beats_strong_general_within_tier():
    data = pd.DataFrame([scheme("general", "Business & Entrepreneurship", None), scheme("targeted", "Business & Entrepreneurship", "SC")])
    ranked = StructuredSimilarityRanker(top_k=2).fit(data).rank(profile())
    assert ranked.iloc[0].scheme_id == "targeted"
