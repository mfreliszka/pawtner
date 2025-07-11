# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is a full-stack pet family management application with a Django REST API backend and Flutter mobile frontend.

### Backend (Django)
- **Framework**: Django 5.1.7 with Django REST Framework
- **Authentication**: JWT-based authentication using `djangorestframework-simplejwt`
- **Database**: PostgreSQL with UUID primary keys for all models
- **Custom User Model**: `PawtnerUser` in `pawtner.user.models:11`
- **Apps Structure**:
  - `pawtner.user`: User authentication and profiles
  - `pawtner.pets`: Pet management with species/breed support
  - `pawtner.family`: Family grouping system with admin/member roles
  - `pawtner.notifications`: User notifications (placeholder)
  - `pawtner.events`: Event management (placeholder)

### Frontend (Flutter)
- **Framework**: Flutter 3.7.0+ with Riverpod for state management
- **Authentication**: JWT tokens stored in secure storage
- **State Management**: Riverpod with `AuthNotifier` in `frontend/lib/auth_provider.dart:57`
- **Environment**: Configuration loaded from `.env` file
- **Navigation**: Route generator pattern in `frontend/lib/route_generator.dart`

## Development Commands

### Backend
```bash
# Run development server
make run
# Alternative: python manage.py runserver 0.0.0.0:8000

# Linting and formatting
make lint          # Check code style with ruff
make format        # Format code with ruff

# Testing
pytest             # Run all tests
pytest tests/user/ # Run specific test module
```

### Frontend
```bash
cd frontend

# Install dependencies
flutter pub get
# Alternative: make flutter-get

# Run on emulator
flutter run
# Or launch specific emulator: make run-emulator

# Testing
flutter test
```

## Database Configuration

The application uses PostgreSQL with environment variables:
- `DB_NAME` (default: myproject)
- `DB_USER` (default: myprojectuser)
- `DB_PASSWORD` (default: mypassword)
- `DB_HOST` (default: localhost)
- `DB_PORT` (default: 5432)

## API Structure

- **Base URL**: Configured in `frontend/lib/api_endpoints.dart`
- **Authentication**: Bearer token in Authorization header
- **Documentation**: Available at `/docs/` (Swagger) and `/redoc/` (ReDoc)
- **Schema**: Available at `/schema/`

### Key Endpoints
- `POST /user/login/`: User authentication
- `POST /user/register/`: User registration
- `GET /user/default/`: User profile details
- `GET|POST /pets/`: Pet management
- `GET|POST /family/`: Family management

## Model Relationships

- **User → Profile**: One-to-one relationship with automatic profile creation
- **User → Pets**: One-to-many (owner relationship)
- **User → Families**: Many-to-many (owner, admin, member roles)
- **Pet → Family**: Many-to-one (pets belong to families)
- **Family → Users**: Many-to-many with separate admin/member relationships

## Flutter State Management

The app uses Riverpod with a centralized `AuthState` that manages:
- User authentication status
- User profile data
- User's pets list
- User's families list
- Loading states and error handling

Auto-login is implemented using secure storage for JWT tokens with automatic refresh capability.

## Testing

- **Backend**: Uses pytest-django with configuration in `pytest.ini`
- **Frontend**: Uses Flutter's built-in testing framework
- **Test Structure**: Tests are organized by app modules in `tests/` directory

## Key Files to Understand

- `config/settings.py`: Django configuration with JWT and CORS setup
- `pawtner/user/models.py`: Custom user model with UUID primary keys
- `frontend/lib/auth_provider.dart`: Complete authentication flow
- `frontend/lib/models.dart`: Data models for API responses
- `pawtner/pets/species.py`: Pet species and breed definitions