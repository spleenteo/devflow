---
name: stack-rails
description: Flow stack preset, invoked only by Flow's conductors by its qualified name; never for general questions.
user-invocable: false
---

# Flow: stack preset, Rails

Opinions for a Ruby on Rails application, following thoughtbot's practice, read by Flow's conductors. A project that disagrees replaces this preset (`presets:` in its configuration file).

## Rules

1. New models set `self.strict_loading_by_default = true` and queries preload their associations (`includes`, `preload`), because N+1 queries then raise in every environment, so set `config.active_record.action_on_strict_loading_violation = :log` in production if raising there is unwanted.
2. Name domain objects for what they are (`Registration`, not `RegistrationService`), plain Ruby classes under `app/models`, because "service" names hide the concept.
3. Keep controllers thin: params in, one call to a model or PORO, a render or redirect out, because logic in controllers is untestable without a request.
4. Reusable view logic goes in presenters or ViewComponents, one-off formatting in helpers, because logic in ERB is not unit-testable.
5. Side effects that leave the database (mail, jobs, webhooks) run in `after_commit`, and jobs are enqueued after the transaction (Rails 7.2+ does so by default), because a rollback must not have sent anything.
6. Use `Time.current` and `Date.current` (`Time.zone`), never `Time.now` or `Date.today`, because the server zone is not the app's zone.
7. Migrations are reversible, add the index for every column a new query filters on, and run backfills in a separate step, because a long lock or irreversible step blocks the deploy.
8. Authorize in one place (policy or ability class) and cover each new action, with the denied case tested, because a missing check is invisible until abused.
9. Strong parameters list every permitted key explicitly; no `permit!`, because mass assignment must be opt-in.
10. Tests follow Arrange/Act/Assert with inline setup rather than `let` and `before`, and stub dependencies, not the system under test, because readable tests are the ones that get maintained.
11. System tests use semantic Capybara selectors (`find_button`, `have_field`, `have_text`), not chained CSS, because they survive markup changes.
12. No `rubocop:disable` comments; fix the code, because disabled cops accumulate silently.
13. Attachments go through ActiveStorage with variants for sizes, because originals are too heavy to serve.
14. Inbound webhooks verify a signature and are idempotent, because providers retry.

## Lenses

| Lens | Looks for |
|---|---|
| **Transactions, callbacks and jobs** | Side effects in `after_save` that belong in `after_commit`; jobs enqueued before commit; scheduled jobs (`sidekiq-cron`, `whenever`) reading the touched tables; writes to schemas or databases other than the main one |
| **Time and locale** | `Time.now` or `Date.today` instead of `Time.zone`; date formats in views and exports; time zones in nightly jobs |
| **Migrations and data** | Reversibility; migrations that must run per tenant or schema; backfills on existing records; missing indexes on columns the new queries filter; N+1 in the views the slices touch |
| **Authorization** | `ability.rb`, Pundit policies or equivalents: who can do the new thing, and who must not; separate application areas (admin, portal, API) sharing the touched models |
| **Attachments and external services** | ActiveStorage and image CDNs; mailers and mail providers; PDFs; inbound and outbound webhooks |

## Tests

Level: essential
Sensitive areas: authentication and authorization, payments and billing, migrations and data backfills, background jobs touching money

Raise to `full` only when the project asks for it.

## Gate

- `bin/rails test` (Minitest) or `bundle exec rspec` (RSpec), whichever the repo uses
- `bin/rubocop` when present (Rails 7.2+)
- `bin/brakeman` when present in `bin/`
- `bin/ci` (Rails 8.1), when present, can replace this list

## References

All optional, never invoked by this preset:

- `rails-patterns` (`rails-development:rails-patterns`): strict loading, presenters, PORO naming.
- `testing-patterns` (`rails-development:testing-patterns`): Arrange/Act/Assert, Capybara selectors, test speed.
