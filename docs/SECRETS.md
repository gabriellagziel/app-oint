# Secrets Management for CI/CD

To securely use tokens and credentials in GitHub Actions:

1. Go to your repository on GitHub.
2. Click **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Add secrets as needed. Common examples:
   - `FIREBASE_TOKEN` (for Firebase Hosting deploys)
   - `CODECOV_TOKEN` (only if your repo is private)
   - Any other API keys or credentials needed for deployment
5. Reference secrets in your workflow using `${{ secrets.SECRET_NAME }}`.

**Never commit secrets to your repository!**
