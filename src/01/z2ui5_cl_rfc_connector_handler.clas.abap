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
    " (z2ui5_if_ui5_exit~set_config_http_post -> check_csrf_active).
    CONSTANTS c_check_csrf TYPE abap_bool VALUE abap_true.

  PROTECTED SECTION.
  PRIVATE SECTION.

    " The URL parameter that asks the source system for one of the frontend
    " bundles instead of the page (?z2ui5-bundle, ?z2ui5-bundle=cc, ...) -
    " the name z2ui5_cl_ui5_http_handler gives it, which keeps it private.
    CONSTANTS c_bundle_param TYPE string VALUE `z2ui5-bundle`.

    " The response headers of the source system do not come back with the
    " function module - only body and status do - so the consumer node, the
    " endpoint the browser actually talks to, sets them itself, by the rules
    " the framework applies to its own responses
    " (z2ui5_cl_ui5_http_handler->set_response): the content type, the cache
    " policy per verb and the security headers. Without them a roundtrip went
    " out labelled text/html and without nosniff or framing protection. What
    " it cannot reproduce is what the source answers beyond the defaults: the
    " ETag of the page and the bundles, and headers a user exit on the source
    " system adds - see get_security_headers.
    CLASS-METHODS get_header_fields
      IMPORTING
        !method       TYPE clike
        status_code   TYPE i
        t_params      TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_t_name_value.

    " The cases the framework distinguishes: an error body is plain text (it
    " may quote the app name back - never rendered as markup), a bundle is
    " JavaScript, the page is HTML, every other successful roundtrip is the
    " model JSON.
    CLASS-METHODS get_content_type
      IMPORTING
        !method       TYPE clike
        status_code   TYPE i
        t_params      TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    " The security headers every abap2UI5 response carries by default (the
    " t_security_header rows of the shipped user exit). A user exit of the
    " source system cannot reach the browser through the connector: a system
    " that changes these rows there changes them here as well.
    CLASS-METHODS get_security_headers
      RETURNING
        VALUE(result) TYPE z2ui5_if_client=>ty_t_name_value.

ENDCLASS.


CLASS z2ui5_cl_rfc_connector_handler IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

    DATA ls_res         TYPE z2ui5_s_rfc_res.
    DATA ls_config      TYPE z2ui5_s_rfc_config.
    " DESTINATION takes a character field, so the string constant cannot be
    " passed directly
    DATA lv_destination TYPE c LENGTH 32.

    DATA(lo_server) = z2ui5_cl_ui5_util_http=>factory( server ).
    DATA(ls_info) = lo_server->get_req_info( ).
    " method, body, path and the raw query - the structure has no room for
    " the parsed t_params, the source system parses the query again
    DATA(ls_req) = CORRESPONDING z2ui5_s_rfc_req( ls_info ).

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

      CALL FUNCTION 'Z2UI5_FM_RFC_CONNECTOR'
        DESTINATION lv_destination
        EXPORTING
          is_req                = ls_req
          is_config             = ls_config
        IMPORTING
          es_res                = ls_res
        EXCEPTIONS
          system_failure        = 1
          communication_failure = 2
          resource_failure      = 3
          OTHERS                = 4.

      IF sy-subrc <> 0.
        " The call never reached the source system, or failed there: the
        " destination missing or not authorized, the system down, a short dump
        " in the function module. The frontend renders the body of every
        " non-2xx response in its error overlay, so a body has to be there - a
        " short dump here would end in the ICF 500 page. It names no
        " destination, host or user, and not the RFC message, which does: the
        " overlay is shown to every user, the reason is for the administrator
        " (SM59, ST22 and SM21 of the source system).
        ls_res = VALUE #( body          = |RFC_CONNECTOR_ERROR - the source system could not be reached (subrc { sy-subrc })|
                          status_code   = 502
                          status_reason = `Bad Gateway` ).

      ELSEIF ls_res-status_code IS INITIAL.
        " A source system still running a connector version whose
        " Z2UI5_S_RFC_RES has no status fields answers with 0, which the ICF
        " sends as an empty response the browser cannot read.
        ls_res-status_code   = 200.
        ls_res-status_reason = `OK`.
      ENDIF.

    ENDIF.

    lo_server->set_cdata( ls_res-body ).
    LOOP AT get_header_fields( method      = ls_req-method
                               status_code = ls_res-status_code
                               t_params    = ls_info-t_params ) INTO DATA(ls_header).
      lo_server->set_header_field( n = ls_header-n
                                   v = ls_header-v ).
    ENDLOOP.
    lo_server->set_status( code   = ls_res-status_code
                           reason = ls_res-status_reason ).

  ENDMETHOD.

  METHOD get_header_fields.

    result = VALUE #( ( n = `content-type`
                        v = get_content_type( method      = method
                                              status_code = status_code
                                              t_params    = t_params ) ) ).

    " The cache policy of the framework, per verb: the page and the bundles
    " carry no user or app data and may be stored, but are revalidated (with
    " no ETag to send, a revalidation is a full GET). Everything else - the
    " roundtrip data, an error, a HEAD - is never stored.
    IF method = `GET` AND status_code < 300.
      INSERT VALUE #( n = `cache-control`
                      v = `private, no-cache` ) INTO TABLE result.
    ELSE.
      INSERT VALUE #( n = `cache-control`
                      v = `no-cache, no-store, must-revalidate` ) INTO TABLE result.
      INSERT VALUE #( n = `Pragma`
                      v = `no-cache` ) INTO TABLE result.
      INSERT VALUE #( n = `Expires`
                      v = `0` ) INTO TABLE result.
    ENDIF.

    INSERT LINES OF get_security_headers( ) INTO TABLE result.

  ENDMETHOD.

  METHOD get_content_type.

    " the names come lower-cased from the query parser - the framework's own
    " check of the bundle parameter reads them the same way
    result = COND #( WHEN status_code >= 400 THEN `text/plain; charset=UTF-8`
                     WHEN method <> `GET`    THEN `application/json; charset=UTF-8`
                     WHEN line_exists( t_params[ n = c_bundle_param ] ) "#EC CI_SORTSEQ
                                             THEN `application/javascript; charset=UTF-8`
                     ELSE `text/html; charset=UTF-8` ).

  ENDMETHOD.

  METHOD get_security_headers.

    result = VALUE #(
        ( n = `X-Content-Type-Options`       v = `nosniff` )
        ( n = `X-Frame-Options`              v = `SAMEORIGIN` )
        ( n = `Referrer-Policy`              v = `strict-origin-when-cross-origin` )
        ( n = `Permissions-Policy`           v = `geolocation=(self), microphone=(self), camera=(self), payment=(), usb=()` )
        ( n = `Cross-Origin-Resource-Policy` v = `same-origin` ) ).

  ENDMETHOD.

ENDCLASS.
