[![abap-standard](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/abap-standard.yaml/badge.svg)](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/abap-standard.yaml)
[![check-abap2ui5](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/check-abap2ui5.yaml/badge.svg)](https://github.com/abap2UI5-addons/rfc-connector/actions/workflows/check-abap2ui5.yaml)

## RFC Connector

Remotely Call abap2UI5 Apps via RFC.

A source repository of the abap2UI5 ecosystem, installed with abapGit on two systems: the one the browser talks to and the one the apps run on.

#### Approach

```
Browser ── GET/POST ──> Consumer System                     Source System
                        /sap/bc/z2ui5_rfc                   Z2UI5_FM_RFC_CONECTOR
                        Z2UI5_CL_RFC_CONNECTOR_HANDLER        │
                          │                                   │
                          └── RFC (SM59 destination) ────────>└──> z2ui5_cl_ui5_http_handler
```

The consumer system receives the browser request, forwards method, body, path and query string via RFC to the source system and returns body and HTTP status of the response. All abap2UI5 apps run on the source system.

<img width="700" alt="image" src="https://github.com/abap2UI5/abap2UI5-connector_rfc/assets/102328295/5787755c-f4f1-48d8-a9da-50b4f04db9ed">

#### Installation

_Prerequisite: Set up a destination in SM59 (type 3) on the consumer system pointing to the source system, with login data maintained. abap2UI5 **1.143.0 or newer** needs to be installed in both systems — the connector calls `z2ui5_cl_ui5_http_handler`, which first shipped with that release. URL parameters (`?z2ui5-bundle`, `app_start` for the user exit, …) are forwarded only when the consumer runs an abap2UI5 release **newer than 1.146.0**; on an older one they stay behind, as before._

Steps:
1. Install this repository on both systems — the same version on each: consumer and source exchange the DDIC structures of this repository over RFC.
2. Replace in the HTTP handler `Z2UI5_CL_RFC_CONNECTOR_HANDLER` the destination `NONE` with your Source System Destination.
3. Activate the ICF node `/sap/bc/z2ui5_rfc` (consumer system) in transaction SICF.
4. Call in your browser the endpoint `.../sap/bc/z2ui5_rfc`

#### Limitations

* **Stateless apps only.** A stateful app (`client->set_session_stateful( )`) needs the ICF session of the system the app runs on, and every RFC call gets a fresh context on the source system. Apps keeping their state in the draft table — the abap2UI5 default — work unchanged.
* **The consumer forwards method, body, path, query string and status — not headers.** Everything abap2UI5 needs for a roundtrip travels in the body and the URL; a request header an app reads through the user exit on the source system does not.

#### Contribution & Support
Pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for what CI checks. Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated. If you encounter any issues, feel free to open an issue.
