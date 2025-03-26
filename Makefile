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