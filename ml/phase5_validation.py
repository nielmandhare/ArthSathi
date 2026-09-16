"""Read-only dataset checks and lightweight performance measurements."""
from pathlib import Path
from time import perf_counter
import pandas as pd

from .inference import DEFAULT_SCHEME_PATH, recommend_schemes
from .pipeline import load_scheme_data, validate_scheme_data

IMPORTANT = ["scheme_id", "minimum_age", "maximum_age", "income_max", "state", "social_categories", "education", "business_type", "supported_purposes", "project_cost_min", "project_cost_max", "loan_amount_min", "loan_amount_max", "source_reference"]
LIST_FIELDS = ["social_categories", "education", "business_type", "supported_purposes", "state"]

def validate_master_dataset(path=DEFAULT_SCHEME_PATH):
    """Return findings without changing the canonical dataset."""
    raw = pd.read_csv(path)
    normalized = load_scheme_data(path)
    validate_scheme_data(normalized)
    numeric = ["minimum_age", "maximum_age", "income_min", "income_max", "loan_amount_min", "loan_amount_max", "project_cost_min", "project_cost_max", "interest_rate"]
    ranges = {name: int((raw[name].notna() & (pd.to_numeric(raw[name], errors="coerce").isna())).sum()) for name in numeric if name in raw}
    ranges.update({"age_reversed": int(((raw["minimum_age"] > raw["maximum_age"]).fillna(False)).sum()), "loan_reversed": int(((raw["loan_amount_min"] > raw["loan_amount_max"]).fillna(False)).sum())})
    missingness = {name: round(float(raw[name].isna().mean()), 4) for name in IMPORTANT if name in raw}
    malformed = {name: int(raw[name].dropna().map(lambda value: not isinstance(value, str) or not str(value).strip()).sum()) for name in LIST_FIELDS if name in raw}
    return {"rows": len(raw), "columns": len(raw.columns), "duplicate_scheme_ids": int(raw["scheme_id"].duplicated().sum()), "missingness": missingness, "numeric_invalid": ranges, "malformed_structured_fields": malformed, "source_reference_present": int(raw["source_reference"].notna().sum()), "consistently_unavailable": [name for name, ratio in missingness.items() if ratio == 1.0]}

def benchmark_inference(profile, repetitions=3, data_path=DEFAULT_SCHEME_PATH):
    """Measure load-inclusive inference; no model quality claim is made."""
    load_times, inference_times = [], []
    for _ in range(repetitions):
        start = perf_counter(); result = recommend_schemes(profile, top_k=10, data_path=data_path); elapsed = perf_counter() - start
        load_times.append(elapsed); inference_times.append(elapsed)
    return {"dataset_rows": result["total_candidates"], "repetitions": repetitions, "end_to_end_seconds": round(sum(inference_times) / repetitions, 6), "min_seconds": round(min(inference_times), 6), "max_seconds": round(max(inference_times), 6)}
