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

    "copy this class to the rfc connector client system

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
