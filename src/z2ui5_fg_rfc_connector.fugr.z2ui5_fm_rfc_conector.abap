FUNCTION z2ui5_fm_rfc_conector.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_REQ) TYPE  Z2UI5_S_HTTP_REQ
*"     VALUE(IS_CONFIG) TYPE  Z2UI5_S_HTTP_CONFIG
*"  EXPORTING
*"     VALUE(ES_RES) TYPE  Z2UI5_S_HTTP_RES
*"----------------------------------------------------------------------
  DATA(ls_res) = z2ui5_cl_http_handler=>_main(
        is_config = CORRESPONDING #( is_config )
        is_req    = CORRESPONDING #( is_req )
    ).

  es_res = CORRESPONDING #( ls_res ).

ENDFUNCTION.
