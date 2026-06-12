# FleetPilot

A B2B fleet management SaaS for companies that operate vehicle fleets: track vehicles, drivers, maintenance, document renewals, fuel costs and get proactive alerts before things expire.

Built with **Ruby on Rails 8** and **Hotwire**, backed by **MySQL**, with real third-party integrations (Twilio SMS, SendGrid email, Stripe subscriptions).

> Portfolio project. The goal is a production-grade codebase: multi-tenant data model, background jobs, automated tests, static security analysis and CI/CD.

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Ruby 3.3 · Rails 8.1 |
| Database | MySQL 8 via [Trilogy](https://github.com/trilogy-libraries/trilogy) |
| Frontend | Hotwire (Turbo + Stimulus) · import maps · Propshaft · Tailwind CSS |
| Jobs / cache / websockets | Solid Queue · Solid Cache · Solid Cable (database-backed) |
| Auth & authorization | Rails 8 native authentication · Pundit role policies |
| Tests | RSpec · FactoryBot · Capybara + Cuprite · SimpleCov |
| Quality & security | RuboCop · Brakeman · bundler-audit · Dependabot · GitHub Actions |
| Integrations | Twilio (SMS) · SendGrid (email) · Stripe (billing) · NHTSA vPIC (VIN decoding) |
| Deployment | Kamal 2 → Docker on a Google Cloud Compute Engine VM |

## Local setup

Requirements: Ruby 3.3.x, MySQL 8, Chrome/Chromium (system tests).

```bash
# Create the database user (once)
mysql -u root -p <<SQL
CREATE USER IF NOT EXISTS 'fleetpilot'@'localhost' IDENTIFIED BY 'fleetpilot';
GRANT ALL PRIVILEGES ON `fleetpilot\_%`.* TO 'fleetpilot'@'localhost';
FLUSH PRIVILEGES;
SQL

bundle install
bin/rails db:prepare
bin/dev
```

Run the checks CI runs:

```bash
bundle exec rspec          # tests (COVERAGE=true for a coverage report)
bin/rubocop                # lint
bin/brakeman --no-pager    # static security analysis
bin/bundler-audit          # known CVEs in dependencies
```

## Engineering log

Every failure we hit and fix becomes a documented prevention rule in
[docs/POSTMORTEMS.md](docs/POSTMORTEMS.md) — symptom, root cause, fix and the rule
that keeps it from happening again.

## Status

🚧 In active development. Roadmap:

- [x] Phase 0 — Foundations: tooling, test suite, CI, security scanning
- [x] Phase 1 — Fleet core: accounts, auth, vehicles (VIN decoding), drivers, assignments
- [x] Phase 2 — Maintenance: service records, schedules, renewals, alert engine
- [ ] Phase 3 — Integrations: Twilio SMS, SendGrid email, Stripe subscriptions
- [ ] Phase 4 — Reports: cost dashboards, fuel tracking, demo seeds
- [ ] Phase 5 — Deployment: Kamal to GCP, live demo
