*&---------------------------------------------------------------------*
*& Report ZGIT025A
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT025A.
TABLES: SSCRFIELDS.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001 .
PARAMETERS:P_FILE TYPE RLGRAP-FILENAME  MODIF ID GR1. "文件
SELECTION-SCREEN END OF BLOCK B1 .

SELECTION-SCREEN: FUNCTION KEY 1.       "工具栏上添加按键

DATA:BEGIN OF IT_DATA OCCURS 0,
       FD TYPE CHAR10,
     END OF IT_DATA.

TYPES:BEGIN OF TY_ITEM.
TYPES: XZ         TYPE C,
       SEL        TYPE C,
       ICON       TYPE ICON_D,
       CURRENCY   LIKE EKPO-NETPR,
       CLR        TYPE CHAR4, "行颜色设置
       COLLCOLOR  TYPE LVC_T_SCOL, "单元格颜色
       BUTTON     TYPE ICON_D,
       RZ         TYPE CHAR200.
       INCLUDE STRUCTURE IT_DATA.
       TYPES: CELLSTYLES TYPE  LVC_T_STYL. "单元格颜色(可编辑，按键等)
TYPES END OF TY_ITEM.

DATA: IT_FIELDCAT TYPE  LVC_T_FCAT,
      WA_FIELDCAT TYPE  LVC_S_FCAT,
      WA_LAYOUT   TYPE LVC_S_LAYO,
      GT_SORT     TYPE SLIS_T_SORTINFO_ALV.

DATA:IT_ITEM TYPE STANDARD TABLE OF TY_ITEM,
     WA_ITEM LIKE LINE OF IT_ITEM.

DATA:CL_GRID TYPE REF TO CL_GUI_ALV_GRID.
DATA: FUNCTXT     TYPE SMP_DYNTXT.


CONSTANTS: C_TEMPLATE  TYPE W3OBJID VALUE 'ZTEMPLATE',
           C_BEGIN_ROW TYPE I VALUE '2',
           C_BEGIN_COL TYPE I VALUE '1',
           C_END_ROW   TYPE I VALUE '9999',
           C_END_COL   TYPE I VALUE '2'.

DEFINE   MACRO_FILL_FCAT.
  CLEAR WA_FIELDCAT.
  &1 = &1 + 1.
  WA_FIELDCAT-COL_POS       = &1.
  WA_FIELDCAT-FIELDNAME     = &2.
  WA_FIELDCAT-SCRTEXT_L     = &3.
  WA_FIELDCAT-SCRTEXT_M     = &3.
  WA_FIELDCAT-SCRTEXT_S     = &3.
  WA_FIELDCAT-OUTPUTLEN     = &4.
  WA_FIELDCAT-EDIT          = &5. "
  WA_FIELDCAT-CHECKBOX      = &6.
  WA_FIELDCAT-EMPHASIZE     = &7. "列颜色设置
  WA_FIELDCAT-REF_TABLE     = &8.
  WA_FIELDCAT-REF_FIELD     = &9.
  WA_FIELDCAT-NO_ZERO       = 'X'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.
END-OF-DEFINITION.

INITIALIZATION.
  FUNCTXT-ICON_ID   = ICON_IMPORT.     "工具栏上添加按键
  IF SY-LANGU = 'E'.
    FUNCTXT-ICON_TEXT = 'Import Template Download'.
  ELSE.
    FUNCTXT-ICON_TEXT = '导入模板下载'.
  ENDIF.
  SSCRFIELDS-FUNCTXT_01 = FUNCTXT.      "工具栏上添加按键


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM FRM_FILE_OPEN USING P_FILE. "获取导入数据文件

AT SELECTION-SCREEN.
  CASE SSCRFIELDS-UCOMM.
    WHEN  'FC01'.
      DATA:L_PATH          TYPE STRING, L_PATH_FULL TYPE STRING, L_FILENAME TYPE STRING,L_TEMPLATE_NAME TYPE STRING.
      PERFORM FRM_FILE_SAVE USING L_PATH L_PATH_FULL L_FILENAME.
      PERFORM FRM_FILE_TEMPLATE_DOWNLOAD USING C_TEMPLATE L_PATH_FULL.
    WHEN 'ONLI'.
      IF P_FILE IS INITIAL.
        IF SY-LANGU = 'E'.
          MESSAGE 'Please select the file to import！' TYPE 'E'.
        ELSE.
          MESSAGE '请选择要导入的文件！' TYPE 'E'.
        ENDIF.
      ENDIF.
  ENDCASE.

START-OF-SELECTION.
  PERFORM FRM_READ_DATA.
  PERFORM FRM_PROCESS_DATA.

END-OF-SELECTION.
  PERFORM FRM_INIT_FIELDCAT.
  PERFORM FRM_INIT_LAYOUT.
  PERFORM FRM_ALV_OUTPUT.

FORM FRM_READ_DATA.
  DATA:IT_TAB LIKE ALSMEX_TABLINE OCCURS 0 WITH HEADER LINE.
  FIELD-SYMBOLS: <FS>.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = C_BEGIN_COL
      I_BEGIN_ROW             = C_BEGIN_ROW
      I_END_COL               = C_END_COL
      I_END_ROW               = C_END_ROW
    TABLES
      INTERN                  = IT_TAB
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  DATA:CL_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
       STR      TYPE STRING.
  RANGES:S_INDEX FOR SY-INDEX.
  CL_STRUC ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( IT_DATA ).
  LOOP AT CL_STRUC->COMPONENTS  ASSIGNING FIELD-SYMBOL(<WA_COMP>).
    IF <WA_COMP>-TYPE_KIND = 'N' OR <WA_COMP>-TYPE_KIND = 'I' OR <WA_COMP>-TYPE_KIND = 'P' .
      S_INDEX-SIGN = 'I'.
      S_INDEX-OPTION = 'EQ'.
      S_INDEX-LOW = SY-TABIX.
      APPEND S_INDEX.
      CLEAR:S_INDEX.
    ENDIF.
  ENDLOOP.

  LOOP AT IT_TAB.
    ASSIGN COMPONENT IT_TAB-COL OF STRUCTURE IT_DATA TO <FS>.
    IF IT_TAB-COL IN S_INDEX.
      STR = IT_TAB-VALUE.
      CONDENSE STR NO-GAPS.
      IF NOT STR CO '0123456789.'.
        READ TABLE CL_STRUC->COMPONENTS ASSIGNING FIELD-SYMBOL(<WA_COMPONENT>) INDEX IT_TAB-COL.
        IF SY-SUBRC = 0.
          WA_ITEM-RZ = STR && '不能赋值给字段'&& <WA_COMPONENT>-NAME.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
    MOVE IT_TAB-VALUE TO <FS>.
    AT END OF ROW.
      MOVE-CORRESPONDING IT_DATA TO WA_ITEM.
      APPEND WA_ITEM TO IT_ITEM.
      CLEAR:WA_ITEM,IT_DATA.
    ENDAT.
  ENDLOOP.
ENDFORM.

FORM FRM_PROCESS_DATA.
ENDFORM.

FORM FRM_INIT_FIELDCAT .
  DATA: L_COLPOS TYPE LVC_S_FCAT-COL_POS.
ENDFORM.

FORM FRM_INIT_LAYOUT .
  WA_LAYOUT-BOX_FNAME  = 'SEL'.
  WA_LAYOUT-CWIDTH_OPT = 'X'."优化列宽选项是否设置
  WA_LAYOUT-INFO_FNAME = 'CLR'."行颜色字段
  WA_LAYOUT-CTAB_FNAME = 'COLLCOLOR'."单元格颜色制单
  WA_LAYOUT-STYLEFNAME = 'CELLSTYLES'.
  WA_LAYOUT-ZEBRA      = 'X'."斑马线显示
ENDFORM.

FORM FRM_ALV_OUTPUT .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM      = SY-REPID
      I_CALLBACK_USER_COMMAND = 'FRM_USER_COMMAND'
*     I_CALLBACK_PF_STATUS_SET = 'FRM_SET_STATUS'
*     I_CALLBACK_TOP_OF_PAGE  = 'PRM_TOP_PAGE'
*     I_CALLBACK_HTML_END_OF_LIST = 'FRM_END_PAGE'
      IS_LAYOUT_LVC           = WA_LAYOUT
      IT_FIELDCAT_LVC         = IT_FIELDCAT[]
*     I_GRID_TITLE            = 'Test Report Title'
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
    TABLES
      T_OUTTAB                = IT_ITEM
    EXCEPTIONS
      OTHERS                  = 2.
ENDFORM.

FORM  FRM_SET_STATUS USING PT_EXTAB TYPE SLIS_T_EXTAB  .
  DATA:WA_EXTAB LIKE LINE OF PT_EXTAB.
  "SE41  标准程序  SAPLKKBL  标准工具栏 STANDARD_FULLSCREEN
  WA_EXTAB-FCODE = '%SC+'.
  APPEND WA_EXTAB TO PT_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING PT_EXTAB.
ENDFORM.

FORM FRM_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM RS_SELFIELD TYPE SLIS_SELFIELD.
  IF CL_GRID IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        E_GRID = CL_GRID.
  ENDIF.
  CASE  R_UCOMM.
    WHEN '&IC1'.
      PERFORM FRM_EVENT_DBCLICK USING RS_SELFIELD-TABINDEX RS_SELFIELD-FIELDNAME.
    WHEN 'ALL'.
      PERFORM FRM_EVENT_ALL.
    WHEN 'SAL'.
      PERFORM FRM_EVENT_SAL.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.

FORM FRM_ALV_REFRESH .
  CL_GRID->CHECK_CHANGED_DATA( ).
  DATA: STBL TYPE LVC_S_STBL.
  STBL-ROW = 'X'.
  STBL-COL = 'X'.
  CALL METHOD CL_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = STBL.
ENDFORM.

"------------------------------------------------------------------------------file 操作。
FORM FRM_FILE_OPEN USING L_PATH_FULL.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = '*.XLSX' "限定上传文件类型为Excel文件(.xls)
      MASK             = '.EXCEL 文件 (*.XLS;*.XLSX)|*.XLS;*.XLSX.'
      MODE             = 'O'
      TITLE            = 'Title'
    IMPORTING
      FILENAME         = L_PATH_FULL
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.
ENDFORM.

FORM FRM_FILE_SAVE USING L_PATH L_PATH_FULL L_FILENAME.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE      = 'Title'
      FILE_FILTER       = '*.xls,*xlsx|*.xls;*.xlsx'
      DEFAULT_FILE_NAME = 'Template.xlsx'
      DEFAULT_EXTENSION = '.xls'
    CHANGING
      PATH              = L_PATH
      FULLPATH          = L_PATH_FULL
      FILENAME          = L_FILENAME.
ENDFORM.

FORM FRM_FILE_TEMPLATE_DOWNLOAD USING L_TEMPLATE_NAME L_PATH_FULL.
  DATA: LO_OBJDATA     LIKE WWWDATATAB,
        LS_DESTINATION TYPE RLGRAP-FILENAME,
        LI_RC          TYPE I.
  SELECT SINGLE RELID OBJID FROM WWWDATA INTO CORRESPONDING FIELDS OF LO_OBJDATA
  WHERE SRTF2 = 0 AND RELID = 'MI' AND OBJID = L_TEMPLATE_NAME.
  LS_DESTINATION = L_PATH_FULL.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LO_OBJDATA
      DESTINATION = LS_DESTINATION
    IMPORTING
      RC          = LI_RC.
ENDFORM.
"------------------------------------------------------------------------------file 操作。

"------------------------------------------------------------------------------event 操作。
FORM FRM_EVENT_DBCLICK  USING  L_TABINDEX L_FIELDNAME.
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
"------------------------------------------------------------------------------event 操作。
