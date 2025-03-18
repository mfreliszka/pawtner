import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status

@pytest.mark.django_db
def test_login_successfully(client, registered_user, login_url, user_data):
    data = {
        "username": user_data["username"],
        "password": user_data["password"]
    }
    response = client.post(login_url, data=data, format="json")
    assert response.status_code == status.HTTP_200_OK
    assert "access" in response.data
    assert "refresh" in response.data

@pytest.mark.django_db
def test_login_wrong_password(client, registered_user):
    response = client.post(reverse("token_obtain_pair"), {"username": "testuser", "password": "wrongpass"}, format="json")
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

@pytest.mark.django_db
def test_login_nonexistent_user(client):
    response = client.post(reverse("token_obtain_pair"), {"username": "ghostuser", "password": "password123"}, format="json")
    assert response.status_code == status.HTTP_401_UNAUTHORIZED

@pytest.mark.django_db
def test_login_missing_fields(client):
    response = client.post(reverse("token_obtain_pair"), {"username": "testuser"}, format="json")
    assert response.status_code == status.HTTP_400_BAD_REQUEST

@pytest.mark.django_db
def test_login_case_insensitive_username(client, registered_user):
    response = client.post(reverse("token_obtain_pair"), {"username": "TESTUSER", "password": "strongpassword123"}, format="json")
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
