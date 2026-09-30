# Contributing

Call abap2UI5 apps of another system via RFC.

## Before you open a pull request

Run what CI runs:

```sh
npm ci
npm run check
```

`npm run check` is the same set of steps the workflows run on a pull request,
so a green run locally is a green run there. `npm test` is an alias for it —
this repository has no separate unit-test suite; its ABAP is checked, not
executed.

## What the gates are

| Gate | What it proves |
| --- | --- |
| `npm run lint` | abaplint: syntax, resolved against the abap2UI5 core |
| `npm run check:abap2ui5` | [abap2UI5-linter](https://github.com/abap2UI5/linter), source-side rules only (there is no view here): abapGit round trip, activation, and that the connector names no unreleased core object beyond the one it uses on purpose |

The abap2UI5-linter keeps a baseline in `abap2ui5lint-baseline.json`. Findings
recorded there are counted and never listed; a **new** finding fails the gate,
and an entry whose finding is gone is stale and fails too. So the file only ever
shrinks — fix something, then refresh it with:

```sh
npx abap2ui5lint --update-baseline
```

Neither gate can call a destination. Say in the pull request whether the change
was tried between two systems.

## Conventions

English for code, comments, commit messages and pull requests. Commit subjects
are written in the imperative and describe the outcome, not the mechanics. One
topic per pull request. The wider rules the whole ecosystem follows live in
[abap2UI5's CONVENTIONS.md](https://github.com/abap2UI5/abap2UI5/blob/main/.github/shared/CONVENTIONS.md).
