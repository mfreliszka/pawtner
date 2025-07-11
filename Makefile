run:
	python manage.py runserver 0.0.0.0:8000
#	uvicorn config.asgi:application 0.0.0.0:8000 --reload

lint:
	ruff check .
	ruff format --check .

format:
	ruff format .

flutter-get:
	flutter pub get

run-emulator:
	flutter emulators --launch Pixel_7_API_35

# Run all Docker services
docker-up:
	@echo "Starting all Docker services..."
	docker compose up -d
	@echo "Docker services started."

# Build and run all Docker services
docker-build:
	@echo "Building and starting all Docker services..."
	docker compose up -d --build
	@echo "Docker services built and started."
