import { toRecommendationRequest } from './recommendationMapper';

const API_BASE_URL = (process.env.REACT_APP_API_BASE_URL || '').replace(/\/$/, '');

export class RecommendationApiError extends Error {
  constructor(message, kind, status) {
    super(message);
    this.name = 'RecommendationApiError';
    this.kind = kind;
    this.status = status;
  }
}

function classifyStatus(status) {
  if (status === 422) return 'validation';
  if (status === 503) return 'unavailable';
  if (status === 504) return 'timeout';
  return 'backend';
}

export function fromRecommendationResponse(payload) {
  if (
    !payload ||
    typeof payload !== 'object' ||
    !payload.profile ||
    typeof payload.profile !== 'object' ||
    !Array.isArray(payload.results) ||
    typeof payload.total_candidates !== 'number'
  ) {
    throw new RecommendationApiError('Recommendation response is malformed', 'malformed');
  }

  return {
    profile: payload.profile,
    totalCandidates: payload.total_candidates,
    recommendations: payload.results.map((result) => {
      const aliases = {};
      // These aliases are presentation conveniences; never replace fields
      // already supplied by the authoritative ML response.
      if (!Object.prototype.hasOwnProperty.call(result, 'id')) aliases.id = result.scheme_id;
      if (!Object.prototype.hasOwnProperty.call(result, 'name')) aliases.name = result.scheme_name;
      if (!Object.prototype.hasOwnProperty.call(result, 'match')) aliases.match = result.match_score;
      if (!Object.prototype.hasOwnProperty.call(result, 'recommendationScore')) {
        aliases.recommendationScore = result.ranking_score;
      }
      return { ...result, ...aliases };
    }),
    raw: payload,
  };
}

export async function fetchRecommendations(state, options = {}) {
  const request = toRecommendationRequest(state);
  let response;

  try {
    response = await fetch(`${API_BASE_URL}/api/recommendations`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(request),
      signal: options.signal,
    });
  } catch (error) {
    if (error?.name === 'AbortError') throw error;
    throw new RecommendationApiError('Recommendation backend is unavailable', 'unavailable');
  }

  let payload;
  try {
    payload = await response.json();
  } catch (error) {
    throw new RecommendationApiError('Recommendation backend returned invalid JSON', 'malformed', response.status);
  }

  if (!response.ok) {
    const detail = typeof payload?.detail === 'string' ? payload.detail : 'Recommendation request failed';
    throw new RecommendationApiError(detail, classifyStatus(response.status), response.status);
  }

  return fromRecommendationResponse(payload);
}
