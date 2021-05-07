FUNCTION ZRFC_DEV_REQUEST_IMPORT_GIT.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     VALUE(REQUESTNO) TYPE  STRING
*"  EXPORTING
*"     VALUE(FILES) TYPE  ZTS_REQUEST_FILE_GIT
*"     VALUE(REQUESTNOS) TYPE  STRING
*"----------------------------------------------------------------------


DATA: RESULT_TAB TYPE TABLE OF STRING WITH HEADER LINE.
  "多个请求以逗号分隔
  SPLIT REQUESTNO AT ',' INTO TABLE RESULT_TAB IN CHARACTER MODE.
  DATA: LT_DATA_BINARY TYPE TABLE OF SDOKCNTBIN WITH HEADER LINE.
  DATA: LV_BINARY_LEN TYPE I,LV_LINES TYPE I,LV_TOTAL_LEN TYPE I.
  DATA: V_FILENAME TYPE STRING.
  DATA: LW_FILES LIKE LINE OF FILES.
  LOOP AT RESULT_TAB.
    DO 2 TIMES.
      CLEAR:LW_FILES,LV_TOTAL_LEN,LT_DATA_BINARY[].
      IF SY-INDEX = 1.
        "传输请求所对应的数据文件
        CONCATENATE `/usr/sap/trans/data/R` RESULT_TAB+4 `.DEV` INTO V_FILENAME.
      ELSE.
        "传输请求所对应的配置文件
        CONCATENATE `/usr/sap/trans/cofiles/K` RESULT_TAB+4 `.DEV` INTO V_FILENAME.
      ENDIF.

      "从服务器上读取文件
      LW_FILES-FILENAME = V_FILENAME.
      OPEN DATASET V_FILENAME FOR INPUT IN BINARY MODE.
      DO.
        CLEAR: LT_DATA_BINARY,LV_BINARY_LEN.
        READ DATASET V_FILENAME INTO LT_DATA_BINARY ACTUAL LENGTH LV_BINARY_LEN.
        IF LV_BINARY_LEN > 0.
          LV_TOTAL_LEN = LV_TOTAL_LEN + LV_BINARY_LEN.
          APPEND LT_DATA_BINARY.
          LW_FILES-LAST_LINE_SIZE = LV_BINARY_LEN.
        ELSE.
          LW_FILES-TOTAL_SIZE = LV_TOTAL_LEN.
          EXIT.
        ENDIF.
      ENDDO.
      CLOSE DATASET V_FILENAME.
      LW_FILES-DATA = LT_DATA_BINARY[].

      APPEND LW_FILES TO FILES.
    ENDDO.
  ENDLOOP.
  "返回给Java Web服务器
  REQUESTNOS = REQUESTNO.


ENDFUNCTION.