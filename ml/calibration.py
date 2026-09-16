"""Transparent Phase 8.2 relevance tiers and conditional target ordering."""

TIER_ORDER = {"unrelated": 0, "weakly_relevant": 1, "relevant": 2, "strongly_relevant": 3}

def classify_relevance(relevance_score, relevance_evaluated, evidence_coverage):
    """Classify using count-based evidence thresholds, not learned weights.

    Strong relevance requires at least three of four intent groups to be
    evaluable and at least four of nine structured criteria to be evidenced.
    Relevant requires two intent groups and two structured criteria.
    """
    if relevance_score <= 0 or relevance_evaluated == 0: return "unrelated"
    if relevance_score >= 85 and relevance_evaluated >= 2 and evidence_coverage >= 44.44:
        return "strongly_relevant"
    if relevance_score >= 50 and relevance_evaluated >= 2 and evidence_coverage >= 22.22:
        return "relevant"
    return "weakly_relevant"
