*&---------------------------------------------------------------------*
*& Report ZGIT005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT005.

DATA:BEGIN OF ITAB OCCURS 0,
       LINE(3000) TYPE C,         "如果代码中某行大于了200个字符，请重新设定值，
     END OF ITAB.

PARAMETERS: PROGNAME(120).       "程序名称
PROGNAME = 'ZABAPRP002'.

READ REPORT PROGNAME INTO ITAB.  "把指定的程序读取到内表

EDITOR-CALL FOR ITAB.            "对内表数据进行修改（即代码进入编辑状态)

INSERT REPORT PROGNAME FROM ITAB."把修改后的程序插回sap
