FUNCTION z2ui5_fm_rfc_conector.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_METHOD) TYPE  STRING
*"     VALUE(IV_REQUEST) TYPE  STRING
*"  EXPORTING
*"     VALUE(RV_RESPONSE) TYPE  STRING
*"----------------------------------------------------------------------
  rv_response = SWITCH #( iv_method
     WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
     WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post( iv_request ) ).


ENDFUNCTION.
