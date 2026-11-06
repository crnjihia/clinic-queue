# path: Makefile
.PHONY: all setup dev test lint build emulator clean help

help:
	@echo "Clinic Queue Build Automation"
	@echo "Available targets:"
	@echo "  make setup     - Install Flutter dependencies and Node function modules"
	@echo "  make dev       - Run Flutter app in dev flavor against local emulators"
	@echo "  make emulator  - Start Firebase Emulator Suite (Auth, Firestore, Functions)"
	@echo "  make test      - Run all unit and BLoC tests in Flutter and Functions"
	@echo "  make lint      - Run strict static analysis on Dart and TypeScript code"
	@echo "  make build     - Build release Android APK for staging flavor"
	@echo "  make clean     - Clean Flutter and Node build artifacts"

setup:
	@echo "==> Setting up root dependencies..."
	@if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; echo "Created .env from .env.example"; fi
	@echo "==> Setting up mobile application dependencies..."
	cd apps/mobile && flutter pub get
	@echo "==> Setting up Cloud Functions dependencies..."
	if [ -d functions ]; then cd functions && npm install; fi

dev:
	@echo "==> Running Clinic Queue in DEV flavor..."
	cd apps/mobile && flutter run -t lib/main_dev.dart --flavor dev

emulator:
	@echo "==> Starting Firebase Emulator Suite..."
	firebase emulators:start --only auth,firestore,functions

test:
	@echo "==> Running Flutter unit and BLoC tests..."
	cd apps/mobile && flutter test
	@if [ -d functions/tests ]; then echo "==> Running Cloud Functions tests..."; cd functions && npm test; fi

lint:
	@echo "==> Running Flutter analyzer..."
	cd apps/mobile && flutter analyze --fatal-infos
	@if [ -d functions ]; then echo "==> Running ESLint on Cloud Functions..."; cd functions && npm run lint; fi

build:
	@echo "==> Building Android APK (staging flavor)..."
	cd apps/mobile && flutter build apk --flavor staging -t lib/main_staging.dart

clean:
	@echo "==> Cleaning mobile and function artifacts..."
	cd apps/mobile && flutter clean
	if [ -d functions ]; then rm -rf functions/lib functions/node_modules; fi
