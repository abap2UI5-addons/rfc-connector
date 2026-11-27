# rfc-connector

[![abap2UI5-addons](https://img.shields.io/badge/abap2UI5--addons-connector-1873b4)](https://github.com/abap2UI5-addons)
[![ABAP](https://img.shields.io/badge/ABAP-Standard%20%E2%89%A5%207.50-blue)](#installation)
[![abap2UI5](https://img.shields.io/badge/requires-abap2UI5-blue)](https://github.com/abap2UI5/abap2UI5)
[![License](https://img.shields.io/github/license/abap2UI5-addons/rfc-connector)](LICENSE)
<br>
[![CI](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/rfc-connector/ci.yaml?branch=main&label=CI)](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/ci.yaml)
[![ABAP 7.02](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/rfc-connector/ci-702.yaml?branch=main&label=ABAP%207.02)](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/ci-702.yaml)

**Remotely call abap2UI5 apps via RFC.** The browser talks to a consumer
system, which forwards every request through an SM59 RFC destination to the
source system where the abap2UI5 apps run. For landscapes where users should
reach the apps of another system through one entry point.

> Part of [abap2UI5-addons](https://github.com/abap2UI5-addons) - addons and apps for [abap2UI5](https://github.com/abap2UI5/abap2UI5), installed with [abapGit](https://abapgit.org). Documentation: [abap2ui5-addons.github.io/rfc-connector](https://abap2ui5-addons.github.io/rfc-connector/).

```
Browser ── GET/POST ──> Consumer System                     Source System
                        /sap/bc/z2ui5_rfc                   Z2UI5_FM_RFC_CONNECTOR
                        Z2UI5_CL_RFC_CONNECTOR_HANDLER        │
                          │                                   │
                          └── RFC (SM59 destination) ────────>└──> z2ui5_cl_ui5_http_handler
```

## Why

The abap2UI5 apps live on one system, but the browser should call another one.
The rfc-connector puts a thin ICF handler on the consumer system that passes
each roundtrip on to the source system by RFC - the apps themselves stay where
they are and run unchanged.

Same approach as the [http-connector](https://github.com/abap2UI5-addons/http-connector),
just with an RFC connection instead of HTTP.

## Installation

The connector is installed on **two systems**: the **consumer system** the
browser talks to and the **source system** the apps run on.

**Requirements**

- Standard ABAP 7.50 or higher on both systems
- NetWeaver 7.02 - 7.40: the branch `702`, downported automatically from
  `main` on every push - pull abap2UI5 from its `702` branch as well
- [abap2UI5](https://github.com/abap2UI5/abap2UI5) **1.143.0 or newer** on both
  systems - the connector calls `z2ui5_cl_ui5_http_handler`, which first
  shipped with that release. URL parameters (`?z2ui5-bundle`, `app_start` for
  the user exit, …) are forwarded only when the consumer runs an abap2UI5
  release **1.147.0 or newer**; on an older one they stay behind, as before.
- On the consumer system: a destination in SM59 (type 3) pointing to the
  source system, with login data maintained

**Renamed (2026-11).** The structures `Z2UI5_S_HTTP_REQ`, `_RES` and `_CONFIG` are `Z2UI5_S_RFC_REQ`, `_RES` and `_CONFIG` now, and the function module is spelled `Z2UI5_FM_RFC_CONNECTOR`. RFC matches the structures by their fields, so a system on the old names still talks to one on the new names. The wrapper under the function module's misspelled name is removed: consumer and source have to be on this version together. After the pull abapGit lists the old structures and the old function module as deleted in the repository - delete them.

**Steps** - with [abapGit](https://abapgit.org):

| System | What to install |
|---|---|
| Consumer system | abap2UI5 + this repository (branch `main`) |
| Source system | abap2UI5 + this repository (branch `main`), the same version as on the consumer |

1. Install [abap2UI5](https://github.com/abap2UI5/abap2UI5) on both systems.
2. Install this repository on **both** systems — the same version on each:
   consumer and source exchange the DDIC structures of this repository over RFC.
   When you update from a version before 2026-11, update **both systems
   together**: the consumer calls `Z2UI5_FM_RFC_CONNECTOR`, which an older
   source does not have, and the source no longer answers to the misspelled
   name the older consumers call.
3. On the **consumer system**, replace in the HTTP handler
   `Z2UI5_CL_RFC_CONNECTOR_HANDLER` the destination `NONE` with your source
   system destination.
4. On the **consumer system**, activate the ICF node `/sap/bc/z2ui5_rfc` in
   transaction SICF. The source system needs no ICF node - it is called through
   the RFC-enabled function module `Z2UI5_FM_RFC_CONNECTOR`.

**Start** - call the endpoint `.../sap/bc/z2ui5_rfc` of the **consumer
system** in your browser.

## Usage

### Approach

The consumer system receives the browser request, forwards method, body, path and query string via RFC to the source system and returns body and HTTP status of the response. All abap2UI5 apps run on the source system.

| System | Entry | Object |
|---|---|---|
| Consumer | ICF node `/sap/bc/z2ui5_rfc` | `Z2UI5_CL_RFC_CONNECTOR_HANDLER` |
| Source | RFC-enabled function module | `Z2UI5_FM_RFC_CONNECTOR` (function group `Z2UI5_FG_RFC_CONNECTOR`) |
| Both | DDIC structures exchanged over RFC | `Z2UI5_S_RFC_REQ`, `Z2UI5_S_RFC_RES`, `Z2UI5_S_RFC_CONFIG` |

<img width="700" alt="image" src="https://github.com/abap2UI5/abap2UI5-connector_rfc/assets/102328295/5787755c-f4f1-48d8-a9da-50b4f04db9ed">

### Limitations

* **Stateless apps only.** A stateful app (`client->set_session_stateful( )`) needs the ICF session of the system the app runs on, and every RFC call gets a fresh context on the source system. Apps keeping their state in the draft table — the abap2UI5 default — work unchanged.
* **The consumer forwards method, body, path, query string and status — not headers.** Everything abap2UI5 needs for a roundtrip travels in the body and the URL; a request header an app reads through the user exit on the source system does not.
* **Response headers are the consumer's own.** Only body and status come back from the source system, so the consumer sets the response headers the way abap2UI5 does by default: the content type (page, bundle, JSON roundtrip, plain-text error), the cache policy (the page and the bundles revalidated, everything else `no-store`) and the default security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, `Cross-Origin-Resource-Policy`). Security headers a user exit adds on the source system do not reach the browser - change them in `Z2UI5_CL_RFC_CONNECTOR_HANDLER` (`get_security_headers`) as well - and the page and the bundles have no ETag, so a reload fetches them again instead of getting a 304.

### Troubleshooting

`RFC_CONNECTOR_ERROR - the source system could not be reached (subrc n)`
(status 502) means the RFC call failed: subrc 1 a system failure on the
source system (a short dump - ST22 there), subrc 2 a communication failure
(destination missing, logon refused, system down - SM59 Connection Test and
Authorization Test), subrc 3 no resources. The text names no destination,
host or user on purpose - every user can see it.

## Development

```sh
npm ci
npm run check
```

`npm run check` runs exactly what CI runs (`ci.yaml`, from the shared CI
template of abap2UI5-addons): abaplint and the abap2UI5-linter.

## Contributing

Issues and pull requests are welcome - see [CONTRIBUTING.md](CONTRIBUTING.md) for what CI checks. Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated.

## License

MIT - see [LICENSE](LICENSE).
