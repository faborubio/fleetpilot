# FleetPilot — project conventions

Fleet management SaaS (Rails 8.1 + Hotwire + MySQL/Trilogy). Portfolio project targeting
a Ruby on Rails full-stack role; code, UI, commits and docs are in English.

## Postmortem rule (mandatory)

Every time a failure is diagnosed and fixed — CI failure, local environment issue,
deploy problem, runtime bug — append an entry to [docs/POSTMORTEMS.md](docs/POSTMORTEMS.md)
using its template (symptom, root cause, fix, prevention rule) in the same commit or PR
as the fix. Check existing entries before debugging: the answer may already be there.

## Environment quirks (WSL2, no Docker)

- rbenv is system-wide and root-owned: gems are vendored via `bundle config set --local path vendor/bundle`. Never sudo-install gems.
- sudo requires a password the agent doesn't have: apt installs are done by the user.
- MySQL 8 runs locally (`sudo service mysql start` if down); app user/password: `fleetpilot`/`fleetpilot`.
- `gh` lives at `~/.local/bin/gh` and is the git credential helper.

## Workflow

- Before pushing, run what CI runs: `bundle exec rspec`, `bin/rubocop`, `bin/brakeman --no-pager`, `bin/bundler-audit`, `bin/importmap audit`.
- All domain models are tenant-scoped by `account_id`; new queries must go through the account scope (isolation specs required).
- Money is stored as integer cents (`*_cents` columns).
- External HTTP (NHTSA, Stripe, Twilio, SendGrid) is always behind an adapter in `app/services/` and stubbed with WebMock in specs.
