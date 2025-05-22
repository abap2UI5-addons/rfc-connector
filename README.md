## RFC Connector

Remotely Call abap2UI5 Apps via RFC. More Information [here.](https://abap2ui5.github.io/docs/advanced/rfc.html)

#### Approach
Remotely call abap2UI5 apps via RFC:
<img width="700" alt="image" src="https://github.com/abap2UI5/abap2UI5-connector_rfc/assets/102328295/5787755c-f4f1-48d8-a9da-50b4f04db9ed">
<br>

#### Installation

Prerequisite: Set up a destination in SM59 that the source system can be called via RFC.

Steps:
1. Install this repository on both system.
2. Replace in the HTTP handler the destination `NONE` with your Source System Destination
3. Call iny our browser the endpoint `.../sap/bc/2ui5_rfc`



#### Contribution & Support
Pull requests are welcome! Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated. If you encounter any issues, feel free to open an issue.
