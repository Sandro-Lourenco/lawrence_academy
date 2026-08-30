import sys
import os
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

# Add paths to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "src")))

os.environ["SUPABASE_URL"] = "https://mock.supabase.co"
os.environ["SUPABASE_SERVICE_KEY"] = "mock-key"
os.environ["STRIPE_API_KEY"] = "sk_test_mock"
os.environ["STRIPE_WEBHOOK_SECRET"] = "whsec_test_mock"

from src.main import app

client = TestClient(app)


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_profile_by_header(mock_db, mock_get_user):
    """Test retrieving profile using standard Authorization header."""
    mock_user = MagicMock()
    mock_user.id = "user_123"
    mock_user.email = "test@lawrence.academy"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = {
        "id": "user_123",
        "email": "test@lawrence.academy",
        "role": "student",
        "full_name": "Test User",
        "avatar_url": "https://avatar.url/123.png",
        "bio": "My biography",
        "certificate_name": "Test User Cert",
        "url_username": "testuser",
        "birth_date": "1995-10-15",
        "occupation": "Fashion Designer",
        "company": "Lawrence Atelier",
        "job_title": "Lead Dressmaker",
        "open_to_opportunities": True,
        "linkedin_url": "https://linkedin.com/in/test",
        "twitter_url": "https://twitter.com/test",
        "github_url": "https://github.com/test",
        "custom_url": "https://test.me",
        "academic_formations": [{"id": "1", "course": "Fashion Design", "institution": "Lawrence", "type": "bachelor"}],
    }
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_db_res

    response = client.get("/api/v1/profiles/me", headers={"Authorization": "Bearer some_token"})
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "user_123"
    assert data["full_name"] == "Test User"
    assert data["avatar_url"] == "https://avatar.url/123.png"
    assert data["bio"] == "My biography"
    assert data["birth_date"] == "1995-10-15"
    assert data["open_to_opportunities"] is True
    assert len(data["academic_formations"]) == 1


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_profile_by_cookie(mock_db, mock_get_user):
    """Test retrieving profile using sb-access-token cookie fallback."""
    mock_user = MagicMock()
    mock_user.id = "user_456"
    mock_user.email = "cookie@lawrence.academy"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = {
        "id": "user_456",
        "email": "cookie@lawrence.academy",
        "role": "student",
        "full_name": "Cookie User",
        "avatar_url": None,
        "bio": None,
    }
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_db_res

    # Send request without Authorization header but with cookie
    response = client.get("/api/v1/profiles/me", cookies={"sb-access-token": "some_cookie_token"})
    assert response.status_code == 200
    assert response.json()["full_name"] == "Cookie User"
    # Ensure auth was called with the cookie token
    mock_get_user.assert_called_with("some_cookie_token")


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_update_profile_all_fields(mock_db, mock_get_user):
    """Test updating all profile fields."""
    mock_user = MagicMock()
    mock_user.id = "user_123"
    mock_user.email = "test@lawrence.academy"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = [{
        "id": "user_123",
        "email": "test@lawrence.academy",
        "role": "student",
        "full_name": "Updated Name",
        "avatar_url": "https://avatar.url/updated.png",
        "bio": "New Bio",
        "certificate_name": "Updated Cert Name",
        "url_username": "newusername",
        "birth_date": "1990-01-01",
        "occupation": "Tailor",
        "company": "Moda Inc",
        "job_title": "Pattern Maker",
        "open_to_opportunities": False,
        "linkedin_url": "https://linkedin.com/in/new",
        "twitter_url": "https://twitter.com/new",
        "github_url": "https://github.com/new",
        "custom_url": "https://new.me",
        "academic_formations": [{"id": "2"}],
    }]
    mock_db.table.return_value.update.return_value.eq.return_value.execute.return_value = mock_db_res

    update_payload = {
        "full_name": "Updated Name",
        "avatar_url": "https://avatar.url/updated.png",
        "bio": "New Bio",
        "certificate_name": "Updated Cert Name",
        "url_username": "newusername",
        "birth_date": "1990-01-01",
        "occupation": "Tailor",
        "company": "Moda Inc",
        "job_title": "Pattern Maker",
        "open_to_opportunities": False,
        "linkedin_url": "https://linkedin.com/in/new",
        "twitter_url": "https://twitter.com/new",
        "github_url": "https://github.com/new",
        "custom_url": "https://new.me",
        "academic_formations": [{"id": "2"}],
    }

    response = client.put("/api/v1/profiles/me", json=update_payload, headers={"Authorization": "Bearer token"})
    assert response.status_code == 200
    res_data = response.json()
    assert res_data["status"] == "success"
    profile_data = res_data["data"][0]
    assert profile_data["full_name"] == "Updated Name"
    assert profile_data["avatar_url"] == "https://avatar.url/updated.png"
    assert profile_data["bio"] == "New Bio"
    assert profile_data["open_to_opportunities"] is False
    assert len(profile_data["academic_formations"]) == 1
