CLASS z2ui5_cl_rfc_connector_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.

    " replace with your SM59 destination (type 3) pointing to the source system
    CONSTANTS c_destination TYPE string VALUE `NONE`.
    " The consumer node is the endpoint the browser talks to, so the CSRF gate
    " of the framework has to run here - over RFC the source system sees no
    " request headers at all and lets every POST through. Set to abap_false
    " only if the source system opts out through its own user exit
    " (z2ui5_if_exit~set_config_http_post -> check_csrf_active).
    CONSTANTS c_check_csrf TYPE abap_bool VALUE abap_true.

  PROTECTED SECTION.
  PRIVATE SECTION.

    " The function module carries body and status back, but no headers - so
    " the content type is derived from the same three cases the framework
    " itself uses (z2ui5_cl_ui5_http_handler=>set_response): an error body is
    " plain text, a GET answers the HTML shell, every other successful
    " roundtrip is the model JSON. Without it the ICF default (text/html)
    " labels the JSON roundtrip, and an error text - which may quote the app
    " name back - could be rendered as markup.
    CLASS-METHODS get_content_type
      IMPORTING
        !method       TYPE clike
        status_code   TYPE i
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_rfc_connector_handler IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

    DATA ls_res         TYPE z2ui5_s_http_res.
    DATA ls_config      TYPE z2ui5_s_http_config.
    DATA lv_message     TYPE string.
    " DESTINATION takes a character field, so the constant cannot be passed
    " directly - and it stays a string so the error message below does not
    " carry the padding of a fixed-length field
    DATA lv_destination TYPE c LENGTH 32.

    DATA(lo_server) = z2ui5_cl_ui5_util_http=>factory( server ).
    " method, body, path and the raw query - the structure has no room for
    " the parsed t_params, the source system parses the query again
    DATA(ls_req) = CORRESPONDING z2ui5_s_http_req( lo_server->get_req_info( ) ).

    IF ls_req-method = `POST`
       AND z2ui5_cl_ui5_http_handler=>_check_csrf_rejected(
               active  = c_check_csrf
               origin  = lo_server->get_header_field( `origin` )
               referer = lo_server->get_header_field( `referer` )
               host    = lo_server->get_header_field( `host` ) ) = abap_true.

      ls_res = VALUE #( body          = `CSRF validation failed - cross-origin POST rejected`
                        status_code   = 403
                        status_reason = `Forbidden` ).

    ELSEIF ls_req-method = `HEAD`.

      " HEAD only ends the ICF session of a stateful app. Every RFC call runs
      " in its own context on the source system, so there is no session there
      " to end - answering here saves a roundtrip that could do nothing.
      ls_res = VALUE #( status_code   = 200
                        status_reason = `OK` ).

    ELSE.

      lv_destination = c_destination.

      CALL FUNCTION 'Z2UI5_FM_RFC_CONECTOR'
        DESTINATION lv_destination
        EXPORTING
          is_req                = ls_req
          is_config             = ls_config
        IMPORTING
          es_res                = ls_res
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_message
          communication_failure = 2 MESSAGE lv_message
          resource_failure      = 3
          OTHERS                = 4.

      IF sy-subrc <> 0.
        " This used to be an ASSERT, which ends in a short dump and the ICF 500
        " page - and that page suppresses the text, so the browser showed an
        " empty error overlay. The frontend renders the body of every non-2xx
        " response, so the RFC reason has to travel in it.
        ls_res = VALUE #( body          = |RFC_CONNECTOR_ERROR - destination { c_destination }, |
                                       && |subrc { sy-subrc } { lv_message }|
                          status_code   = 500
                          status_reason = `Internal Server Error` ).

      ELSEIF ls_res-status_code IS INITIAL.
        " A source system still running a connector version whose
        " Z2UI5_S_HTTP_RES has no status fields answers with 0, which the ICF
        " sends as an empty response the browser cannot read.
        ls_res-status_code   = 200.
        ls_res-status_reason = `OK`.
      ENDIF.

    ENDIF.

    lo_server->set_cdata( ls_res-body ).
    lo_server->set_header_field( n = `content-type`
                                 v = get_content_type( method      = ls_req-method
                                                       status_code = ls_res-status_code ) ).
    lo_server->set_header_field( n = `cache-control`
                                 v = `no-cache` ).
    lo_server->set_status( code   = ls_res-status_code
                           reason = ls_res-status_reason ).

  ENDMETHOD.

  METHOD get_content_type.

    result = COND #( WHEN status_code >= 400 THEN `text/plain; charset=UTF-8`
                     WHEN method = `GET`     THEN `text/html; charset=UTF-8`
                     ELSE `application/json; charset=UTF-8` ).

  ENDMETHOD.

ENDCLASS.
