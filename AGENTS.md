# AGENTS.md

Single source of truth for agents working on **rfc-connector**.

Calls abap2UI5 apps of another system via RFC: the browser talks to a consumer
system, which forwards every request through an SM59 destination to the source
system where the apps run.

## What this repository is

A **source** repository in the abap2UI5 ecosystem: humans and agents edit here,
and CI gates every change. It is installed with abapGit — on **both** systems,
consumer and source, in the same version — and depends on the
[abap2UI5](https://github.com/abap2UI5/abap2UI5) core at runtime.

## Layout

| Path | Contents |
| --- | --- |
| `src/01` | Consumer side: the ICF handler `z2ui5_cl_rfc_connector_handler` and its SICF node `/sap/bc/z2ui5_rfc` |
| `src/02` | Source side: function group `z2ui5_fg_rfc_connector` with the RFC-enabled `Z2UI5_FM_RFC_CONECTOR` |
| `src/` | The DDIC structures both sides exchange: `z2ui5_s_http_req`, `z2ui5_s_http_res`, `z2ui5_s_http_config` |

## The RFC interface is a contract between two systems

Consumer and source are updated independently, so the function module and the
three structures are a public interface:

- Never rename or remove a parameter of `Z2UI5_FM_RFC_CONECTOR` or a field of
  the three structures. The misspelling `CONECTOR` is part of that contract.
- `IS_CONFIG` is reserved and unused — the source system reads its HTTP
  configuration from its own user exit. It stays because removing it breaks
  every consumer still on the previous version.
- A new field is additive, but the README asks for the same version on both
  systems for a reason: the handler has to cope with a source that answers
  without it (see the `status_code IS INITIAL` branch).

## What this depends on in the core

There is no version pin on the core — abaplint resolves it from its `main`
branch. That is why both workflows also run on a weekly schedule: a rename
upstream breaks this repository silently, and with no pull request open nothing
else would notice.

The connector calls:

| Member | Where in the core | Status |
| --- | --- | --- |
| `z2ui5_cl_ui5_http_handler=>_main` | `src/02` | released; the entry point that runs one roundtrip |
| `z2ui5_cl_ui5_http_handler=>get_request` | `src/02` | released, but the core marks it as having no caller and as a candidate for its next API revision — it does not know about this one |
| `z2ui5_cl_ui5_http_handler=>_check_csrf_rejected` | `src/02` | released |
| `z2ui5_cl_ui5_util_http=>factory` | `src/00/03` | **not released** — a vendored utility the core may rename without notice; recorded in `abap2ui5lint-baseline.json` |

Both systems need abap2UI5 1.143.0 or newer, the first release with
`z2ui5_cl_ui5_http_handler`.

## Build and verify

```sh
npm ci
npm run check
```

`npm run check` runs exactly what CI runs: abaplint (`abap-standard.yaml`) and
the abap2UI5-linter (`check-abap2ui5.yaml`). This repository builds no view, so
the linter runs with `allClasses` and without the render gate; what it adds is
the released-API check.

Nothing offline can prove the RFC call itself, the SICF node or the round trip
through a real destination. State in the pull request what was and was not
verified in a system.

## Conventions

- ABAP object names start with `z2ui5_`; the connector's own objects carry
  `rfc_connector`.
- Syntax level v750 with the `downport` rule, the same floor as the core.
- English for code, comments, commit messages, pull requests and issues.
- All text files are LF-only (`.gitattributes`).
- The ecosystem-wide rules — workflow and npm-script naming, toolchain versions,
  which documentation files exist, commit style — live in
  [CONVENTIONS.md](https://github.com/abap2UI5/abap2UI5/blob/main/.github/shared/CONVENTIONS.md)
  and bind this repository too.
