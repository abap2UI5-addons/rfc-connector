FUNCTION z2ui5_fm_rfc_conector.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_REQ) TYPE  Z2UI5_S_HTTP_REQ
*"     VALUE(IS_CONFIG) TYPE  Z2UI5_S_HTTP_CONFIG
*"  EXPORTING
*"     VALUE(ES_RES) TYPE  Z2UI5_S_HTTP_RES
*"----------------------------------------------------------------------

* IS_CONFIG is reserved: the framework reads its HTTP configuration from the
* user exit of the system the apps run on - this one - so there is nothing to
* inject from the consumer side. It stays in the interface because removing a
* parameter from an RFC-enabled function module breaks every consumer system
* that still runs the previous version.

* PATH and QUERY are the consumer's: the path the browser called, and its
* query string raw. The query is parsed here exactly as an ICF request of this
* system would be (z2ui5_cl_ui5_util_http=>get_req_info), so ?z2ui5-bundle,
* app_start and every other parameter reach the framework and the user exit.
* A consumer still on a version without the two fields sends them empty,
* which is the behaviour of that version.
  DATA(ls_req) = CORRESPONDING z2ui5_cl_ui5_http_handler=>ty_s_http_req( is_req ).
  ls_req-t_params = z2ui5_cl_ui5_util_context=>url_param_get_tab( |?{ is_req-query }| ).

* _main( ) never raises - it turns any exception into a 500 whose body carries
* the reason - so ES_RES always describes the response, status included. The
* consumer only forwards it.
  DATA(ls_res) = z2ui5_cl_ui5_http_handler=>_main( ls_req ).

  es_res = CORRESPONDING #( ls_res ).

ENDFUNCTION.
