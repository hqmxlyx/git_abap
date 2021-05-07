*&---------------------------------------------------------------------*
*& Report ZGIT003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT003.

TABLES:PRPS,PROJ,VBAK,VBAP.
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_WERKS FOR PROJ-WERKS,
                S_ERDAT FOR PRPS-ERDAT ,     "公司代码
                S_PSPNR FOR PROJ-PSPNR,     "发票过帐日期
                S_MODEL FOR PRPS-USR00, "模治具编号
                S_USR01 FOR PRPS-USR01,"产品料号
                S_DATUM FOR SY-DATUM.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
PARAMETERS:R1 RADIOBUTTON GROUP G1 DEFAULT 'X',
           R2 RADIOBUTTON GROUP G1,
           R3 RADIOBUTTON GROUP G1.
SELECTION-SCREEN END OF BLOCK B2.

DATA: IT_FIELDCAT        TYPE LVC_T_FCAT,
      WA_FIELDCAT        TYPE LVC_S_FCAT,
      IT_FIELDCAT_DIALOG TYPE LVC_T_FCAT,
      WA_LAYOUT          TYPE LVC_S_LAYO.

DATA:CL_GRID TYPE REF TO CL_GUI_ALV_GRID.

TYPES:BEGIN OF TY_ITEM,
        SEL        TYPE C,
        XZ         TYPE C,
        ICON       TYPE ICON_D,     "状态
        BUTTON     TYPE CHAR4, "显示为按键字段
        CLR        TYPE CHAR4, "行颜色设置
        COLLCOLOR  TYPE LVC_T_SCOL, "单元格颜色
        CELLSTYLES TYPE LVC_T_STYL. "单元格颜色(可编辑，按键等)
        INCLUDE TYPE ZEMPLOYEE.
      TYPES END OF  TY_ITEM.

DATA:IT_ITEM TYPE STANDARD TABLE OF TY_ITEM,
     WA_ITEM LIKE LINE OF IT_ITEM.

DEFINE   MACRO_FILL_FCAT.
  CLEAR WA_FIELDCAT.
  &1 = &1 + 1.
  WA_FIELDCAT-COL_POS       = &1.
  WA_FIELDCAT-FIELDNAME     = &2.
  WA_FIELDCAT-SCRTEXT_L     = &3.
  WA_FIELDCAT-SCRTEXT_M     = &3.
  WA_FIELDCAT-SCRTEXT_S     = &3.
  WA_FIELDCAT-OUTPUTLEN     = &4.
  WA_FIELDCAT-NO_ZERO       = 'X'.
  WA_FIELDCAT-FIX_COLUMN    = &5. "固定列
  WA_FIELDCAT-KEY           = &5. "固定列
  WA_FIELDCAT-EDIT          = &6. "可编辑字段
  WA_FIELDCAT-REF_TABLE     = &7. "内表名称
  WA_FIELDCAT-REF_FIELD     = &8."内表字段名称
  WA_FIELDCAT-EMPHASIZE     = &9."列颜色
  IF WA_FIELDCAT-FIELDNAME = 'ZSEX'.
    WA_FIELDCAT-HOTSPOT = 'X'."热点事件
  ENDIF.
  IF WA_FIELDCAT-FIELDNAME = 'ZNUM_PER'.
    WA_FIELDCAT-F4AVAILABL    = 'X'."F4 帮助字段
  ENDIF.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
END-OF-DEFINITION.

"按键点击事件
CLASS CL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS: HANDLE_BUTTON_CLICK
                FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID ES_ROW_NO.
    METHODS: HANDLE_MODIFY
                FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS:
      HANDLE_F4
                  FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING E_FIELDNAME
                  ES_ROW_NO
                  ER_EVENT_DATA
                  ET_BAD_CELLS.
ENDCLASS.

CLASS CL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_BUTTON_CLICK.
    MESSAGE '按键点击事件！' TYPE 'I'.
  ENDMETHOD.
  "前提示fieldcat 属性设置为F4
  METHOD  HANDLE_F4.
    PERFORM FRM_SEARCH_HELP  USING E_FIELDNAME ES_ROW_NO.
  ENDMETHOD.

  METHOD HANDLE_MODIFY.
    DATA:IT_CELLS TYPE STANDARD TABLE OF LVC_S_POS,
         WA_CELLS LIKE LINE OF IT_CELLS.

    LOOP AT ET_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<WA_CELLS>).
      READ TABLE IT_ITEM ASSIGNING FIELD-SYMBOL(<WA_ITEM>) INDEX <WA_CELLS>-ROW_ID.
      IF SY-SUBRC = 0.
        <WA_ITEM>-ZNAME = '修改的值'.
      ENDIF.

      WA_CELLS-FIELDNAME = 'ZNAME'.
      WA_CELLS-ROW_ID = <WA_CELLS>-ROW_ID.
      APPEND WA_CELLS TO IT_CELLS.
      CLEAR WA_CELLS.
    ENDLOOP.

    CALL METHOD CL_GRID->CHANGE_DATA_FROM_INSIDE
      EXPORTING
        IT_CELLS = IT_CELLS.
  ENDMETHOD.

ENDCLASS.




INITIALIZATION.


START-OF-SELECTION.
  PERFORM FRM_PROCESS_DATA.

END-OF-SELECTION.
  PERFORM FRM_INIT_FIELDCAT.
  PERFORM FRM_INIT_LAYOUT.
  PERFORM FRM_ALV_OUTPUT.


FORM FRM_PROCESS_DATA .
  DATA:WA_CELLCOLOR TYPE LVC_S_SCOL."单云格颜色表
  DATA:WA_STYLEROW TYPE LVC_T_STYL WITH HEADER LINE.

  DATA:L_LINE TYPE I.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ITEM FROM ZEMPLOYEE.

  LOOP AT  IT_ITEM ASSIGNING FIELD-SYMBOL(<WA_ITEM>).
    L_LINE = L_LINE + 1.
    "行颜色
    IF SY-TABIX = 2.
      <WA_ITEM>-CLR = 'C700'.
    ENDIF.

    "显示按键
    <WA_ITEM>-BUTTON = ICON_EXECUTE_OBJECT.
    WA_STYLEROW-FIELDNAME = 'BUTTON'.
    WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
    APPEND WA_STYLEROW TO <WA_ITEM>-CELLSTYLES.


    "单元格颜色
    WA_CELLCOLOR-FNAME = 'ZNUM_PER'.
    WA_CELLCOLOR-COLOR-COL = 3.
    WA_CELLCOLOR-COLOR-INT = 1.
    WA_CELLCOLOR-COLOR-INV = 0.
    APPEND WA_CELLCOLOR TO <WA_ITEM>-COLLCOLOR.

    "动态可编辑(前提是该列可以编辑的才有效果)
    IF L_LINE = 3.
      WA_STYLEROW-FIELDNAME = 'ZNAME'.
      "WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED. "可编辑
      WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED. "不可编辑
      APPEND WA_STYLEROW TO <WA_ITEM>-CELLSTYLES.
    ENDIF.


  ENDLOOP.
ENDFORM.



FORM FRM_INIT_FIELDCAT .
  DATA: L_COLPOS TYPE LVC_S_FCAT-COL_POS.
  MACRO_FILL_FCAT L_COLPOS 'ZNUM_PER' '工号' '4' '' '' '' '' 'C600'.
  MACRO_FILL_FCAT L_COLPOS 'ZNAME' '姓名' '4' '' 'X' 'ZEMPLOYEE' 'ZNAME' ''.
  MACRO_FILL_FCAT L_COLPOS 'ZSEX' '姓名' '4' '' '' '' '' ''.
  MACRO_FILL_FCAT L_COLPOS 'ZAGE' '工号' '4' '' '' '' '' ''.
  MACRO_FILL_FCAT L_COLPOS 'BUTTON' '执行' '4' '' '' '' '' ''.

ENDFORM.



FORM FRM_INIT_LAYOUT .
  WA_LAYOUT-CWIDTH_OPT    = 'X'."优化列宽选项是否设置
  WA_LAYOUT-BOX_FNAME = 'SEL'. "显示选择栏
  WA_LAYOUT-INFO_FNAME = 'CLR'."行颜色字段
  WA_LAYOUT-CTAB_FNAME = 'COLLCOLOR'."单元格颜色制单
  WA_LAYOUT-STYLEFNAME   = 'CELLSTYLES'.
ENDFORM.


FORM FRM_ALV_OUTPUT .
  "alv 响应按键事件
  DATA:IT_EVENT TYPE SLIS_T_EVENT WITH HEADER LINE.
  IT_EVENT-NAME = 'CALLER_EXIT'.
  IT_EVENT-FORM = 'FRM_EVENT_BUTTON'.
  APPEND IT_EVENT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM      = SY-REPID
      I_CALLBACK_USER_COMMAND = 'FRM_USER_COMMAND'
*     I_CALLBACK_PF_STATUS_SET = 'FRM_SET_STATUS'
      IS_LAYOUT_LVC           = WA_LAYOUT
      IT_FIELDCAT_LVC         = IT_FIELDCAT
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
      IT_EVENTS               = IT_EVENT[]
    TABLES
      T_OUTTAB                = IT_ITEM
    EXCEPTIONS
      OTHERS                  = 2.
ENDFORM.

FORM  FRM_SET_STATUS USING PT_EXTAB TYPE SLIS_T_EXTAB  .
  DATA :WA_EXTAB LIKE LINE OF PT_EXTAB.
*  "SE90   PROGRAM NAME:SAPLKKBL  GUI STATUS:STANDARD_FULLSCREEN    COPY
*  "SE41  标准程序  SAPLKKBL  标准工具栏 STANDARD_FULLSCREEN
  WA_EXTAB-FCODE = '&RNT'.
  APPEND WA_EXTAB TO PT_EXTAB.
  WA_EXTAB-FCODE = '&ALL'.
  APPEND WA_EXTAB TO PT_EXTAB.
  WA_EXTAB-FCODE = '&SAL'.
  APPEND WA_EXTAB TO PT_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING PT_EXTAB.

  IF CL_GRID IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        E_GRID = CL_GRID.
  ENDIF.
*  CL_GRID->CHECK_CHANGED_DATA( ).
ENDFORM.

FORM FRM_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
  CASE R_UCOMM.
    WHEN 'ALL'.
      PERFORM FRM_EVENT_ALL.
    WHEN 'SAL'.
      PERFORM FRM_EVENT_SAL.
    WHEN '&IC1'.
      PERFORM FRM_EVENT_DBCLICK USING  RS_SELFIELD-TABINDEX RS_SELFIELD-FIELDNAME.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.


FORM FRM_EVENT_DBCLICK USING L_TABIX TYPE SY-TABIX L_FIELDNAME.

ENDFORM.

FORM FRM_ALV_REFRESH .
  DATA STBL TYPE LVC_S_STBL.
  STBL-ROW = 'X'." 基于行的稳定刷新
  STBL-COL = 'X'." 基于列稳定刷新
  CALL METHOD CL_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = STBL.
ENDFORM.

FORM FRM_EVENT_REFRESH_DATA .
  PERFORM FRM_PROCESS_DATA.
  PERFORM FRM_ALV_REFRESH.
ENDFORM.

FORM FRM_EVENT_ALL .
  WA_ITEM-XZ = 'X'.
  MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING XZ WHERE XZ = ''.
  PERFORM FRM_ALV_REFRESH.
ENDFORM.

FORM FRM_EVENT_SAL .
  WA_ITEM-XZ = ''.
  MODIFY IT_ITEM FROM WA_ITEM TRANSPORTING XZ WHERE XZ = 'X'.
  PERFORM FRM_ALV_REFRESH.
ENDFORM.


FORM FRM_EVENT_BUTTON USING E_GRID TYPE SLIS_DATA_CALLER_EXIT.
  IF CL_GRID IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        E_GRID = CL_GRID.
  ENDIF.

* 设置ENTER事件
  CALL METHOD CL_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER
    EXCEPTIONS
      ERROR      = 1
      OTHERS     = 2.

  "搜索帮助
  DATA: LT_F4 TYPE LVC_T_F4,
        LS_F4 TYPE LVC_S_F4.
  LS_F4-FIELDNAME  = 'ZNUM_PER'.   "窗口时间参数（需要定义F4帮助按钮的字段）
  LS_F4-REGISTER   = 'X'.
  LS_F4-GETBEFORE  = 'X'.
  LS_F4-CHNGEAFTER = 'X'.
  INSERT LS_F4 INTO TABLE LT_F4.

  DATA: ZCL_EVENT_RECEIVER TYPE REF TO CL_EVENT_RECEIVER.
  CREATE OBJECT ZCL_EVENT_RECEIVER.
  SET HANDLER ZCL_EVENT_RECEIVER->HANDLE_F4 FOR CL_GRID.
  SET HANDLER ZCL_EVENT_RECEIVER->HANDLE_MODIFY FOR CL_GRID.
  SET HANDLER ZCL_EVENT_RECEIVER->HANDLE_BUTTON_CLICK FOR CL_GRID.

  "注册F4事件
  CALL METHOD CL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].
ENDFORM.

FORM FRM_SEARCH_HELP  USING   P_FIELDNAME  TYPE LVC_FNAME
                              P_ROW_NO     TYPE LVC_S_ROID.
  DATA: LT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL,
        LS_RETURN TYPE DDSHRETVAL.
  DATA :LV_EQART TYPE EQART.

  DATA:IT_F4 TYPE STANDARD TABLE OF ZEMPLOYEE.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_F4 FROM ZEMPLOYEE.

  READ TABLE IT_ITEM INTO WA_ITEM INDEX P_ROW_NO-ROW_ID.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNUM_PER'            "筛选内表里面的字段
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZNUM_PER'            "ALV内表字段
      VALUE_ORG       = 'S'
"     CALLBACK_PROGRAM = SY-REPID
    TABLES
      VALUE_TAB       = IT_F4        "需要显示帮助的值内表
      RETURN_TAB      = LT_RETURN          "返回值
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC = 0.
    READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
    IF LS_RETURN-FIELDVAL IS NOT INITIAL.
      WA_ITEM-ZNUM_PER = LS_RETURN-FIELDVAL.
      MODIFY IT_ITEM FROM WA_ITEM INDEX  P_ROW_NO-ROW_ID.
    ENDIF.
  ENDIF.
ENDFORM.