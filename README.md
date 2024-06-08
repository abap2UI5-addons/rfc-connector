# abap2UI5 - RFC Connector - WIP  🚧
Remotely call abap2UI5 apps via RFC <br>
🚧 work in progress 🚧

<img width="700" alt="Screenshot 2024-06-02 at 16 51 03" src="https://github.com/abap2UI5/abap2UI5-connector_rfc/assets/102328295/d0858b8a-9358-457e-a6c9-a68f6dc227f6"><br>
[Link](https://excalidraw.com/#json=FZbOicm3gdvuq1dNcsSwK,m1I-zU-uLWcL3gERqE3e6w)


### Installation
Handler:
```abap
CLASS z2ui5_cl_rfc_connector_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_rfc_connector_handler IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

    DATA(lv_resp) = ``.
    CALL FUNCTION 'Z2UI5_FM_RFC_CONECTOR'
      DESTINATION 'NONE' "setup your destination here
      EXPORTING
        iv_method   = server->request->get_method( )
        iv_request  = server->request->get_cdata( )
      IMPORTING
        rv_response = lv_resp.

    server->response->set_header_field( name = `cache-control` value = `no-cache` ).
    server->response->set_cdata( lv_resp ).
    server->response->set_status( code = 200 reason = `success` ).

  ENDMETHOD.

ENDCLASS.
```
