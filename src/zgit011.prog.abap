*&---------------------------------------------------------------------*
*& Report ZGIT011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT011.

DATA:L_LOG TYPE STRING.
DATA:GT_BDCDATA TYPE TABLE OF BDCDATA WITH HEADER LINE,   "bdc执行内表
     GT_MSGTAB  TYPE TABLE OF BDCMSGCOLL WITH HEADER LINE. "bdc返回信息表
PERFORM BDC_DYNPRO      USING 'SAPMSVMA'
                              '0100'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'VIEWNAME'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=UPD'.
PERFORM BDC_FIELD       USING 'VIEWNAME'
                            'ZEMPLOYEE'. "导入视图的名称
PERFORM BDC_FIELD       USING 'VIMDYNFLDS-LTD_DTA_NO'
                              'X'.
PERFORM BDC_DYNPRO      USING 'SAPLZEMPLOYEEEE'
                              '0001'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'VIM_POSITION_INFO'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=NEWL'.



PERFORM BDC_DYNPRO      USING 'SAPLZEMPLOYEEEE'
                              '0001'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'ZEMPLOYEE-ZAGE(01)'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=SAVE'.
PERFORM BDC_FIELD       USING 'ZEMPLOYEE-ZNUM_PER(01)'
                              '1'.
PERFORM BDC_FIELD       USING 'ZEMPLOYEE-ZNAME(01)'
                               '2'.
PERFORM BDC_FIELD       USING 'ZEMPLOYEE-ZSEX(01)'
                               '3'.
PERFORM BDC_FIELD       USING 'ZEMPLOYEE-ZAGE(01)'
                              '4'.
CALL TRANSACTION 'SM30' USING GT_BDCDATA   "事物代码字母一定要大写，否则无效
                        MODE 'A'      "执行模式
                        MESSAGES INTO GT_MSGTAB
                        UPDATE 'S'.      "批导更新模式（A = '异步',S = '同步'）

READ TABLE GT_MSGTAB WITH KEY MSGTYP = 'E'.
IF SY-SUBRC = 0.
  "获取错误日志
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = GT_MSGTAB-MSGID
      MSGNR               = GT_MSGTAB-MSGNR
      MSGV1               = GT_MSGTAB-MSGV1
      MSGV2               = GT_MSGTAB-MSGV2
      MSGV3               = GT_MSGTAB-MSGV3
      MSGV4               = GT_MSGTAB-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = L_LOG.
  WRITE:/'导入失败:','消息：',L_LOG .
ELSE.
  WRITE:/ '导入成功:'.
ENDIF.

FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR GT_BDCDATA.  "调用哪个功能
  GT_BDCDATA-PROGRAM  = PROGRAM.
  GT_BDCDATA-DYNPRO   = DYNPRO.
  GT_BDCDATA-DYNBEGIN = 'X'.
  APPEND GT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO

FORM BDC_FIELD USING FNAM FVAL.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-FNAM = FNAM.
  GT_BDCDATA-FVAL = FVAL.
  APPEND GT_BDCDATA.
ENDFORM.
