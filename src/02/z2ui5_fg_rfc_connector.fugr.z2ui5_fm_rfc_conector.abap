FUNCTION z2ui5_fm_rfc_conector.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_REQ) TYPE  Z2UI5_S_HTTP_REQ
*"     VALUE(IS_CONFIG) TYPE  Z2UI5_S_HTTP_CONFIG
*"  EXPORTING
*"     VALUE(ES_RES) TYPE  Z2UI5_S_HTTP_RES
*"----------------------------------------------------------------------

* The name before the spelling was fixed - Z2UI5_FM_RFC_CONNECTOR does the
* work. It stays for consumer systems on an earlier version, which call it by
* this name over RFC: never remove it or change its interface.
  CALL FUNCTION 'Z2UI5_FM_RFC_CONNECTOR'
    EXPORTING
      is_req    = is_req
      is_config = is_config
    IMPORTING
      es_res    = es_res.

ENDFUNCTION.
