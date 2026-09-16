import { toRecommendationRequest } from './recommendationMapper';
import { fromRecommendationResponse } from './recommendations';

const state = {
  profile: {
    age: 34,
    monthlyIncome: 25000,
    district: 'Pune',
    state: 'Maharashtra',
    category: 'OBC',
    education: 'ITI — Sewing Technology',
    business: 'Tailoring & Boutique',
  },
  requirement: {
    purpose: 'Expand my boutique',
    projectCost: 400000,
    loanAmount: 250000,
    businessType: 'Tailoring & Boutique',
  },
};

test('maps AppContext state to the exact backend field names', () => {
  expect(toRecommendationRequest(state)).toEqual({
    age: 34,
    income: 25000,
    location: 'Maharashtra',
    social_category: 'OBC',
    education: 'ITI — Sewing Technology',
    business_type: 'Tailoring & Boutique',
    loan_purpose: 'Expand my boutique',
    project_cost: 400000,
    required_loan_amount: 250000,
  });
});

test('keeps optional numeric fields null', () => {
  const request = toRecommendationRequest({ profile: {}, requirement: {} });
  expect(request.age).toBeNull();
  expect(request.income).toBeNull();
  expect(request.project_cost).toBeNull();
  expect(request.required_loan_amount).toBeNull();
});

test('preserves original ML fields while adding UI-safe aliases', () => {
  const result = fromRecommendationResponse({
    profile: {},
    total_candidates: 1,
    results: [{ scheme_id: 'x', scheme_name: 'Scheme X', match_score: 80, ranking_score: 70 }],
  }).recommendations[0];
  expect(result.scheme_id).toBe('x');
  expect(result.match_score).toBe(80);
  expect(result.recommendationScore).toBe(70);
});

test('does not overwrite response fields that share an alias name', () => {
  const result = fromRecommendationResponse({
    profile: {},
    total_candidates: 1,
    results: [{ scheme_id: 'x', scheme_name: 'Scheme X', match_score: 80, id: 'authoritative-id' }],
  }).recommendations[0];
  expect(result.id).toBe('authoritative-id');
  expect(result.scheme_id).toBe('x');
});
