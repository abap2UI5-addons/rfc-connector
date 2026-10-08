# rfc-connector

[![abap2UI5-addons](https://img.shields.io/badge/abap2UI5--addons-connector-1873b4)](https://github.com/abap2UI5-addons)
[![ABAP](https://img.shields.io/badge/ABAP-Standard%20%E2%89%A5%207.50-blue)](#installation)
[![abap2UI5](https://img.shields.io/badge/requires-abap2UI5-blue)](https://github.com/abap2UI5/abap2UI5)
[![License](https://img.shields.io/github/license/abap2UI5-addons/rfc-connector)](LICENSE)
<br>
[![ABAP Standard](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/rfc-connector/abap-standard.yaml?branch=main&label=ABAP%20Standard)](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/abap-standard.yaml)
[![check-abap2UI5](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/rfc-connector/check-abap2ui5.yaml?branch=main&label=check-abap2UI5)](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/check-abap2ui5.yaml)

**Remotely call abap2UI5 apps via RFC.** The browser talks to a consumer
system, which forwards every request through an SM59 RFC destination to the
source system where the abap2UI5 apps run. For landscapes where users should
reach the apps of another system through one entry point.

> Part of [abap2UI5-addons](https://github.com/abap2UI5-addons) - addons and apps for [abap2UI5](https://github.com/abap2UI5/abap2UI5), installed with [abapGit](https://abapgit.org).

```
Browser ── GET/POST ──> Consumer System                     Source System
                        /sap/bc/z2ui5_rfc                   Z2UI5_FM_RFC_CONECTOR
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
- [abap2UI5](https://github.com/abap2UI5/abap2UI5) **1.143.0 or newer** on both
  systems - the connector calls `z2ui5_cl_ui5_http_handler`, which first
  shipped with that release. URL parameters (`?z2ui5-bundle`, `app_start` for
  the user exit, …) are forwarded only when the consumer runs an abap2UI5
  release **newer than 1.146.0**; on an older one they stay behind, as before.
- On the consumer system: a destination in SM59 (type 3) pointing to the
  source system, with login data maintained

**Steps** - with [abapGit](https://abapgit.org):

| System | What to install |
|---|---|
| Consumer system | abap2UI5 + this repository (branch `main`) |
| Source system | abap2UI5 + this repository (branch `main`), the same version as on the consumer |

1. Install [abap2UI5](https://github.com/abap2UI5/abap2UI5) on both systems.
2. Install this repository on **both** systems — the same version on each:
   consumer and source exchange the DDIC structures of this repository over RFC.
3. On the **consumer system**, replace in the HTTP handler
   `Z2UI5_CL_RFC_CONNECTOR_HANDLER` the destination `NONE` with your source
   system destination.
4. On the **consumer system**, activate the ICF node `/sap/bc/z2ui5_rfc` in
   transaction SICF. The source system needs no ICF node - it is called through
   the RFC-enabled function module `Z2UI5_FM_RFC_CONECTOR`.

**Start** - call the endpoint `.../sap/bc/z2ui5_rfc` of the **consumer
system** in your browser.

## Usage

### Approach

The consumer system receives the browser request, forwards method, body, path and query string via RFC to the source system and returns body and HTTP status of the response. All abap2UI5 apps run on the source system.

| System | Entry | Object |
|---|---|---|
| Consumer | ICF node `/sap/bc/z2ui5_rfc` | `Z2UI5_CL_RFC_CONNECTOR_HANDLER` |
| Source | RFC-enabled function module | `Z2UI5_FM_RFC_CONECTOR` (function group `Z2UI5_FG_RFC_CONNECTOR`) |
| Both | DDIC structures exchanged over RFC | `Z2UI5_S_HTTP_REQ`, `Z2UI5_S_HTTP_RES`, `Z2UI5_S_HTTP_CONFIG` |

<img width="700" alt="image" src="https://github.com/abap2UI5/abap2UI5-connector_rfc/assets/102328295/5787755c-f4f1-48d8-a9da-50b4f04db9ed">

### Limitations

* **Stateless apps only.** A stateful app (`client->set_session_stateful( )`) needs the ICF session of the system the app runs on, and every RFC call gets a fresh context on the source system. Apps keeping their state in the draft table — the abap2UI5 default — work unchanged.
* **The consumer forwards method, body, path, query string and status — not headers.** Everything abap2UI5 needs for a roundtrip travels in the body and the URL; a request header an app reads through the user exit on the source system does not.

## Development

```sh
npm ci
npm run check
```

`npm run check` runs exactly what CI runs: abaplint (`abap-standard.yaml`) and
the abap2UI5-linter (`check-abap2ui5.yaml`).

## Contributing

Issues and pull requests are welcome - see [CONTRIBUTING.md](CONTRIBUTING.md) for what CI checks. Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated.

## License

MIT - see [LICENSE](LICENSE).
