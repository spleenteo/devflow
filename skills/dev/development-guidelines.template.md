# Development guidelines

Rules the plans and the code must follow. Devflow passes this file to every plan, review and execution. Keep it short and checkable: a rule nobody can verify isn't a rule. Delete the sections you don't need.

## Tests

<!-- Framework and command. Where tests live and how they're named. What must be tested (pure functions, components, endpoints) and what isn't worth it. What a good test looks like: one behaviour per test, arrange/act/assert, no sleep, no snapshot as the only assertion. -->

## Naming

<!-- Variables, functions, files, components, database columns. Casing. Booleans as questions (isOpen, hasAccess). Abbreviations allowed and forbidden. -->

## Functions and modules

<!-- Size limits. One responsibility per function. When to split and when not to. Pure functions vs side effects. Error handling: throw, return, log. -->

## Code placement

<!-- Where each category of code goes and how to choose between two plausible places. Only the deviations from the framework's convention: the tree itself is what `ls` says. -->

## Dependencies

<!-- When adding a library is acceptable. Preferred ones. Forbidden ones. -->

## Commits

<!-- Message language and mood. What goes in one commit. What never goes in: generated files, secrets, unrelated fixes. -->

## Gate

<!-- What must be green before a slice closes. Exact commands, in order. -->

```bash
npm test
npm run typecheck
npm run build
```
