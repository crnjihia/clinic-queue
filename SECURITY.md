<!-- path: SECURITY.md -->
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of healthcare data, queue integrity, and payment workflows seriously.

If you discover a security vulnerability in Clinic Queue:
1. **Do not open a public GitHub issue.**
2. Email vulnerability details to `security@clinicqueue.ke` (or contact the maintainer Chris directly on GitHub).
3. Include detailed steps to reproduce the issue, proof of concept, and affected versions.
4. We will acknowledge receipt within 48 hours and provide a remediation timeline.

## Privacy Guidelines

- **Zero Medical Data in Firestore**: Clinic Queue intentionally stores no diagnosis, medical records, or prescriptions. Only queue ticket tokens, timestamps, and minimal appointment reason codes are permitted.
- **Role-Guarded Operations**: All queue mutations (calling a patient, marking in-service or completed) must be strictly gated by verified `staff` roles in Firestore Security Rules.
