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

    "setup the destination here
    CALL FUNCTION 'Z2UI5_FM_RFC_CONECTOR'
      DESTINATION 'NONE'
      EXPORTING
        iv_method             = server->request->get_method( )
        iv_request            = server->request->get_cdata( )
      IMPORTING
        rv_response           = lv_resp
      EXCEPTIONS
        system_failure        = 1
        communication_failure = 2
        resource_failure      = 3.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.

    server->response->set_header_field( name = `cache-control` value = `no-cache` ).
    server->response->set_cdata( lv_resp ).
    server->response->set_status( code = 200 reason = `success` ).

  ENDMETHOD.

ENDCLASS.
