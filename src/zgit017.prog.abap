*&---------------------------------------------------------------------*
*& Report ZGIT017
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT017.
DATA:HTTP_CLIENT  TYPE REF TO IF_HTTP_CLIENT,
     STR_RETURN   TYPE STRING,
     STR_PARAMENT TYPE STRING,
     URL          TYPE STRING.

STR_PARAMENT = '[{"id":2,"passworld":"222","username":"222"},'
&& '{"id":2,"passworld":"222","username":"222"},'
&& '{"id":2,"passworld":"222","username":"222"},'
&& '{"id":2,"passworld":"222","username":"222"},'
&&'{"id":2,"passworld":"222","username":"222"}]'.

URL = 'http://192.168.40.67:8080/web/helloworld?paramete='&& STR_PARAMENT.

CALL METHOD CL_HTTP_CLIENT=>CREATE_BY_URL
  EXPORTING
    URL                = URL
  IMPORTING
    CLIENT             = HTTP_CLIENT
  EXCEPTIONS
    ARGUMENT_NOT_FOUND = 1
    PLUGIN_NOT_ACTIVE  = 2
    INTERNAL_ERROR     = 3
    OTHERS             = 4.


*HTTP_CLIENT->PROPERTYTYPE_LOGON_POPUP = HTTP_CLIENT->CO_DISABLED.
*
*CALL METHOD HTTP_CLIENT->AUTHENTICATE
*  EXPORTING
**   CLIENT               = ''
*    PROXY_AUTHENTICATION = 'X'
*    USERNAME             = 'UserName'
*    PASSWORD             = 'PassWorld'
*    LANGUAGE             = '1'.
*
CALL METHOD HTTP_CLIENT->REQUEST->SET_HEADER_FIELD
  EXPORTING
    NAME  = 'Content-Type'
*   VALUE = 'application/HTML; charset=utf-8'
    VALUE = 'application/JSON; charset=utf-8'.



CALL METHOD HTTP_CLIENT->REQUEST->SET_METHOD('POST').

CALL METHOD HTTP_CLIENT->REQUEST->SET_CDATA
  EXPORTING
    DATA = STR_PARAMENT.




CALL METHOD HTTP_CLIENT->SEND
  EXCEPTIONS
    HTTP_COMMUNICATION_FAILURE = 1
    HTTP_INVALID_STATE         = 2.
IF SY-SUBRC = 1.

ENDIF.


CALL METHOD HTTP_CLIENT->RECEIVE
  EXCEPTIONS
    HTTP_COMMUNICATION_FAILURE = 1
    HTTP_INVALID_STATE         = 2
    OTHERS                     = 3.

CALL METHOD HTTP_CLIENT->RESPONSE->GET_CDATA
  RECEIVING
    DATA   = STR_RETURN
  EXCEPTIONS
    OTHERS = 1.


"----------------------------json  数据解析

TYPES:BEGIN OF TY_USER,
        ID        TYPE I,
        USERNAME  TYPE STRING,
        PASSWORLD TYPE STRING,
      END OF TY_USER.

DATA: JSON_SER TYPE REF TO CL_TREX_JSON_SERIALIZER,
      JSON_DES TYPE REF TO CL_TREX_JSON_DESERIALIZER,
      IT_USER  TYPE STANDARD TABLE OF TY_USER WITH HEADER LINE.

DATA:DES_JSON TYPE REF TO /UI2/CL_JSON.
CREATE OBJECT DES_JSON.
CALL METHOD DES_JSON->DESERIALIZE
  EXPORTING
    JSON   = STR_RETURN
  CHANGING
    DATA   = IT_USER[]
  EXCEPTIONS
    OTHERS = 1.

LOOP AT  IT_USER.
  WRITE:/ 'id=',IT_USER-ID,' username=',IT_USER-USERNAME.
ENDLOOP.




*CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
*  EXPORTING
*    APPLICATION            = 'JAVA' "需要执行的语言
*    PARAMETER              = 'CAPS_LOCK'   "参数
*    DEFAULT_DIRECTORY      = 'C:/'  "路径
*    MINIMIZED              = 'X'
*    SYNCHRONOUS            = 'WAIT'
*    OPERATION              = 'OPEN'
*  EXCEPTIONS
*    CNTL_ERROR             = 1
*    ERROR_NO_GUI           = 2
*    BAD_PARAMETER          = 3
*    FILE_NOT_FOUND         = 4
*    PATH_NOT_FOUND         = 5
*    FILE_EXTENSION_UNKNOWN = 6
*    ERROR_EXECUTE_FAILED   = 7
*    SYNCHRONOUS_FAILED     = 8
*    NOT_SUPPORTED_BY_GUI   = 9
*    OTHERS                 = 10.
