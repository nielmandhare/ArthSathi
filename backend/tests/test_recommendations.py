import os

os.environ.setdefault("MONGO_URL", "mongodb://localhost:27017")
os.environ.setdefault("DB_NAME", "arthsathi_test")
os.environ["ML_SERVICE_URL"] = "http://ml.test"

import httpx
import pytest
from fastapi.testclient import TestClient

from backend import server


client = TestClient(server.app)


PROFILE = {
    "age": 34,
    "income": 300000,
    "location": "Maharashtra",
    "social_category": "OBC",
    "education": "ITI",
    "business_type": "Tailoring",
    "loan_purpose": "working capital",
    "project_cost": 400000,
    "required_loan_amount": 250000,
}


def upstream_response(payload, status_code=200):
    return httpx.Response(status_code, json=payload, request=httpx.Request("POST", "http://ml.test/api/recommendations"))


@pytest.mark.anyio
async def test_recommendations_forwards_profile_and_preserves_response(monkeypatch):
    captured = {}

    class MockClient:
        def __init__(self, *args, **kwargs):
            captured["timeout"] = kwargs["timeout"]

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def post(self, url, json):
            captured["url"] = url
            captured["json"] = json
            return upstream_response({"profile": PROFILE, "results": [{"scheme_id": "x", "match_score": 80}], "total_candidates": 1, "extra": "kept"})

    monkeypatch.setattr(server.httpx, "AsyncClient", MockClient)
    response = client.post("/api/recommendations", json=PROFILE)
    assert response.status_code == 200
    assert captured["url"] == "http://ml.test/api/recommendations"
    assert captured["json"] == PROFILE
    assert response.json()["extra"] == "kept"


def test_invalid_request_is_rejected_before_upstream():
    response = client.post("/api/recommendations", json={"age": -1})
    assert response.status_code == 422


@pytest.mark.anyio
async def test_upstream_timeout_maps_to_gateway_timeout(monkeypatch):
    class MockClient:
        def __init__(self, *args, **kwargs): pass
        async def __aenter__(self): return self
        async def __aexit__(self, *args): return False
        async def post(self, *args, **kwargs): raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(server.httpx, "AsyncClient", MockClient)
    assert client.post("/api/recommendations", json=PROFILE).status_code == 504


@pytest.mark.anyio
async def test_upstream_error_and_malformed_response(monkeypatch):
    class MockClient:
        def __init__(self, *args, **kwargs): pass
        async def __aenter__(self): return self
        async def __aexit__(self, *args): return False
        async def post(self, *args, **kwargs): return upstream_response({"detail": "invalid profile"}, 422)

    monkeypatch.setattr(server.httpx, "AsyncClient", MockClient)
    assert client.post("/api/recommendations", json=PROFILE).status_code == 422

    class MalformedClient(MockClient):
        async def post(self, *args, **kwargs): return upstream_response({"results": []})

    monkeypatch.setattr(server.httpx, "AsyncClient", MalformedClient)
    assert client.post("/api/recommendations", json=PROFILE).status_code == 502
