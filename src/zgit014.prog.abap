*&---------------------------------------------------------------------*
*& Report ZGIT014
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT014.
TYPE-POOLS ICON.
TABLES MARA.
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
PARAMETERS P_WERKS TYPE WERKS.
SELECTION-SCREEN END OF BLOCK B1.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON 1(4) BUT1 USER-COMMAND BUTTON1 VISIBLE LENGTH 2."按钮，
SELECTION-SCREEN COMMENT 6(20) COM1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME  TITLE TEXT-002.
SELECT-OPTIONS:S_MATNR FOR MARA-MATNR MODIF ID BL1,
               S_GROES FOR MARA-GROES MODIF ID BL1.
SELECTION-SCREEN END OF BLOCK B2 .

INITIALIZATION.
  WRITE ICON_DATA_AREA_EXPAND AS ICON TO BUT1 ."设置按钮BUT1的初始显示图标
  COM1 = 'DATA EXPAND'.

AT SELECTION-SCREEN.
* 按钮BUT1的图标切换
  CASE SY-UCOMM.
    WHEN 'BUTTON1'.
      IF BUT1 = '@K1@'.
        WRITE ICON_DATA_AREA_COLLAPSE AS ICON TO BUT1.
        COM1 = 'DATA COLLAPSE'.
      ELSE.
        WRITE ICON_DATA_AREA_EXPAND AS ICON TO BUT1.
        COM1 = 'DATA EXPAND'.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
* 设置屏幕元素属性
  LOOP AT SCREEN.
    IF BUT1 = '@K2@' AND SCREEN-GROUP1 = 'BL1'.
      SCREEN-ACTIVE = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
