*&---------------------------------------------------------------------*
*& Report ZGIT006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT006.


"参考 https://www.cnblogs.com/jiangzhengjun/p/8514732.html

DATA:FILES     TYPE ZTS_REQUEST_FILE,
     REQUESTNO TYPE STRING.
CALL FUNCTION 'ZRFC_DEV_REQUEST_IMPORT_GIT' DESTINATION 'CALL_TO_KUS_400'
  EXPORTING
    REQUESTNO  = 'DEVK912055'
  IMPORTING
    FILES      = FILES
    REQUESTNOS = REQUESTNO.

LOOP AT FILES ASSIGNING FIELD-SYMBOL(<WA_FILES>).

ENDLOOP.

CALL FUNCTION 'ZRFC_PRD_REQUEST_EXPROT_GIT'
  EXPORTING
    FILES      = FILES
    REQUESTNOS = REQUESTNO.
