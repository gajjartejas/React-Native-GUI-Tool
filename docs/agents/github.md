# GitHub triage reference

Supporting rules for repository-root `AGENTS.md`. Read when working with GitHub issues.

## GitHub issue triage

- Confirm the repository remote and search open and closed issues before filing.
  Read relevant issue bodies/comments to avoid duplicating an existing report.
- Update an existing issue when it describes the same root cause; create a new
  issue for a distinct confirmed defect. Do not reopen or close issues casually.
- Include a concrete title, severity/impact, reviewed branch and commit, file/line
  references, reproduction steps, expected/actual behavior, and verification method.
  Distinguish source-confirmed defects from runtime reproductions and speculation.
- For branch-only findings, say so and link the reviewed commit. Do not imply that
  an unreleased defect was confirmed in a release or the default branch.
- Known placeholder modules are feature work, not newly discovered regressions.
  Do not duplicate their existing feature issues.
- If instructed not to fix issues, report findings and links without changing
  production behavior, refactoring, closing issues as fixed, or submitting fix PRs.

Start with a compact issue list (number, title, state), filtered by relevant terms.
Read bodies/comments only for likely matches; paginate when the scope requires it.
Do not repeatedly download every issue body.
