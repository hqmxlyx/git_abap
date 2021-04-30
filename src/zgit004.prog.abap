*&---------------------------------------------------------------------*
*& Report ZGIT003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT004.

DATA:BEGIN OF IT_ITEM OCCURS 0.
DATA:SEL       TYPE C,
     CELLTAB   TYPE  LVC_T_STYL,
     DD_HANDLE TYPE INT4. "下拉框索引值
     INCLUDE STRUCTURE ZEMPLOYEE.
     DATA END OF IT_ITEM.

CONSTANTS: G_CONTAINER TYPE SCRFNAME VALUE 'CONTAINER'.
CONSTANTS: GC_X          VALUE 'X'.
DATA: GT_FIELDCAT TYPE LVC_T_FCAT,
      GW_FIELDCAT TYPE LVC_S_FCAT,
      GW_LAYOUT   TYPE LVC_S_LAYO,
      GS_TOOLBAR  TYPE UI_FUNCTIONS.

DATA:CL_GRID             TYPE REF TO CL_GUI_ALV_GRID,
     CL_CONTAINER        TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
     CL_CONTAINER_DIALOG TYPE REF TO CL_GUI_DIALOGBOX_CONTAINER,
     CL_GRID_DIALOG      TYPE REF TO CL_GUI_ALV_GRID.

"存储下拉列表的数据
DATA: I_DDVAL  TYPE LVC_T_DROP,
      WA_DDVAL TYPE LVC_S_DROP.

CLASS: CL_EVENT_RECEIVER DEFINITION DEFERRED,
        CL_EVENT_RECEIVER_DIALOG DEFINITION DEFERRED.
DATA:EVENT_RECEIVER        TYPE REF TO CL_EVENT_RECEIVER,
     EVENT_RECEIVER_DIALOG TYPE REF TO CL_EVENT_RECEIVER_DIALOG.


CLASS CL_EVENT_RECEIVER_DIALOG DEFINITION.
  PUBLIC SECTION.
    METHODS CLICK_CLOSE FOR EVENT CLOSE OF CL_GUI_DIALOGBOX_CONTAINER  IMPORTING SENDER.

    METHODS HANDLE_TOOLBAR
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.
    METHODS HANDLE_COMMAND
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.
ENDCLASS.


CLASS CL_EVENT_RECEIVER_DIALOG IMPLEMENTATION.
  METHOD CLICK_CLOSE.
    SENDER->SET_VISIBLE( VISIBLE = SPACE ).
  ENDMETHOD.

  METHOD HANDLE_TOOLBAR.
    DATA: LS_TOOLBAR TYPE STB_BUTTON.
    CLEAR: LS_TOOLBAR.
    LS_TOOLBAR-BUTN_TYPE = 3. " 分隔符
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    CLEAR: LS_TOOLBAR.
    LS_TOOLBAR-FUNCTION = 'DISP'.    " 功能码
    LS_TOOLBAR-ICON = ICON_DISPLAY.  " 图标名称
    LS_TOOLBAR-QUICKINFO = '显示'.   " 图标的提示信息
    LS_TOOLBAR-BUTN_TYPE = 0.        " 0表示正常按钮
    LS_TOOLBAR-DISABLED = ''.        " X表示灰色，不可用
    LS_TOOLBAR-TEXT = '按钮1'.       " 按钮上显示的文本
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    CLEAR: LS_TOOLBAR.

    LS_TOOLBAR-FUNCTION = 'REFRESH'.    " 功能码
    LS_TOOLBAR-ICON = ICON_DISPLAY.  " 图标名称
    LS_TOOLBAR-QUICKINFO = '刷新数据'.   " 图标的提示信息
    LS_TOOLBAR-BUTN_TYPE = 0.        " 0表示正常按钮
    LS_TOOLBAR-DISABLED = ''.        " X表示灰色，不可用
    LS_TOOLBAR-TEXT = '刷新数据'.       " 按钮上显示的文本
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    CLEAR: LS_TOOLBAR.
  ENDMETHOD.                    "handle_toolbar
  " 实现USER-COMMAND 事件方法
  METHOD HANDLE_COMMAND.
    CASE E_UCOMM.
      WHEN 'DISP'.
        READ TABLE IT_ITEM TRANSPORTING NO FIELDS WITH  KEY SEL ='X'.
        IF SY-SUBRC = 0.
          MESSAGE '有数据了' TYPE 'I'.
        ENDIF.
        MESSAGE I001(00) WITH 'Toolbar事件 + USER-COMMAND事件 '.
      WHEN 'REFRESH'.
        CALL METHOD CL_GRID->CHECK_CHANGED_DATA.
        DATA LS_STABLE TYPE LVC_S_STBL.
        LS_STABLE-ROW = 'X'.
        LS_STABLE-COL = 'X'.
        CL_GRID->REFRESH_TABLE_DISPLAY( IS_STABLE = LS_STABLE ) .
    ENDCASE.
  ENDMETHOD.                    "HANDLE_COMMAND
ENDCLASS.



CLASS CL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS CLICK_BUTTON FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID IMPORTING E_ROW_ID E_COLUMN_ID.

    METHODS RIGHT_BUTTON FOR EVENT MOVE_CONTROL OF CL_GUI_ALV_GRID .

    METHODS DBCLICK_BUTTON FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID IMPORTING E_ROW E_COLUMN.

    " 声明单击事件的方法
    METHODS HANDLE_HOTSPOT_CLICK
                FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.
    " 声明双击事件方法
    METHODS HANDLE_DOUBLE_CLICK
                FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW E_COLUMN.
    " 声明Toolbar事件方法
    METHODS HANDLE_TOOLBAR
                FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.
    " 声明USER-COMMAND 事件方法
    METHODS HANDLE_COMMAND
                FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    "文本编辑改变事件
    METHODS HANDLE_MODIFY
                FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED ET_GOOD_CELLS.

    METHODS: ON_F4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING E_FIELDNAME
*                  E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                "E_DISPLAY
      .
    METHODS: DATA_CHANGE FOR EVENT DATA_CHANGED
                OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED
                E_ONF4.

    METHODS: HANDLE_MENU_BUTTON    FOR EVENT MENU_BUTTON        "用于在下拉菜单中增加选项
                OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_UCOMM.
ENDCLASS.

CLASS CL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD CLICK_BUTTON.
    CONDENSE E_ROW_ID     NO-GAPS .
    SHIFT E_ROW_ID LEFT DELETING LEADING '0'.

    CONDENSE E_COLUMN_ID  NO-GAPS.
    MESSAGE I001(00) WITH '单击事件->行号:' E_ROW_ID  '、列名：' E_COLUMN_ID.
  ENDMETHOD.

  METHOD RIGHT_BUTTON.
    MESSAGE 'RIGHT_BUTTON' TYPE 'I'.
  ENDMETHOD.

  " 单击事件方法的实现
  METHOD HANDLE_HOTSPOT_CLICK.
    CONDENSE E_ROW_ID     NO-GAPS.
    CONDENSE E_COLUMN_ID  NO-GAPS.
    MESSAGE I001(00) WITH '单击事件->行号:' E_ROW_ID  '、列名：' E_COLUMN_ID.
  ENDMETHOD.                    "handle_HOTSPOT_CLICK
  " 双击事件方法的实现
  METHOD HANDLE_DOUBLE_CLICK.
    CONDENSE E_ROW     NO-GAPS.
    CONDENSE E_COLUMN  NO-GAPS.
    MESSAGE I001(00) WITH '双击事件->行号:' E_ROW  '、列名：' E_COLUMN.
  ENDMETHOD.                    "handle_double_click
  " 实现Toolbar事件方法
  METHOD HANDLE_TOOLBAR.
    DATA: LS_TOOLBAR TYPE STB_BUTTON.
    CLEAR: LS_TOOLBAR.
    LS_TOOLBAR-BUTN_TYPE = 3. " 分隔符
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    CLEAR: LS_TOOLBAR.
    LS_TOOLBAR-FUNCTION = 'DISP'.    " 功能码
    LS_TOOLBAR-ICON = ICON_DISPLAY.  " 图标名称
    LS_TOOLBAR-QUICKINFO = '显示'.   " 图标的提示信息
    LS_TOOLBAR-BUTN_TYPE = 0.        " 0表示正常按钮
    LS_TOOLBAR-DISABLED = ''.        " X表示灰色，不可用
    LS_TOOLBAR-TEXT = '按钮1'.       " 按钮上显示的文本
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    LS_TOOLBAR-FUNCTION = 'REFRESH'.    " 功能码
    LS_TOOLBAR-ICON = ICON_DISPLAY.  " 图标名称
    LS_TOOLBAR-QUICKINFO = '刷新数据'.   " 图标的提示信息
    LS_TOOLBAR-BUTN_TYPE = 0.        " 0表示正常按钮
    LS_TOOLBAR-DISABLED = ''.        " X表示灰色，不可用
    LS_TOOLBAR-TEXT = '刷新数据'.       " 按钮上显示的文本
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


    LS_TOOLBAR-FUNCTION = 'DROP'.    " 功能码
    LS_TOOLBAR-ICON = ICON_DISPLAY.  " 图标名称
    LS_TOOLBAR-QUICKINFO = '下拉框按键'.   " 图标的提示信息
    LS_TOOLBAR-BUTN_TYPE = 1.        " 0表示正常按钮
    LS_TOOLBAR-DISABLED = ''.        " X表示灰色，不可用
    LS_TOOLBAR-TEXT = '下拉框按键'.       " 按钮上显示的文本
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    CLEAR: LS_TOOLBAR.


    LS_TOOLBAR-FUNCTION = 'REFRESH_DATA'.    " 功能码
    LS_TOOLBAR-ICON = ICON_DISPLAY.  " 图标名称
    LS_TOOLBAR-QUICKINFO = '刷新数据'.   " 图标的提示信息
    LS_TOOLBAR-BUTN_TYPE = 0.        " 0表示正常按钮
    LS_TOOLBAR-DISABLED = ''.        " X表示灰色，不可用
    LS_TOOLBAR-TEXT = '刷新数据'.       " 按钮上显示的文本
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    CLEAR: LS_TOOLBAR.

  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_MENU_BUTTON.
    IF E_UCOMM = 'DROP'.
      CALL METHOD E_OBJECT->ADD_FUNCTION
        EXPORTING
          ICON  = ICON_DISPLAY
          FCODE = 'DROP1'
          TEXT  = '下拉框按键1'.
      CALL METHOD E_OBJECT->ADD_FUNCTION
        EXPORTING
          ICON  = ICON_DISPLAY
          FCODE = 'DROP2'
          TEXT  = '下拉框按键2'.

    ENDIF.
  ENDMETHOD.

  " 实现USER-COMMAND 事件方法
  METHOD HANDLE_COMMAND.
    CASE E_UCOMM.
      WHEN 'DISP'.
        READ TABLE IT_ITEM TRANSPORTING NO FIELDS WITH  KEY SEL ='X'.
        IF SY-SUBRC = 0.
          MESSAGE '有数据了' TYPE 'I'.
        ENDIF.
        MESSAGE I001(00) WITH 'Toolbar事件 + USER-COMMAND事件 '.
      WHEN 'REFRESH'.
        CALL METHOD CL_GRID->CHECK_CHANGED_DATA.
        DATA LS_STABLE TYPE LVC_S_STBL.
        LS_STABLE-ROW = 'X'.
        LS_STABLE-COL = 'X'.
        CL_GRID->REFRESH_TABLE_DISPLAY( IS_STABLE = LS_STABLE ) .
      WHEN 'REFRESH_DATA'.
        DATA:ZCL_CHANGE_PROTOCOL TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
        CREATE OBJECT ZCL_CHANGE_PROTOCOL
          EXPORTING
            I_CONTAINER   = CL_CONTAINER
            I_CALLING_ALV = CL_GRID.

        DATA: LFLG_ORDER_CHANGED TYPE I,
              M_FULL             TYPE CHAR01.
        DATA: LT_CONVERSION TYPE LVC_T_ROID.
        DATA: LT_DELETED_ROWS TYPE LVC_T_MOCE,
              LS_DELETED_ROWS TYPE LVC_S_MOCE.

    ENDCASE.
  ENDMETHOD.
  METHOD DBCLICK_BUTTON.
    MESSAGE '触发双击事件' TYPE 'I'.
    PERFORM SHOW_DIALOG_DATA.
  ENDMETHOD.

  METHOD HANDLE_MODIFY.
    DATA STBL TYPE LVC_S_STBL.

    MESSAGE '文本发生变化触发，回车可以触发。传入的参数是' && E_MODIFIED  TYPE 'I'.
*    MESSAGE ET_GOOD_CELLS TYPE 'I'.
    DATA:L_TEXT TYPE C.
*    CALL METHOD CL_GUI_ALV_GRID=>GET_CURRENT_CELL_TEXT( IMPORTING TEXT = L_TEXT ).
    MESSAGE '当前框的文本是' && L_TEXT TYPE 'I'.
    STBL-ROW = 'X'." 基于行的稳定刷新
    STBL-COL = 'X'." 基于列稳定刷新
    CALL METHOD CL_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = STBL.
  ENDMETHOD.


  METHOD ON_F4.
    DATA:IT_RETURN TYPE TABLE OF DDSHRETVAL,
         WA_RETURN LIKE LINE OF IT_RETURN.
    DATA:IT_HELP TYPE STANDARD TABLE OF ZEMPLOYEE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_HELP FROM ZEMPLOYEE.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD        = 'ZNUM_PER'
        WINDOW_TITLE    = 'List of State entries'(002)
        DYNPPROG        = SY-REPID
        DYNPNR          = SY-DYNNR
        DYNPROFIELD     = 'ZNUM_PER'
        VALUE_ORG       = 'S'
      TABLES
        VALUE_TAB       = IT_HELP
        RETURN_TAB      = IT_RETURN[]
      EXCEPTIONS
        PARAMETER_ERROR = 1
        NO_VALUES_FOUND = 2
        OTHERS          = 3.
    IF SY-SUBRC = 0.
      READ TABLE IT_RETURN INTO WA_RETURN INDEX 1.
      READ TABLE IT_ITEM ASSIGNING FIELD-SYMBOL(<WA_ITEM>) INDEX  ES_ROW_NO-ROW_ID.
      IF SY-SUBRC = 0.
        <WA_ITEM>-ZNUM_PER =  WA_RETURN-FIELDVAL.
        <WA_ITEM>-ZNAME = 'aaaaa'.
      ENDIF.
    ENDIF.

    DATA STBL TYPE LVC_S_STBL.
    STBL-ROW = 'X'." 基于行的稳定刷新
    STBL-COL = 'X'." 基于列稳定刷新
    CALL METHOD CL_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = STBL.
  ENDMETHOD.

  METHOD DATA_CHANGE.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  PERFORM FRM_GET_DATE.
  PERFORM FRM_SET_FIELDCAT.
  PERFORM FRM_SET_LAYOUT.
  PERFORM FRM_DISPLAY_DATA.

  CALL SCREEN 1000.

FORM FRM_GET_DATE.
  SELECT * UP TO 10 ROWS INTO CORRESPONDING FIELDS OF TABLE IT_ITEM FROM ZEMPLOYEE.

  DO 10 TIMES.
    APPEND  LINES OF  IT_ITEM[]  TO IT_ITEM[].
  ENDDO.


  DATA: LT_CELLTAB TYPE LVC_T_STYL,
        LS_CELLTAB TYPE LVC_S_STYL.

  "给下拉框赋值
  WA_DDVAL-HANDLE = 2.
  WA_DDVAL-VALUE  = '1'.
  APPEND WA_DDVAL TO I_DDVAL.
  WA_DDVAL-HANDLE = 2.
  WA_DDVAL-VALUE  = '2'.
  APPEND WA_DDVAL TO I_DDVAL.
  WA_DDVAL-HANDLE = 2.
  WA_DDVAL-VALUE  = '3'.
  APPEND WA_DDVAL TO I_DDVAL.

  LOOP AT IT_ITEM ASSIGNING FIELD-SYMBOL(<WA_ITEM>).
    IF SY-TABIX = 1.
      LS_CELLTAB-FIELDNAME = 'ZNUM_PER'.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.  "可编辑
      APPEND LS_CELLTAB TO LT_CELLTAB.
      IT_ITEM-CELLTAB = LT_CELLTAB.
      MODIFY  IT_ITEM .
      CLEAR:IT_ITEM, LT_CELLTAB,LS_CELLTAB.
      REFRESH: LT_CELLTAB.
    ENDIF.

    IF SY-TABIX = 2.
      LS_CELLTAB-FIELDNAME = 'ZSEX'.
      LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.  "显示
      APPEND LS_CELLTAB TO LT_CELLTAB.
      IT_ITEM-CELLTAB = LT_CELLTAB.
      MODIFY  IT_ITEM .
      CLEAR:IT_ITEM, LT_CELLTAB,LS_CELLTAB.
      REFRESH: LT_CELLTAB.
    ENDIF.
    "设置下拉选项的索引值
    <WA_ITEM>-DD_HANDLE = 2.
  ENDLOOP.

ENDFORM.


FORM FRM_SET_FIELDCAT.
  DATA:L_COLUME    TYPE LVC_S_FCAT-COL_POS.
  DEFINE MACRO_FIELDCAT.
    CLEAR GW_FIELDCAT.
        &1 = &1 + 1.
        GW_FIELDCAT-COL_POS = &1.
        GW_FIELDCAT-FIELDNAME = &2.
        GW_FIELDCAT-COLTEXT = &3.
        GW_FIELDCAT-OUTPUTLEN = &4. "输入出长度
        GW_FIELDCAT-FIX_COLUMN =  &5.
        GW_FIELDCAT-KEY = &6.
        GW_FIELDCAT-EDIT = &7.
      "  GW_FIELDCAT-HOTSPOT = 'X'.
        GW_FIELDCAT-NO_ZERO = 'X'.
        GW_FIELDCAT-JUST = 'C'.
        IF  GW_FIELDCAT-FIELDNAME = 'ZNUM_PER'.
          GW_FIELDCAT-F4AVAILABL = 'X'.
        ENDIF.
        "设置下拉抗
        IF  GW_FIELDCAT-FIELDNAME = 'ZSEX'.
           GW_FIELDCAT-INTTYPE   = 'C'.
           GW_FIELDCAT-INTLEN    = '9'.
           GW_FIELDCAT-EDIT       = 'X'.
           GW_FIELDCAT-OUTPUTLEN = '12'.
           GW_FIELDCAT-DD_OUTLEN = '12'.
           GW_FIELDCAT-DRDN_FIELD = 'DD_HANDLE'.   "设置下拉菜单
        ENDIF.
      APPEND GW_FIELDCAT TO GT_FIELDCAT.
  END-OF-DEFINITION.

  MACRO_FIELDCAT  L_COLUME 'ZNUM_PER' '工号' '30' 'X' 'X' 'X'.
  MACRO_FIELDCAT  L_COLUME 'ZNAME' '姓名' '' '' ''  ''.
  MACRO_FIELDCAT  L_COLUME 'ZAGE' '年龄' '' '' '' ''.
  MACRO_FIELDCAT  L_COLUME 'ZSEX' '性别' '' '' '' 'X'.
ENDFORM.


FORM FRM_SET_LAYOUT.
  GW_LAYOUT-ZEBRA = 'X'.
  GW_LAYOUT-BOX_FNAME = 'SEL'.
  GW_LAYOUT-INFO_FNAME = 'COLOR'.
  GW_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GW_LAYOUT-CWIDTH_OPT = 'X'.  "自动调整列宽
  "GW_LAYOUT-SEL_MODE = 'A'. "显示全选按键
ENDFORM.


FORM FRM_DISPLAY_DATA.

  IF CL_CONTAINER IS INITIAL.
    CREATE OBJECT CL_CONTAINER
      EXPORTING
        CONTAINER_NAME = G_CONTAINER.
  ENDIF.


  IF CL_GRID IS INITIAL.
    CREATE OBJECT CL_GRID
      EXPORTING
        I_PARENT = CL_CONTAINER.
  ENDIF.

  "设置下拦选项的内表
  CALL METHOD CL_GRID->SET_DROP_DOWN_TABLE
    EXPORTING
      IT_DROP_DOWN = I_DDVAL.


  IF  EVENT_RECEIVER IS INITIAL.
    CREATE OBJECT EVENT_RECEIVER.
  ENDIF.

  " 设置enter事件
  CALL METHOD CL_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER
    EXCEPTIONS
      ERROR      = 1
      OTHERS     = 2.

  "注册文本变化和回车事件
  CALL METHOD CL_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  SET HANDLER EVENT_RECEIVER->CLICK_BUTTON FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->DBCLICK_BUTTON FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK  FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK   FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_COMMAND FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_MODIFY FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->ON_F4 FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->DATA_CHANGE FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->RIGHT_BUTTON FOR CL_GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_MENU_BUTTON FOR CL_GRID.

  "注册F4事件
  DATA:IT_F4 TYPE LVC_T_F4,
       WA_F4 LIKE LINE OF IT_F4.
  WA_F4-FIELDNAME  = 'ZNUM_PER'.
  WA_F4-REGISTER   = 'X'.
  WA_F4-GETBEFORE  = 'X'.
  WA_F4-CHNGEAFTER = 'X'.
  WA_F4-INTERNAL = 'X'.
  APPEND WA_F4 TO IT_F4 .

  CALL METHOD CL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = IT_F4.

  "隐藏按键
  DATA: PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA: LS_EXCLUDE TYPE LINE OF UI_FUNCTIONS.
  LS_EXCLUDE = '&LOCAL&CUT'.    "剪切
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = '&LOCAL&COPY'.   "复制文本
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = '&MB_PASTE'.     "插入总览
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = '&LOCAL&UNDO'.   "撤销
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = '&LOCAL&APPEND'.     "附加行
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE ='&LOCAL&INSERT_ROW'.  "插入行
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
*  LS_EXCLUDE ='&LOCAL&DELETE_ROW'.  "删除行
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE ='&LOCAL&COPY_ROW'.    "复制行
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE ='&INFO'.    "复制行
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  DATA :LS_VARIANT TYPE DISVARIANT.
  LS_VARIANT-REPORT = SY-REPID.
  CALL METHOD CL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GW_LAYOUT
      IS_VARIANT           = LS_VARIANT
      I_SAVE               = 'A'
      IT_TOOLBAR_EXCLUDING = PT_EXCLUDE
      I_BYPASSING_BUFFER   = 'X'
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT
      IT_OUTTAB            = IT_ITEM[].
ENDFORM.

MODULE STATUS_1000 OUTPUT.
  SET PF-STATUS 'PF_STATUS'.
  SET TITLEBAR 'TITLEBAR'.
ENDMODULE.

MODULE USER_EXIT INPUT.
  LEAVE PROGRAM.
ENDMODULE.

MODULE INIT_DATE OUTPUT.
  PERFORM FRM_SET_FIELDCAT.
  PERFORM FRM_SET_LAYOUT.
  PERFORM FRM_DISPLAY_DATA.
ENDMODULE.



FORM SHOW_DIALOG_DATA.
  IF CL_CONTAINER_DIALOG IS INITIAL.
    CREATE OBJECT CL_CONTAINER_DIALOG
      EXPORTING
        TOP      = 50
        LEFT     = 100
        LIFETIME = CNTL_LIFETIME_DYNPRO
        CAPTION  = 'dialog title'  "dialog title
        WIDTH    = 500
        HEIGHT   = 200.

    IF CL_GRID_DIALOG IS INITIAL.
      CREATE OBJECT CL_GRID_DIALOG
        EXPORTING
          I_PARENT = CL_CONTAINER_DIALOG.
    ENDIF.

    IF EVENT_RECEIVER_DIALOG IS INITIAL.
      CREATE OBJECT EVENT_RECEIVER_DIALOG.
    ENDIF.

    SET HANDLER EVENT_RECEIVER_DIALOG->CLICK_CLOSE FOR CL_CONTAINER_DIALOG.
    SET HANDLER EVENT_RECEIVER_DIALOG->HANDLE_TOOLBAR FOR CL_GRID_DIALOG.
    SET HANDLER EVENT_RECEIVER_DIALOG->HANDLE_COMMAND FOR CL_GRID_DIALOG.

    CALL METHOD CL_GRID_DIALOG->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = GW_LAYOUT
        IT_TOOLBAR_EXCLUDING = GS_TOOLBAR
      CHANGING
        IT_FIELDCATALOG      = GT_FIELDCAT
        IT_OUTTAB            = IT_ITEM[].
  ELSE.
    CL_CONTAINER_DIALOG->SET_VISIBLE( VISIBLE = 'X' ).
    CL_GRID_DIALOG->REFRESH_TABLE_DISPLAY( ).
  ENDIF.

ENDFORM.

MODULE USER_COMMAND_1000 INPUT.

ENDMODULE.

MODULE USER_EXIT_1000 INPUT.
*MODULE USER_EXIT_1000 AT EXIT-COMMAND
  LEAVE PROGRAM.
ENDMODULE.
