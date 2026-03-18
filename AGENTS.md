# DS-Test Agent Rules

This repository is the testing and future-development repo.

- Test repo name: `DS-Test`
- Test repo remote: `https://github.com/DattSoap-2026/DS-Test.git`
- Real production repo: `https://github.com/DattSoap-2026/DattSoap.git`
- Default branch for both repos: `main` unless the user explicitly says otherwise

## Core Rule

Never push this entire `DS-Test` working tree directly to the real `DattSoap` repo.

Reason: `DS-Test` can contain testing-only files, future work, local placeholders, logs, and local Firebase setup that must not leak into production.

## Remote Safety Rules

- `origin` must always remain the `DS-Test` remote.
- If the real repo is needed for comparison, add it as a separate remote named `real`, or use a separate clone.
- Do not change `origin` from `DS-Test` to `DattSoap`.
- Do not run `git push real main` from this `DS-Test` checkout.
- Production pushes must happen from a separate clean checkout of the real repo after copying or cherry-picking only approved production changes.

## Safe Commands

Use these commands unless the user explicitly asks for something else.

```powershell
git remote -v
git pull origin main
git remote add real https://github.com/DattSoap-2026/DattSoap.git
git fetch real main
git log --oneline --left-right origin/main...real/main
```

If the real repo must be updated, use a separate folder such as `d:\Datt Soap\DattSoap`.

```powershell
git clone https://github.com/DattSoap-2026/DattSoap.git d:\Datt Soap\DattSoap
cd d:\Datt Soap\DattSoap
git pull origin main
```

After that, copy only production-safe changes from `DS-Test` into the real repo checkout, review them, run validation there, then push from the real repo checkout only.

## Never Sync To Real Repo

Do not copy, cherry-pick, or commit these into the real repo unless the user explicitly overrides after review.

- `AGENTS.md`
- `backlog/`
- `docs/archive/`
- `build/`
- `.dart_tool/`
- `release_output/`
- `installer/output/`
- `analysis_log.txt`
- `analysis_output.txt`
- `analysis.txt`
- `analyze_output.txt`
- `analysis.json`
- `build_log.txt`
- `code_summary.json`
- `app_log.txt`
- `app_log_run.txt`
- `app_log_utf8.txt`
- `app_verify_log.txt`
- `test_output.txt`
- `temp_user.json`
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `android/app/google-services.xml`
- `windows/firebase_config.json`
- `.env`
- `.env.local`
- `.env.production`
- `.env.development`
- `*.env`
- `*.jks`
- `*.keystore`
- `android/key.properties`
- `android/local.properties`
- platform generated plugin registrant files copied from this repo; regenerate them inside the real repo instead

## Firebase And Secret Handling

- `lib/firebase_options.dart` in this repo is local-only and must remain untracked.
- Real Firebase config must be generated or supplied locally in each environment.
- Never force-add Firebase config files with `git add -f`.
- Before any production push, inspect staged files and stop if any Firebase or env file appears.

Recommended check:

```powershell
git diff --name-only --cached | rg "firebase_options|google-services|firebase_config|\\.env|key.properties"
```

If this command returns any file, remove it from staging before pushing.

## Production Sync Checklist

Before pushing to the real repo, confirm all of the following.

1. You are inside the real repo checkout, not inside `DS-Test`.
2. `git remote get-url origin` returns `https://github.com/DattSoap-2026/DattSoap.git`.
3. Only production-safe source changes are staged.
4. No testing-only files, logs, placeholder assets, or secret files are staged.
5. Validation has been run in the real repo checkout.

## DS-Test Pull Checklist

When the user asks to update the testing repo, use this repo and only this repo.

1. Stay inside `DS-Test`.
2. Verify `origin` points to `https://github.com/DattSoap-2026/DS-Test.git`.
3. Run `git pull origin main`.
4. Do not mix real repo commits into `DS-Test` without review.

## Default Agent Behavior

If a user says "push to real repo", do not push from this checkout.

Instead:

1. Fetch or clone the real repo separately.
2. Move only the approved production changes.
3. Re-run validation in the real repo.
4. Push from the real repo checkout.

This file must stay in `DS-Test` only. Do not copy it into the real `DattSoap` repo.
