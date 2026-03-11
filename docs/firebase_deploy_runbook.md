# Firebase Firestore Deploy Runbook

This project is wired for Firestore config deploys via:
- `firebase.json` -> `firestore.rules`, `firestore.indexes.json`
- `.firebaserc` aliases:
  - `default` -> `REPLACE_WITH_STAGING_PROJECT_ID` (safe placeholder; prevents implicit prod target)
  - `staging` -> `REPLACE_WITH_STAGING_PROJECT_ID` (must be set before use)
  - `production` -> `dattsoap-6cf2a`

Safety rule:
- Never run `firebase deploy` without `--project ...`.
- Keep `.firebaserc.projects.default` pointed to staging, never production.

## One-time setup

1. Install Firebase CLI:
```powershell
npm install -g firebase-tools
```

2. Login:
```powershell
firebase login
```

3. Verify project aliases:
```powershell
firebase projects:list
Get-Content .firebaserc
```

4. Update staging/default aliases in `.firebaserc` before first staging deploy.

5. Block deploy if placeholder alias is still present:
```powershell
if (Select-String -Path .firebaserc -Pattern "REPLACE_WITH_STAGING_PROJECT_ID") {
  throw "Set staging/default alias in .firebaserc before deploy."
}
```

## Pre-deploy validation

```powershell
flutter analyze
flutter test
```

```powershell
# Sanity check: do not rely on active firebase use target.
firebase use
```

## Staging deploy commands

1. Backup currently deployed Firestore rules:
```powershell
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
New-Item -ItemType Directory -Force -Path "deploy_backups\\staging" | Out-Null
firebase firestore:rules:get "deploy_backups\\staging\\firestore.rules.$ts.remote" --project staging
Copy-Item firestore.indexes.json "deploy_backups\\staging\\firestore.indexes.$ts.local.json"
```

2. Deploy rules + indexes to staging:
```powershell
firebase deploy --project staging --only firestore:rules,firestore:indexes
```

## Production deploy commands

1. Backup currently deployed Firestore rules:
```powershell
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
New-Item -ItemType Directory -Force -Path "deploy_backups\\production" | Out-Null
firebase firestore:rules:get "deploy_backups\\production\\firestore.rules.$ts.remote" --project production
Copy-Item firestore.indexes.json "deploy_backups\\production\\firestore.indexes.$ts.local.json"
```

2. Explicit operator confirmation:
```powershell
$confirm = Read-Host "Type PRODUCTION to deploy Firestore config to dattsoap-6cf2a"
if ($confirm -ne "PRODUCTION") { throw "Production deploy aborted." }
```

3. Deploy rules + indexes to production:
```powershell
firebase deploy --project production --only firestore:rules,firestore:indexes
```

## Rollback steps

Note: Firestore index rollback is asynchronous and may take time to converge.

### Rollback rules only

```powershell
Copy-Item "deploy_backups\\production\\firestore.rules.<TIMESTAMP>.remote" firestore.rules -Force
firebase deploy --project production --only firestore:rules
git restore firestore.rules
```

### Rollback indexes (using previous known-good index file)

```powershell
Copy-Item "deploy_backups\\production\\firestore.indexes.<TIMESTAMP>.local.json" firestore.indexes.json -Force
firebase deploy --project production --only firestore:indexes
git restore firestore.indexes.json
```

### Full rollback (rules + indexes)

```powershell
Copy-Item "deploy_backups\\production\\firestore.rules.<TIMESTAMP>.remote" firestore.rules -Force
Copy-Item "deploy_backups\\production\\firestore.indexes.<TIMESTAMP>.local.json" firestore.indexes.json -Force
firebase deploy --project production --only firestore:rules,firestore:indexes
git restore firestore.rules firestore.indexes.json
```

## Smoke checks after deploy

```powershell
firebase firestore:indexes --project production
```

Manual checks:
- Accountant user can open accounting routes.
- Non-accountant users cannot access accounting routes.
- Sales/Purchase transactions continue in operational mode.
- No new permission leaks on users/settings/tax config collections.
