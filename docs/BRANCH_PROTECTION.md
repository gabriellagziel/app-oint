# Branch Protection Setup

To ensure code quality and prevent mistakes, set up branch protection for `main`:

1. Go to your repository on GitHub.
2. Click **Settings** > **Branches**.
3. Under "Branch protection rules", click **Add rule**.
4. Set the rule for `main`.
5. Enable these options:
   - Require a pull request before merging
   - Require status checks to pass before merging (select your CI workflow)
   - Require branches to be up to date before merging
   - (Optional) Require pull request reviews before merging
   - (Optional) Restrict who can push to matching branches
6. Click **Create** or **Save changes**.

This ensures only reviewed, tested code is merged into production.
