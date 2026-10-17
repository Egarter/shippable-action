# Shippable scan (GitHub Action)

Check your AI-built app for security leaks on every pull request: open Supabase or Firebase data, secret keys headed for the browser, edge functions anyone can call, unsigned payment webhooks, vulnerable libraries. Read-only and free. Powered by [`shippable-dev`](https://www.npmjs.com/package/shippable-dev).

The job fails when it finds a critical or high issue, and the findings (with a fix for each) appear in the run's summary.

## Use it

`.github/workflows/shippable.yml`:

```yaml
name: Shippable
on: pull_request

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npm ci
      - uses: Egarter/shippable-action@v1
        with:
          start: npm run dev   # starts your dev server in the background
          url: localhost:5173  # where it listens
```

It scans the running dev server and reads your project folder (migrations and policies, edge functions, webhooks, `.env` files, every dependency in the lockfile). Nothing leaves the runner except the anonymous usage count described in the [CLI README](https://www.npmjs.com/package/shippable-dev#telemetry) (turn it off with `SHIPPABLE_TELEMETRY: 0` in `env`).

## Inputs

| Input | Default | What it does |
|---|---|---|
| `url` | `localhost:3000` | The dev server to scan |
| `start` | none | Command that starts the server. Leave empty if an earlier step already did |
| `working-directory` | `.` | The project folder (where `package.json` is) |
| `version` | `latest` | `shippable-dev` version to run |

## Good to know

- **Only report, don't block:** add `continue-on-error: true` to the step.
- **Public repos:** logs are public. Findings print with keys redacted (first and last few characters), but the file and line of a leak are visible, so fix before pushing, or keep the repo private.
- **Live URLs:** work too, once you own the site (a meta tag only the owner can deploy). Run `npx shippable-dev scan https://your-app.com` once locally to get it.
- Only scan apps you own.

Apache-2.0. The license covers the code only; it doesn't grant use of the Shippable name or the Patchy mascot.
