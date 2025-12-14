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

    DATA(ls_req2) = z2ui5_cl_http_handler=>get_request( server = server ).
    DATA(ls_req) = CORRESPONDING z2ui5_s_http_req( ls_req2 ).
    DATA(ls_config) = VALUE z2ui5_s_http_config( ).
    DATA(ls_res) = VALUE z2ui5_s_http_res( ).

    CALL FUNCTION 'Z2UI5_FM_RFC_CONECTOR'
      DESTINATION 'NONE'
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

    server->response->set_cdata( ls_res-body ).
    server->response->response->set_header_field( n = `cache-control`
                             v = `no-cache` ).

  ENDMETHOD.

ENDCLASS.
