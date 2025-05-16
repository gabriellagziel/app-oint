# Repository Overview: app-oint

This document provides a comprehensive overview of the repository's configuration, automation, and security settings. Update this file as your repo evolves.

---

## 1. Workflows
List of all GitHub Actions workflows in `.github/workflows/`:

| Workflow File                | Purpose                        | Triggers           |
|------------------------------|--------------------------------|--------------------|
| flutter.yml                  | CI: Build, lint, test, coverage| push, PR to main   |
| firebase-deploy.yml          | Deploy to Firebase Hosting     | push to main       |
| release.yml                  | Build & attach release assets  | tag v*.*.*         |

---

## 2. Secrets (Names Only)
List of all repository secrets (Settings → Secrets and variables → Actions):

- `FIREBASE_SERVICE_ACCOUNT` (for Firebase deploy)
- `CODECOV_TOKEN` (if private repo)
- (Add others as needed)

---

## 3. Branch Protection
- **Protected branch:** `main`
- **Rules enabled:**
  - Require pull request before merging
  - Require status checks to pass (`build`)
  - Require branches to be up to date before merging
  - Block force pushes
  - Block deletions
  - (Optional) Require PR reviews, conversation resolution, etc.

---

## 4. Collaborators & Permissions
- List all collaborators and their roles (admin, write, read)
- (Update as your team changes)

---

## 5. Integrations
- **Codecov:** Test coverage reporting
- **Firebase Hosting:** Automated deploys
- (Add others as needed)

---

## 6. Special Notes
- Any manual steps, environment variables, or important setup notes
- (E.g., "All deploys require a valid service account secret.")

---

*Update this file regularly to keep your repo documentation perfect!* 