*&---------------------------------------------------------------------*
*& Report ZGIT022
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT022.
"TCODE:OAOR 上传
DATA:CONTROL     TYPE REF TO I_OI_CONTAINER_CONTROL,
     DOCUMENT    TYPE REF TO I_OI_DOCUMENT_PROXY,
     SPREADSHEET TYPE REF TO I_OI_SPREADSHEET,
     ERROR       TYPE REF TO I_OI_ERROR,
     ERRORS      TYPE REF TO I_OI_ERROR OCCURS 0 WITH HEADER LINE.


DATA: BDS_INSTANCE TYPE REF TO CL_BDS_DOCUMENT_SET.
DATA: DOC_URIS    TYPE SBDST_URI,
      WA_DOC_URIS LIKE LINE OF DOC_URIS.

DATA:L_URL TYPE BDS_URI.

*CALL METHOD C_OI_CONTAINER_CONTROL_CREATOR=>GET_CONTAINER_CONTROL
*  IMPORTING
*    CONTROL = CONTROL
*    ERROR   = ERROR.
*
*CALL METHOD CONTROL->GET_DOCUMENT_PROXY
*  EXPORTING
*    DOCUMENT_TYPE  = 'Excel.Sheet'
*    NO_FLUSH       = 'X'
*  IMPORTING
*    DOCUMENT_PROXY = DOCUMENT
*    ERROR          = ERRORS.

CALL METHOD CL_BDS_DOCUMENT_SET=>GET_WITH_URL
  EXPORTING
    CLASSNAME  = 'HRFPM_EXCEL_STANDARD'
    CLASSTYPE  = 'OT'
    OBJECT_KEY = 'ZTEST'
  CHANGING
    URIS       = DOC_URIS
  EXCEPTIONS
    OTHERS     = 1.


LOOP AT DOC_URIS INTO WA_DOC_URIS.
  L_URL = WA_DOC_URIS-URI.
  EXIT.
ENDLOOP.



** open a document saved in business document service.
*CALL METHOD DOCUMENT->OPEN_DOCUMENT
*  EXPORTING
*    OPEN_INPLACE = 'X'
*    DOCUMENT_URL = L_URL.
*
*DATA: HAS TYPE I.
*CALL METHOD DOCUMENT->HAS_SPREADSHEET_INTERFACE
*  EXPORTING
*    NO_FLUSH     = 'X'
*  IMPORTING
*    IS_AVAILABLE = HAS
*    ERROR        = ERRORS.
*
*CALL METHOD DOCUMENT->GET_SPREADSHEET_INTERFACE
*  EXPORTING
*    NO_FLUSH        = 'X'
*  IMPORTING
*    SHEET_INTERFACE = SPREADSHEET
*    ERROR           = ERRORS.
*
*IF SPREADSHEET IS INITIAL.
*  "MESSAGE STXT01  TYPE 'E'.
*  EXIT.
*ENDIF.
** Activate  sheet
**CALL METHOD SPREADSHEET->SELECT_SHEET
**  EXPORTING
**    NAME     = ACTIVE_SHEET
**    NO_FLUSH = ''
**  IMPORTING
**    ERROR    = ERRORS.