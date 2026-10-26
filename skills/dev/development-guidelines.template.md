# Development guidelines

Rules the plans and the code must follow. `/flow:dev` passes this file to every plan, review and execution. Keep it short and checkable: a rule nobody can verify isn't a rule.

## References

<!-- External guides and skills this project follows (style guides, framework skills, internal handbooks). One line each, with where to find it. -->

## Tests

Level: <none | essential | full>
Sensitive areas: <path or concept>, …

<!-- Framework and command. Where tests live and how they're named. What a good test looks like: one behaviour per test, arrange/act/assert, no sleep, no snapshot as the only assertion. -->

## Gate

<!-- What must be green before a slice closes. Exact commands, in order. -->

```bash
npm test
npm run typecheck
npm run build
```

## Deviations

<!-- Where this project departs from its references, and why. -->
