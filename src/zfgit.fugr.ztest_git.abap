FUNCTION ZTEST_GIT.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(MATNR) TYPE  MATNR
*"  EXPORTING
*"     VALUE(MAKTX) TYPE  MAKTX
*"  TABLES
*"      IT_MARA STRUCTURE  MARA OPTIONAL
*"----------------------------------------------------------------------

  SELECT SINGLE MAKTX INTO MAKTX FROM MAKT WHERE MATNR = MATNR AND SPRAS = SY-LANGU.


ENDFUNCTION.
