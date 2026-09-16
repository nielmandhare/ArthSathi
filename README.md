# ArthSathi ML Phase 1

This phase provides the data contract, validation, preprocessing, and deterministic splits. The canonical beneficiary fields are `beneficiary_id`, `age`, `income`, `location`, `social_category`, `education`, `business_type`, `loan_purpose`, `project_cost`, and `required_loan_amount`. Schemes use `scheme_id`, `scheme_name`, age/income limits, supported categories/locations/education/business types/purposes, loan limits, financial parameters, and `source_reference`.

`data/schemes_master.csv` is the source of truth for schemes and contains the cleaned government scheme dataset plus source metadata. `data/beneficiaries.csv` remains a small `DEMO/SYNTHETIC` fixture and is not real training data. `load_scheme_data` normalizes the master columns into the canonical scheme contract. The Phase 2 baseline in `ml/recommender.py` checks only explicit structured constraints, excludes criteria-not-met schemes, and ranks the rest by a deterministic match score. The score is the percentage of evaluated criteria satisfied; it is not an approval probability. Missing or ambiguous information produces `further_verification_required`. This baseline does not train a model, infer rules from free text, or guarantee eligibility. Install dependencies with `python -m pip install -r requirements.txt`, then run `python -m ml.sample_pipeline` and `python -m pytest -q` from the repository root.

## Phase 3 experimentation

Inspection of `schemes_master.csv` found no legitimate beneficiary outcome target: there are no scheme-selection, application, approval, rejection, or interaction labels. Therefore no supervised model is trained and no classification metrics are reported. `ml/features.py` creates deterministic beneficiary-scheme features from explicit structured fields only. `ml/models/similarity.py` provides an unlabeled structured similarity ranking experiment; Phase 2 remains the fallback deterministic recommendation baseline. `ml/evaluate.py` reports ranking diagnostics such as row count, score ordering, and identifier uniqueness, and refuses supervised evaluation without real labels.

The match score/model output is not government approval or approval probability. It measures structured compatibility only. Ambiguous or missing fields remain unknown and require verification; free-text eligibility is not converted into strict rules. Real beneficiary outcome data and a documented target definition are required before supervised learning or meaningful precision/recall/F1/AUC evaluation is valid.

## Phase 5 validation

Read-only validation of `data/schemes_master.csv` found 3,397 rows × 60 columns, zero duplicate scheme IDs, zero invalid numeric ranges, and no malformed structured list fields. Education, business type, project-cost ranges, and source references are consistently unavailable; source-reference presence is 0/3,397. Missing and unknown profile fields remain verification-required or are excluded when a known constraint is not met. Boundary, sparse, invalid, unknown-category, large-value, deterministic, JSON-safety, and no-result cases are covered by Phase 5 tests.

On the current environment, three load-inclusive real-dataset inference runs averaged 0.672311 seconds (minimum 0.644860, maximum 0.691130) across 3,397 schemes. This is a baseline measurement, not an ML performance metric. A live Uvicorn smoke request to `POST /api/recommendations` returned HTTP 200 with the stable JSON contract.

## Phase 4 inference API

`ml/inference.py` loads and validates `data/schemes_master.csv`, evaluates each scheme with the Phase 2 structured rules, and uses the stateless Phase 3 ranker for deterministic ordering. It returns only non-`criteria_not_met` results, preserves verification-required status, and includes source metadata. No training or artifact loading occurs during inference.

Run locally with `uvicorn api:app --reload`. The endpoint is `POST /api/recommendations`; send the beneficiary profile fields as JSON, for example `{"age":30,"income":200000,"location":"Maharashtra","social_category":"OBC","education":"graduate","business_type":"tailoring","loan_purpose":"working_capital","project_cost":100000,"required_loan_amount":50000}`. The response contains `profile`, `results`, and `total_candidates`; each result contains the scheme identity, compatibility score, eligibility status, reasons, unmet criteria, verification-required fields, and source references. The match score is a criteria-compatibility score, never approval probability or a government decision.
