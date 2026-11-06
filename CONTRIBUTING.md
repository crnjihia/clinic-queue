<!-- path: CONTRIBUTING.md -->
# Contributing to Clinic Queue

Thank you for your interest in contributing to **Clinic Queue** (*Foleni wa Kliniki*). We welcome contributions from developers passionate about healthcare accessibility, mobile resilience, and Kenyan digital health infrastructure.

## Development Workflow

1. Fork the repository and create your branch from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```
2. Set up local development environment:
   ```bash
   make setup
   ```
3. Run the application with the Firebase Emulator Suite:
   ```bash
   make emulator
   make dev
   ```
4. Run tests and static analysis:
   ```bash
   make test
   make lint
   ```

## Commit Conventions

We strictly enforce **Conventional Commits**:
- `feat(scope): add patient ticket cancellation stream`
- `fix(scope): handle null fcm token on sign-in`
- `test(scope): add unit test for rolling average service time`
- `docs(scope): update emulator setup guide`

Keep summaries to 72 characters or fewer, imperative tense, with a descriptive body explaining the *why* rather than just the *how*.

## Pull Request Checklist

- [ ] Strict Dart analysis passes (`flutter analyze` with 0 issues).
- [ ] Unit and BLoC tests pass with 100% success rate.
- [ ] Golden tests updated if visual UI changes were made.
- [ ] No hard-coded credentials, API keys, or patient medical details.
- [ ] Localization strings added to both `app_en.arb` and `app_sw.arb`.
