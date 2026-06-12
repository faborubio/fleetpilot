# Postmortems & prevention rules

Every time a failure is diagnosed and fixed (CI, local environment, deploy, runtime bug),
it gets an entry here: what broke, why, how it was fixed, and the rule that prevents it
from happening again. Newest entries first.

Template:

```markdown
## YYYY-MM-DD — Short title
- **Symptom:** what was observed.
- **Root cause:** the actual underlying reason.
- **Fix:** what resolved it.
- **Prevention rule:** the rule we follow from now on.
```

---

## 2026-06-11 — `bin/dev` fails with `foreman: not found`

- **Symptom:** `bin/dev` tried to `gem install foreman`, which landed in `~/.local/share/gem/.../bin` (not on PATH) and failed to rehash rbenv shims, then `exec foreman` failed with `foreman: not found`.
- **Root cause:** the stock `bin/dev` installs foreman as a global gem, but rbenv is root-owned (gems install to a user dir outside PATH) and foreman isn't in the bundle.
- **Fix:** added `foreman` to the Gemfile `development` group and changed `bin/dev` to `exec bundle exec foreman start -f Procfile.dev`.
- **Prevention rule:** on this machine, dev tools that scripts expect on PATH (foreman, etc.) must live in the Gemfile and be invoked via `bundle exec`, never `gem install`. Same root cause as the vendored-gems entry below.

## 2026-06-11 — git push rejected for workflow files (missing OAuth scope)

- **Symptom:** `git push` rejected with `refusing to allow an OAuth App to create or update workflow .github/workflows/ci.yml without workflow scope`.
- **Root cause:** the default `gh auth login` token does not include the `workflow` scope, which GitHub requires for any push that touches `.github/workflows/`.
- **Fix:** `gh auth refresh -h github.com -s workflow`, then `gh auth setup-git` so git uses gh as credential helper.
- **Prevention rule:** when authenticating `gh` for a repo that has GitHub Actions, request the `workflow` scope from the start and run `gh auth setup-git` immediately after login.

## 2026-06-11 — CI red on first push: missing importmap/Turbo/Stimulus/Solid artifacts and schema

- **Symptom:** first CI run failed on two jobs: `scan_js` (`bin/importmap: No such file or directory`) and `test` (`db/schema.rb doesn't exist yet`).
- **Root cause:** the `bundle install` step inside the original `rails new` failed silently for us (see entry below), so the after-bundle install generators (`importmap:install`, `turbo:install`, `stimulus:install`, `solid_cache/queue/cable:install`) never ran. The skeleton looked complete but `app/javascript/`, `config/importmap.rb`, `config/queue.yml` and friends were missing, and no `db/schema.rb` existed for `db:test:prepare`.
- **Fix:** ran the four install generators manually, then `bin/rails db:migrate` to produce an (empty) `db/schema.rb`, committed and pushed.
- **Prevention rule:** if `rails new` (or any generator) reports a bundler error, assume every after-bundle hook was skipped. Verify the artifacts exist (`bin/importmap`, `app/javascript/`, `config/queue.yml`, `db/*_schema.rb`) before trusting the skeleton. Run all CI commands locally (`rspec`, `rubocop`, `brakeman`, `bundler-audit`, `importmap audit`) before the first push of any branch.

## 2026-06-11 — Bundler cannot install gems: read-only system rbenv

- **Symptom:** `bundle install` failed repeatedly with `Bundler::PermissionError: there was an error while trying to write to /usr/local/rbenv/.../cache/*.gem`.
- **Root cause:** rbenv is installed system-wide under `/usr/local/rbenv` (owned by root), so installing gems to the default `GEM_HOME` requires sudo.
- **Fix:** `bundle config set --local path vendor/bundle` to vendor gems inside the project; added `/vendor/bundle` to `.gitignore`.
- **Prevention rule:** on this machine, every Ruby project must set the local bundler path (`vendor/bundle`) before its first `bundle install`. Never sudo-install gems.
