---
layout: home

hero:
  name: "RFC Connector"
  text: "Call abap2UI5 apps on another system via RFC."
  image:
    src: /favicon.png
    alt: abap2UI5
  actions:
    - theme: brand
      text: Get started
      link: /guide
    - theme: alt
      text: GitHub
      link: https://github.com/abap2UI5-addons/rfc-connector
    - theme: alt
      text: All addons
      link: https://abap2ui5-addons.github.io/

features:
  - title: "ICF node /sap/bc/z2ui5_rfc and handler Z2UI5_CL_RFC_CONNECTOR_HANDLER on the consumer"
  - title: "RFC-enabled function module Z2UI5_FM_RFC_CONECTOR on the source system"
  - title: "Forwards method, body, path, query string and HTTP status over RFC"
  - title: "Apps run unchanged on the source system; stateless (draft table) apps supported"
  - title: "No ICF node needed on the source system"
---

## What it does

rfc-connector puts a thin ICF handler on a consumer system that the browser talks to; the handler forwards method, body, path and query string of each roundtrip through an SM59 RFC destination to the source system where the abap2UI5 apps run, and returns body and HTTP status. The apps stay where they are and run unchanged. Use it in landscapes where users should reach the apps of another system through one entry point. It is the same approach as the http-connector, with an RFC connection instead of HTTP.

## Requirements

- Standard ABAP 7.50 or higher on both systems
- abap2UI5 1.143.0 or newer on both systems
- abap2UI5 1.147.0 or newer on the consumer to forward URL parameters
- An SM59 destination (type 3) on the consumer system pointing to the source system with login data
- Stateless apps only; request headers are not forwarded

## Installation

With [abapGit](https://abapgit.org), from [the repository](https://github.com/abap2UI5-addons/rfc-connector):

- Install abap2UI5 and this repository (branch main) on both the consumer and the source system, the same version on each
- On the consumer system replace the destination NONE in Z2UI5_CL_RFC_CONNECTOR_HANDLER with your source system destination
- On the consumer system activate the ICF node /sap/bc/z2ui5_rfc in SICF
- Call .../sap/bc/z2ui5_rfc of the consumer system in the browser

The [Guide](/guide) has every step.

## A first app

The [Guide](/guide) shows how it is used.

## Links

- [http-connector](https://github.com/abap2UI5-addons/http-connector)
- [abap2UI5](https://github.com/abap2UI5/abap2UI5)
- [The repository](https://github.com/abap2UI5-addons/rfc-connector) - issues and pull requests welcome
