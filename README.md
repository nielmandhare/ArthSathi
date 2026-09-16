# ArthSathi ML Phase 1

This phase provides the data contract, validation, preprocessing, and deterministic splits. The canonical beneficiary fields are `beneficiary_id`, `age`, `income`, `location`, `social_category`, `education`, `business_type`, `loan_purpose`, `project_cost`, and `required_loan_amount`. Schemes use `scheme_id`, `scheme_name`, age/income limits, supported categories/locations/education/business types/purposes, loan limits, financial parameters, and `source_reference`.

`data/schemes_master.csv` is the source of truth for schemes and contains the cleaned government scheme dataset plus source metadata. `data/beneficiaries.csv` remains a small `DEMO/SYNTHETIC` fixture and is not real training data. `load_scheme_data` normalizes the master columns into the canonical scheme contract. The Phase 2 baseline in `ml/recommender.py` checks only explicit structured constraints, excludes criteria-not-met schemes, and ranks the rest by a deterministic match score. The score is the percentage of evaluated criteria satisfied; it is not an approval probability. Missing or ambiguous information produces `further_verification_required`. This baseline does not train a model, infer rules from free text, or guarantee eligibility. Install dependencies with `python -m pip install -r requirements.txt`, then run `python -m ml.sample_pipeline` and `python -m pytest -q` from the repository root.

## Phase 3 experimentation

Inspection of `schemes_master.csv` found no legitimate beneficiary outcome target: there are no scheme-selection, application, approval, rejection, or interaction labels. Therefore no supervised model is trained and no classification metrics are reported. `ml/features.py` creates deterministic beneficiary-scheme features from explicit structured fields only. `ml/models/similarity.py` provides an unlabeled structured similarity ranking experiment; Phase 2 remains the fallback deterministic recommendation baseline. `ml/evaluate.py` reports ranking diagnostics such as row count, score ordering, and identifier uniqueness, and refuses supervised evaluation without real labels.

The match score/model output is not government approval or approval probability. It measures structured compatibility only. Ambiguous or missing fields remain unknown and require verification; free-text eligibility is not converted into strict rules. Real beneficiary outcome data and a documented target definition are required before supervised learning or meaningful precision/recall/F1/AUC evaluation is valid.

## Phase 5 validation

Read-only validation of `data/schemes_master.csv` found 3,397 rows × 60 columns, zero duplicate scheme IDs, zero invalid numeric ranges, and no malformed structured list fields. Education, business type, project-cost ranges, and source references are consistently unavailable; source-reference presence is 0/3,397. Missing and unknown profile fields remain verification-required or are excluded when a known constraint is not met. Boundary, sparse, invalid, unknown-category, large-value, deterministic, JSON-safety, and no-result cases are covered by Phase 5 tests.

On the current environment, three load-inclusive real-dataset inference runs averaged 0.687492 seconds (minimum 0.666324, maximum 0.701596) across 3,397 schemes. This is a baseline measurement, not an ML performance metric. A live Uvicorn smoke request to `POST /api/recommendations` returned HTTP 200 with the stable JSON contract.

## Phase 6 evidence-aware ranking

Phase 5 exposed a sparse-evidence issue: compatibility was calculated only over available criteria, so one passing criterion could produce 100. Phase 6 preserves `match_score` as the compatibility score and adds `evidence_coverage` (`evaluated criteria / 9 total criteria`) and `ranking_score` (`compatibility_score × evidence_coverage / 100`). Final ordering uses ranking score, evidence coverage, compatibility, then stable `scheme_id` tie-breaking. Unknown criteria are listed in `verification_required` with grounded explanations, and missing data never becomes a passed criterion. A score of 100 is not approval, confidence, or a probability; results remain recommendations for further verification.

## Phase 4 inference API

`ml/inference.py` loads and validates `data/schemes_master.csv`, evaluates each scheme with the Phase 2 structured rules, and uses the stateless Phase 3 ranker for deterministic ordering. It returns only non-`criteria_not_met` results, preserves verification-required status, and includes source metadata. No training or artifact loading occurs during inference.

Run locally with `uvicorn api:app --reload`. The endpoint is `POST /api/recommendations`; send the beneficiary profile fields as JSON, for example `{"age":30,"income":200000,"location":"Maharashtra","social_category":"OBC","education":"graduate","business_type":"tailoring","loan_purpose":"working_capital","project_cost":100000,"required_loan_amount":50000}`. The response contains `profile`, `results`, and `total_candidates`; each result contains the scheme identity, compatibility score, eligibility status, reasons, unmet criteria, verification-required fields, and source references. The match score is a criteria-compatibility score, never approval probability or a government decision.

## Phase 7 semantic relevance

Relevance is separate from eligibility. The signal uses populated canonical fields: scheme name, official name, descriptions, category, subcategory, tags, supported purposes, and state/state requirement. It tokenizes normalized text and checks deterministic overlap with business type, loan purpose, location, and social category. Category-level domain signals prevent agriculture-only or education-only categories from receiving business-domain relevance merely because a description contains a broad word such as “business”. Empty fields remain unknown and do not create eligibility.

The final ranking score is `compatibility_score × evidence_coverage × relevance_score / 10000`. Compatibility measures evaluated structured criteria, evidence coverage measures evaluated criteria out of nine, and relevance measures documented intent/domain overlap. Relevance can improve ordering but cannot turn a failed criterion into eligibility. Outputs remain recommendations for verification, not approval decisions or approval probabilities.

Three load-inclusive Phase 7 runs over all 3,397 schemes averaged 1.364697 seconds (minimum 1.353408, maximum 1.385012), compared with the Phase 6 baseline of approximately 0.687 seconds. The extra cost comes from deterministic text tokenization; no model is trained and no semantic artifact is rebuilt outside the request path.

## Phase 8 target-group-aware ranking

Target-group evidence is separate from both eligibility and semantic relevance. `ml/target_groups.py` uses explicit `social_categories`, structured `gender`, and clearly stated Scheduled Caste/Tribe or women-targeting phrases. SC/ST variants are normalized. Missing or ambiguous target data is `unknown`, not ineligible. For ranking, matched target groups receive deterministic priority before the Phase 7 ranking score; unknown/general schemes remain candidates, while reliable non-matches are deprioritized. The response exposes `target_group_match`, `target_group_score`, and `target_group_evidence`. These fields describe ranking evidence only and do not indicate approval, confidence, or probability.

On the real dataset, the SC profile's top results included `bls`, `tls-delhi`, `acandabc`, `cegssc`, and `cmegp`, all with matched SC evidence. The ST profile's top results included `cmegp`, `sclcss`, `cts-maharashtra`, `aif`, and `ap`, all with matched ST evidence. Three load-inclusive SC inference runs averaged 1.949705 seconds across 3,397 schemes. This is a runtime measurement, not a recommendation-quality or approval metric.

## Phase 8.1 ranking calibration

Target-group evidence now breaks ties only after semantic/domain relevance is considered. Thus a relevant business scheme with general or unknown target evidence can outrank a weakly relevant SC/ST-targeted scheme, while matched SC/ST evidence still strengthens similarly relevant candidates. The API exposes `target_group_reason` alongside the existing target-group fields. Three calibrated SC inference runs averaged 2.009428 seconds across 3,397 schemes.

## Phase 8.2 calibrated ranking

Relevance is tiered before target-group ordering: `strongly_relevant`, `relevant`, `weakly_relevant`, or `unrelated`. Strong relevance requires at least three evaluable intent groups, at least 75% intent overlap, and at least four of nine structured criteria evidenced; relevant requires at least two evaluable intent groups, at least 50% overlap, and at least two structured criteria evidenced. Target-group priority is applied only within comparable tiers, so a weak or unrelated SC/ST-targeted scheme cannot outrank a strongly relevant general scheme. The API exposes `relevance_tier`, target-group fields, and ranking reasons.

Three calibrated SC inference runs averaged 4.909529 seconds across 3,397 schemes (minimum 4.733749, maximum 5.041060). This is runtime only; no supervised model or approval metric is involved.

## Phase 8.3 semantic relevance precision

Semantic relevance now removes generic tokens such as `business`, `loan`, `scheme`, `support`, `SC`, and `ST` from domain matching. Specific domain tokens and structured category/purpose evidence are required for meaningful matches; social-category evidence is handled only by target-group logic. Generic-only matches are capped below a perfect relevance score, and agriculture, transport, and education domains require corresponding profile intent. Five focused Phase 8.3 tests cover these distinctions. Three load-inclusive SC inference runs averaged 1.956604 seconds across 3,397 schemes.

## Phase 8.4 relevance calibration

Relevance now uses weighted evidence by field: exact structured domain or supported-purpose matches score strongest, related category matches score medium, descriptive text matches score lower, and generic business-purpose matches score weakly. SC/ST terms are excluded from semantic relevance and remain target-group evidence only. Relevance evidence and matched groups are returned for explanation. Generic small-business profiles no longer receive perfect relevance for broad categories, while explicit agriculture, transport, and education intent can produce strong relevance when supported by the dataset.

Three load-inclusive SC inference runs averaged 5.032936 seconds across 3,397 schemes (minimum 4.729977, maximum 5.236456). This is a runtime measurement only.

## Phase 8.5 relevance evidence sanity

Structured domain or purpose matches are now classified as corroborated only when supported by scheme name/description text. Structured-only evidence is medium strength, generic overlap is weak, and contradictory domain evidence is explicitly recorded. Relevance evidence exposes source fields, strength, corroboration, and contradiction. In the SC manual API checks, generic business returned 25/weakly_relevant, agriculture returned 72.5/relevant, and transport returned 27.5/weakly_relevant. Three load-inclusive SC runs averaged 5.979209 seconds across 3,397 schemes.

## Phase 8.6 intent/domain separation

Business-domain evidence now activates only for business, enterprise, agriculture, transport, or comparable activity intent. Student and education profiles are represented through education and loan-purpose evidence instead of being labeled as business matches. SC/ST remains target-group evidence only. Missing or ambiguous intent remains unknown, and eligibility calculations are unchanged.

Four real API smoke profiles returned HTTP 200 with valid JSON: SC education (top relevance 45, weakly relevant), SC agriculture (72.5, relevant), SC transport (27.5, weakly relevant), and generic SC business (25, weakly relevant). Three load-inclusive SC education inference runs averaged 6.324558 seconds across 3,397 schemes.
