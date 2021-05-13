*&---------------------------------------------------------------------*
*& Report ZGIT008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT008.


DATA:I_EINA       TYPE  MEWIEINA,
     I_EINAX      TYPE  MEWIEINAX,
     I_EINE       TYPE  MEWIEINE,
     I_EINEX      TYPE  MEWIEINEX,
     E_EINA       TYPE  MEWIEINA,
     E_EINE       TYPE  MEWIEINE,
     IT_COND      TYPE  STANDARD TABLE OF MEWICONDITION  WITH HEADER LINE,
     IT_CONDVALI  TYPE STANDARD TABLE OF MEWIVALIDITY  WITH HEADER LINE,
     IT_CONDSCALE TYPE STANDARD TABLE OF MEWISCALEQUAN WITH HEADER LINE,
     IT_RETURN    TYPE MEWI_T_RETURN.

I_EINA-INFO_REC = '5300000005'."采购信息记录好
I_EINA-VENDOR = '0000100010'."供应商
I_EINA-MATERIAL = '000000301010000003'."不输入物料会提示 采购信息记录已存在
I_EINA-MAT_GRP = '30103'.
I_EINA-PO_UNIT = 'ST'.
I_EINA-REMINDER1 = '2'."第一封催询单天数

I_EINAX-INFO_REC = 'X'."采购信息记录好
I_EINAX-VENDOR = 'X'."供应商
I_EINAX-MATERIAL = 'X'.
I_EINAX-MAT_GRP = 'X'.
I_EINAX-PO_UNIT = 'X'.
I_EINAX-REMINDER1 = 'X'.


I_EINE-INFO_REC = '5300000005'."采购信息记录好
I_EINE-PURCH_ORG = '1100'.
I_EINE-INFO_TYPE = '0'.
I_EINE-PLANT = '1101'.
I_EINE-NET_PRICE = '21'.
I_EINE-ORDERPR_UN = 'ST'.

I_EINEX-INFO_REC = 'X'."采购信息记录好
I_EINEX-PURCH_ORG = 'X'.
I_EINEX-INFO_TYPE = 'X'.
I_EINEX-PLANT = 'X'.
I_EINEX-NET_PRICE = 'X'.
I_EINEX-ORDERPR_UN = 'X'.


"修改
IT_CONDVALI-SERIAL_ID = '0000011518'."
IT_CONDVALI-BASE_UOM = 'PCS'.
IT_CONDVALI-BASE_UOM_ISO = 'ST'.
IT_CONDVALI-PLANT = '1101'.
IT_CONDVALI-VALID_FROM = '20170917'.
IT_CONDVALI-VALID_TO = '20170930'.
APPEND IT_CONDVALI.
CLEAR:IT_CONDVALI.


"新增
IT_CONDVALI-BASE_UOM = 'PCS'.
IT_CONDVALI-BASE_UOM_ISO = 'ST'.
IT_CONDVALI-PLANT = '1101'.
IT_CONDVALI-VALID_FROM = '20210101'.
IT_CONDVALI-VALID_TO = '99991231'.
APPEND IT_CONDVALI.
CLEAR:IT_CONDVALI.

IT_COND-SERIAL_ID = '0000011518'."
IT_COND-COND_COUNT = '01'.
IT_COND-COND_TYPE = 'PB00'.
IT_COND-CURRENCY = 'CNY'.
IT_COND-COND_VALUE = '21'.
IT_COND-COND_P_UNT = '1'.
IT_COND-COND_UNIT = 'ST'.
IT_COND-CHANGE_ID = 'U'."更新标识
APPEND IT_COND.
CLEAR IT_COND.

IT_COND-COND_TYPE = 'PB00'.
IT_COND-CURRENCY = 'CNY'.
IT_COND-COND_VALUE = '29'.
IT_COND-COND_P_UNT = '1'.
IT_COND-COND_UNIT = 'ST'.
IT_COND-CHANGE_ID = 'I'."更新标识
APPEND IT_COND.
CLEAR IT_COND.
"阶梯价
IT_CONDSCALE-SERIAL_NO = '0000011518'."
IT_CONDSCALE-COND_COUNT = '01'.
IT_CONDSCALE-SCALE_BASE_QTY = '10'.
IT_CONDSCALE-COND_VALUE = '19'.
IT_CONDSCALE-LINE_NO = '0001'.
APPEND IT_CONDSCALE.
CLEAR IT_CONDSCALE.

IT_CONDSCALE-SERIAL_NO = '0000011518'."
IT_CONDSCALE-COND_COUNT = '01'.
IT_CONDSCALE-SCALE_BASE_QTY = '20'.
IT_CONDSCALE-COND_VALUE = '15'.
IT_CONDSCALE-LINE_NO = '0002'.
APPEND IT_CONDSCALE.
CLEAR IT_CONDSCALE.

CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
  EXPORTING
    I_EINA          = I_EINA
    I_EINAX         = I_EINAX
    I_EINE          = I_EINE
    I_EINEX         = I_EINEX
    TESTRUN         = ''
  IMPORTING
    E_EINA          = E_EINA
    E_EINE          = E_EINE
  TABLES
    COND_VALIDITY   = IT_CONDVALI
    CONDITION       = IT_COND
    COND_SCALE_QUAN = IT_CONDSCALE
    RETURN          = IT_RETURN.

LOOP AT IT_RETURN ASSIGNING FIELD-SYMBOL(<WA_RETURN>) WHERE TYPE = 'E' OR TYPE = 'A'.

ENDLOOP.
IF SY-SUBRC = 0.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDIF.