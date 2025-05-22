## RFC Connector

Remotely Call abap2UI5 Apps via RFC. More Information [here.](https://abap2ui5.github.io/docs/advanced/rfc.html)

### Approach
Remotely call abap2UI5 apps via RFC:
<img width="800" alt="image" src="https://github.com/abap2UI5/abap2UI5-connector_rfc/assets/102328295/5787755c-f4f1-48d8-a9da-50b4f04db9ed">
<br>

### Installation
Install this repository with abapGit on the system. Install this handler on client system.
Handler:
```abap
CLASS z2ui5_cl_rfc_connector_handler DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS z2ui5_cl_rfc_connector_handler IMPLEMENTATION.
  METHOD if_http_extension~handle_request.

    DATA(ls_req2) = z2ui5_cl_http_handler=>get_request( server = server ).
    DATA(ls_req) = CORRESPONDING z2ui5_s_http_req( ls_req2 ).
    DATA(ls_config) = VALUE z2ui5_s_http_config( ).
    DATA(ls_res) = VALUE z2ui5_s_http_res( ).

    CALL FUNCTION 'Z2UI5_FM_RFC_CONECTOR'
      EXPORTING
        is_req                = ls_req
        is_config             = ls_config
      IMPORTING
        es_res                = ls_res
      EXCEPTIONS
        system_failure        = 1
        communication_failure = 2
        resource_failure      = 3.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    z2ui5_cl_http_handler=>get_response(
      server = server
      is_res = CORRESPONDING #( ls_res ) ).

  ENDMETHOD.
ENDCLASS.
```
Setup destinations in SM50 that both systems can call each other and create an ICF Endpoint to call your abap2UI5 apps.
