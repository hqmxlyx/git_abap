*&---------------------------------------------------------------------*
*& Report ZGIT015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT015.
WRITE:/ '内外部单位转换'.

DATA:L_OUTPUT(3) TYPE C,
     L_INPUT(3)  TYPE C.

CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
  EXPORTING
    INPUT  = 'ST' "输入的英文单位
  IMPORTING
    OUTPUT = L_OUTPUT. "输出的中文单位

WRITE:/ '内部单位st 转外部单位 = ', L_OUTPUT.


CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
  EXPORTING
    INPUT  = 'PC' "输入的中文单位
  IMPORTING
    OUTPUT = L_INPUT. "输出的英文单位
WRITE:/ '外部单位pc 转内部单位 = ', L_INPUT.
ULINE.


WRITE:/'CONVERSION_EXIT_ALPHA_INPUT'.
ULINE.
WRITE :/                    '单位转换'.
DATA: P_IN     TYPE P DECIMALS 3,
      UNIT_IN  LIKE T006-MSEHI VALUE 'M', "米
      UNIT_OUT LIKE T006-MSEHI VALUE 'MM', "毫米
      ROUND(1) TYPE C VALUE 'X'.
DATA: RESULT TYPE P DECIMALS 3.




CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
  EXPORTING
    INPUT      = P_IN
    ROUND_SIGN = ROUND "舍入方式(+ up, - down, X comm, SPACE.)
    UNIT_IN    = UNIT_IN
    UNIT_OUT   = UNIT_OUT
  IMPORTING
    OUTPUT     = RESULT.
WRITE: '单位转换 Result: ',RESULT.

ULINE.

WRITE:/ '物料单位转换 PC 转换KG'.
WRITE:/ 'MD_CONVERT_MATERIAL_UNIT ， MATERIAL_UNIT_CONVERSION 同样只支持内部单位转换'.

DATA:LV_MATNR     LIKE MARA-MATNR VALUE 'C-FIN-100',
     LV_IN_MEINS  LIKE MARA-MEINS VALUE 'ST',
     LV_OUT_MEINS LIKE MARA-MEINS VALUE 'KG',
     LV_OUT_VALUE LIKE EKPO-MENGE,
     LV_IN_VALUE  LIKE EKPO-MENGE VALUE '10'.

CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
  EXPORTING
    I_MATNR              = LV_MATNR
    I_IN_ME              = LV_IN_MEINS
    I_OUT_ME             = LV_OUT_MEINS
    I_MENGE              = LV_IN_VALUE
  IMPORTING
    E_MENGE              = LV_OUT_VALUE
  EXCEPTIONS
    ERROR_IN_APPLICATION = 1
    ERROR                = 2
    OTHERS               = 3.
IF SY-SUBRC <> 0.
  MESSAGE '转换失败' TYPE 'I'.
ENDIF.
WRITE:/'1 PC 的 C-FIN-100 转换多少KG =' ,LV_OUT_VALUE.

ULINE.

CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
  EXPORTING
    INPUT                = 1
    KZMEINH              = 'X' "如果 in (X,space) X 计量单位=多少基本单位
    MATNR                = 'C-FIN-100'
    MEINH                = 'ST'
  IMPORTING
    OUTPUT               = LV_OUT_VALUE
  EXCEPTIONS
    CONVERSION_NOT_FOUND = 1
    INPUT_INVALID        = 2
    MATERIAL_NOT_FOUND   = 3
    MEINH_NOT_FOUND      = 4
    MEINS_MISSING        = 5
    NO_MEINH             = 6
    OUTPUT_INVALID       = 7
    OVERFLOW             = 8
    OTHERS               = 9.
IF SY-SUBRC <> 0.
  MESSAGE '数据转换失败' TYPE 'I'.
ENDIF.
WRITE :/ '转换2   1 PC 的 C-FIN-100 转换多少KG =', LV_OUT_VALUE.


ULINE.

WRITE:/ 'CONVERT_TO_LOCAL_CURRENCY' ,'CONVERT_TO_FOREIGN_CURRENCY' , '都是以内部金额进行转换的'.
ULINE.

DATA:L_NETPR LIKE VBAP-NETPR,
     L_WAERK LIKE VBAP-WAERK.
DATA: ISOC_FACTOR TYPE P DECIMALS 3.
SELECT SINGLE NETPR WAERK INTO (L_NETPR,L_WAERK) FROM VBAP WHERE VBELN = '2014000000'.

IF SY-SUBRC <> 0.
  MESSAGE '获取数据失败' TYPE 'I'.
ENDIF.
CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
  EXPORTING
    CURRENCY = L_WAERK
  IMPORTING
    FACTOR   = ISOC_FACTOR.

WRITE:/ '货比：' , L_WAERK , '的转换率：', ISOC_FACTOR.

ULINE.
DATA:L_DMBTR LIKE BSEG-DMBTR, "本位币
     L_DMBE2 LIKE BSEG-DMBTR,
     L_DMBE3 LIKE BSEG-DMBTR,
     L_PSWSL LIKE BSEG-PSWSL,
     L_ZHL   TYPE P DECIMALS 3,
     L_AUGDT LIKE BSEG-AUGDT,
     L_BWB2  LIKE BSEG-DMBTR,
     L_BWB3  LIKE BSEG-DMBTR. "货币

SELECT SINGLE DMBTR DMBE2 DMBE3 PSWSL AUGDT INTO ( L_DMBTR,L_DMBE2,L_DMBE3,L_PSWSL,L_AUGDT )   FROM BSEG WHERE
  BUKRS = '1100' AND  BELNR = '0100000015' AND  GJAHR = '2018' AND BUZEI = '1'.


WRITE:/ L_DMBTR,L_DMBE2,L_DMBE3,L_PSWSL.

IF SY-SUBRC <> 0.
  MESSAGE '获取数据失败' TYPE 'I'.
ENDIF.

CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
  EXPORTING
    CURRENCY = 'USD'
  IMPORTING
    FACTOR   = L_ZHL.
.
WRITE:/ '货比：USD 的转换率：' , L_ZHL.

CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
  EXPORTING
    DATE             = L_AUGDT
    FOREIGN_AMOUNT   = L_DMBTR
    FOREIGN_CURRENCY = L_PSWSL
    LOCAL_CURRENCY   = 'HKD'
  IMPORTING
    LOCAL_AMOUNT     = L_BWB2.
WRITE: / '本位币转换相等？' , '转换前=' ,L_DMBE2,'转换后=' ,L_BWB2.

CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY' "将一种货币兑换成另一种货币
  EXPORTING
    DATE             = L_AUGDT
    FOREIGN_AMOUNT   = L_DMBTR "该程序中的jpy本身为外部金额，但在这里会将
    FOREIGN_CURRENCY = L_PSWSL                    "它当作是内部金额，所以最后相当于外部金额1000001
    LOCAL_CURRENCY   = 'USD'
  IMPORTING
    LOCAL_AMOUNT     = L_BWB3. "转换出来的也是内部金额

WRITE: / '本位币转换相等？' , '转换前=' ,L_DMBE3,'转换后=' ,L_BWB3.


DATA: USD(7)    TYPE P DECIMALS 2,
      JPY(7)    TYPE P DECIMALS 2,
      JPY_E(12) TYPE P DECIMALS 4.
DATA: USD_K TYPE WAERS, JPY_K TYPE WAERS.
DATA: RET TYPE BAPIRETURN.

ULINE.
"此处为实际金额，所以不宜直接格式化（只有对内部表中存储格式的金额格式化输出才有意义，
"否则是错误的输出），不过这里为实际的金额似乎也有点不对，因为日元真实金额是不会有小数的，
"所以变量jpy用来存储外部实际金额是不妥的，jpy应该为整数类型才恰当
*JPY = '10000.01'.
*USD_K = 'USD'.
*JPY_K = 'JPY'.

JPY = '825.00'.
USD_K = 'INR'.
JPY_K = 'CNY'.

"使用CONVERT_TO_LOCAL_CURRENCY、CONVERT_TO_FOREIGN_CURRENCY函数时，
"涉及到的金额输入输出参数都是采用内部金额，所以在使用这些函数时，如果是外部金额，应先将它们转换为内部金额后再传入
CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY' "将一种货币兑换成另一种货币
  EXPORTING
    DATE             = SY-DATUM
    FOREIGN_AMOUNT   = JPY "该程序中的jpy本身为外部金额，但在这里会将
    "它当作是内部金额，所以最后相当于外部金额1000001
    FOREIGN_CURRENCY = JPY_K
    LOCAL_CURRENCY   = USD_K
  IMPORTING
    LOCAL_AMOUNT     = USD. "转换出来的也是内部金额


"call function 'CONVERT_TO_FOREIGN_CURRENCY'



*CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*  EXPORTING
*    date             = sy-datum
*    foreign_amount   = '1.00'"内部金额，美元的外部金额也是1.00美元
*    foreign_currency = 'USD'
*    local_currency   = 'JPY'
*  IMPORTING
*    local_amount     = usd."结果为内部金额：1.15，相当于外部金额为115日元

*CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*  EXPORTING
*    date             = sy-datum
*    "如果内部金额没有小数，也要补上两位小数位0，否则实质金额不准确，这里正是
*    "因为末尾未补两位0，所以这里的金额实质上为0.01美元，而不是1美元
*     foreign_amount   = '1'"内部金额，相当于外部0.01美元
*    foreign_currency = 'USD'
*    local_currency   = 'JPY'
*  IMPORTING
*    local_amount     = usd. "结果为：0.01内部金额，实质相当于外部金额1日元

WRITE: JPY, JPY_K,USD, USD_K.
"由于jpy本身为实际金额，所以不能在这里格式输出；但usd为内部
"格式的金额，所以需要使用格式化输出（但usd本身就是带两位小数
"的内部金额，转换
WRITE:/ JPY CURRENCY JPY_K, JPY_K,
       USD CURRENCY USD_K, USD_K.
ULINE.

JPY_E = JPY.
WRITE:/ 'jpy 转换内部金额之前' ,JPY_E .
"将外部金额转换为内部存储金额，实质上过程是将外部金额除以转换因子即可得到
CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
  EXPORTING
    CURRENCY             = JPY_K
    AMOUNT_EXTERNAL      = JPY_E "外部金额
    MAX_NUMBER_OF_DIGITS = 23 "没什么作用，一般写23即可
  IMPORTING
    AMOUNT_INTERNAL      = JPY "转换后的内部存储金额
    RETURN               = RET.
WRITE:/ 'jpy 转换内部金额之后' ,JPY .

"CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'.


CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
  EXPORTING
    DATE             = SY-DATUM
    FOREIGN_AMOUNT   = JPY "源货币金额（内部格式）
    FOREIGN_CURRENCY = JPY_K "源货币类型
    LOCAL_CURRENCY   = USD_K "目标货币类型
  IMPORTING
    LOCAL_AMOUNT     = USD. "目标货币金额（内部格式）
WRITE: JPY, JPY_K,USD, USD_K.
WRITE: / JPY CURRENCY JPY_K, JPY_K,
       USD CURRENCY USD_K, USD_K.


"获取税率
DATA:IT_FTAXP TYPE STANDARD TABLE OF FTAXP.
CALL FUNCTION 'GET_TAX_PERCENTAGE'
  EXPORTING
    ALAND   = 'CN'
    DATAB   = SY-DATUM
    MWSKZ   = 'J1'
    TXJCD   = ''
  TABLES
    T_FTAXP = IT_FTAXP.
