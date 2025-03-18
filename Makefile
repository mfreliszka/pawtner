run:
	uvicorn config.asgi:application --reload

lint:
	ruff check .
	ruff format --check .

format:
	ruff format .

flutter-get:
	flutter pub get