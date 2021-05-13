*&---------------------------------------------------------------------*
*& Report ZGIT016
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT016.
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_FILE TYPE RLGRAP-FILENAME.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-001.
PARAMETERS: R1 RADIOBUTTON GROUP RB,  "文件上传
            R2 RADIOBUTTON GROUP RB,  "文件下载
            R3 RADIOBUTTON GROUP RB,   "execl 到内表
            R4 RADIOBUTTON GROUP RB,   "内表到 execl
            R5 RADIOBUTTON GROUP RB,   "FTP 文件上传
            R6 RADIOBUTTON GROUP RB,   "FTP 文件上传
            R7 RADIOBUTTON GROUP RB.   "FTP 文件上传
SELECTION-SCREEN END OF BLOCK B2.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME = '*.txt;*.xlsx'
      MASK         = '*.txt;*.xlsx'
*     MASK         = ',Excel file,*.xls;*.xlsx;'
    IMPORTING
      FILENAME     = P_FILE.

START-OF-SELECTION.
  "------------------------------------------------------------------文件上传
  IF R1 = 'X'.
    IF  P_FILE IS INITIAL.
      MESSAGE '请选择要上传的文本文件' TYPE 'E'.
    ENDIF.

    DATA:STR1(128)        TYPE C,
         STR2(128)        TYPE C,
         STR3(128)        TYPE C,
         UPLOAD_PATH(200) TYPE C,
         EXECPTION        TYPE REF TO CX_SY_FILE_OPEN_MODE,
         EXEC_STR         TYPE STRING.

    TYPES:BEGIN OF TY_INPUT,
            CONTENT(8000) TYPE C,
          END OF TY_INPUT.

    DATA:IT_INPUT TYPE STANDARD TABLE OF TY_INPUT,
         WA_INPUT LIKE LINE OF IT_INPUT.

    SPLIT P_FILE AT '.' INTO STR1 STR2 STR3.
    IF  STR3 <> 'txt'.
      MESSAGE '只能上传txt文件' TYPE 'E'.
    ENDIF.

    "文件上传到内表
    CALL FUNCTION 'WS_UPLOAD'
      EXPORTING
        FILENAME = P_FILE
      TABLES
        DATA_TAB = IT_INPUT.

    IF SY-SUBRC <> 0.
      MESSAGE '上传文件失败' TYPE 'E'.
    ENDIF.

    TRY .
        UPLOAD_PATH = '/usr/sap/tmp/upload_text'.
        OPEN DATASET UPLOAD_PATH FOR OUTPUT IN TEXT MODE ENCODING UTF-8.

        LOOP  AT IT_INPUT INTO WA_INPUT.
          TRANSFER WA_INPUT TO UPLOAD_PATH.
        ENDLOOP.
        CLOSE DATASET UPLOAD_PATH.

        IF SY-SUBRC = 0.
          MESSAGE '文件上传成功' TYPE 'S'.
        ENDIF.

      CATCH CX_SY_FILE_OPEN_MODE INTO EXECPTION.
        EXEC_STR = EXECPTION->GET_TEXT( ).
        MESSAGE EXEC_STR TYPE 'E'.
    ENDTRY.

  ENDIF.

ENHANCEMENT-POINT Z_TEST_ZQ SPOTS Z_TEST_ZQ .

  "------------------------------------------------------------------文件下载
  IF R2 = 'X'.

    UPLOAD_PATH = '/usr/sap/tmp/upload_text'.
    OPEN DATASET UPLOAD_PATH FOR INPUT IN TEXT MODE ENCODING UTF-8.

    DO .
      READ DATASET UPLOAD_PATH INTO WA_INPUT.
      IF SY-SUBRC <> 0.
        EXIT.
      ENDIF.
      APPEND WA_INPUT TO IT_INPUT.
    ENDDO.

    CLOSE DATASET UPLOAD_PATH.

    CALL FUNCTION 'WS_FILENAME_GET'
      EXPORTING
        DEF_FILENAME = '*.txt;*.xlsx'
        MASK         = '*.txt;*.xlsx'
      IMPORTING
        FILENAME     = P_FILE.


    CALL FUNCTION 'WS_DOWNLOAD'
      EXPORTING
        FILENAME = P_FILE
      TABLES
        DATA_TAB = IT_INPUT.

    IF SY-SUBRC = 0 .
      MESSAGE '文件下载完成' TYPE 'S'.
    ENDIF.

  ENDIF.

  "-----------------------------------------------------------------excel 导入 内表

  IF  R3 = 'X'.

    TYPES:BEGIN OF TY_EXCEL,
            FD1 TYPE STRING,
            FD2 TYPE STRING,
            FD3 TYPE STRING,
            FD4 TYPE STRING,
            FD5 TYPE STRING,
          END OF TY_EXCEL.



    DATA:IT_EXCEL TYPE STANDARD TABLE OF TY_EXCEL,
         WA_EXCEL LIKE LINE OF IT_EXCEL.

    IF P_FILE IS INITIAL .
      MESSAGE '请选着导入的文件' TYPE 'E'.
    ENDIF.


    DATA: IL_RAW TYPE TRUXS_T_TEXT_DATA.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    = 分隔符，默认为Tab
*       i_line_header        = 'X' "文本中的第一行是否是标题头，如果是则不会读取
        I_TAB_RAW_DATA       = IL_RAW "该参数实际上没有使用到，但为必输参数
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = IT_EXCEL.

    LOOP AT IT_EXCEL INTO WA_EXCEL.
      WRITE:/ WA_EXCEL-FD1.
    ENDLOOP.
  ENDIF.

  "-----------------------------------------------------------------excel 导入 内表

  IF  R4 = 'X'.
    IF P_FILE IS INITIAL .
      MESSAGE '请选着导入的文件' TYPE 'E'.
    ENDIF.

    DATA: IT_EMPLOYEE TYPE STANDARD TABLE OF ZEMPLOYEE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_EMPLOYEE FROM ZEMPLOYEE.
    CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
      EXPORTING
        I_FILENAME     = P_FILE
      TABLES
        I_TAB_SAP_DATA = IT_EMPLOYEE.
    IF SY-SUBRC = 0.
      MESSAGE '文件导入成功' TYPE 'S'.
    ENDIF.
  ENDIF.



  "-----------------------------------------------------------------excel 格式化输出
  IF  R5 = 'X'.
    TYPE-POOLS OLE2. " 引用ole2类型池
    DATA: V_EXCEL        TYPE OLE2_OBJECT,
          V_SHEET        TYPE OLE2_OBJECT,
          V_BOOK         TYPE OLE2_OBJECT,
          V_CELL         TYPE OLE2_OBJECT,
          V_RANGE        TYPE OLE2_OBJECT,
          V_FONT         TYPE OLE2_OBJECT,
          V_COLOR        TYPE OLE2_OBJECT,
          V_COLUMN       TYPE OLE2_OBJECT,
          V_BORDERS      TYPE OLE2_OBJECT,
          LS_DESTINATION LIKE RLGRAP-FILENAME. "下载保存的目标路径.

    DATA:C_EXPORT_FILENAME_XLS TYPE STRING VALUE 'Z1.XLS', "导出模板默认文件名 '数据导入模板'
         C_OBJID_XLS           TYPE WWWDATATAB-OBJID VALUE 'Z1',
         LO_OBJDATA            LIKE WWWDATATAB,
         LI_RC                 LIKE SY-SUBRC.   "返回值.   "存放模板的对象id

    DATA:IT_ITEM    TYPE STANDARD TABLE OF ZEMPLOYEE,
         ROW_I      TYPE I,
         COL_I      TYPE I,
         LV_TXT(50) TYPE C,
         LC_PATH    TYPE STRING.
    FIELD-SYMBOLS:<WA>    TYPE  ANY,
                  <FIELD> TYPE  ANY.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ITEM FROM  ZEMPLOYEE.

    " 检查模板是否存在   T-code:smw0
    SELECT SINGLE RELID OBJID FROM WWWDATA INTO CORRESPONDING FIELDS OF LO_OBJDATA
    WHERE SRTF2 = 0 AND RELID = 'MI' AND OBJID = C_OBJID_XLS.
    IF SY-SUBRC NE 0 OR LO_OBJDATA-OBJID EQ SPACE.
      MESSAGE '服务器未找到模板' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    "  获取保存路径
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
      CHANGING
        DESKTOP_DIRECTORY = LC_PATH.
    IF LC_PATH IS INITIAL.
      LC_PATH = 'C:\TEMP'.
    ENDIF.


    CONCATENATE  LC_PATH '\' 'Z1.XLS'  INTO LS_DESTINATION.

    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        KEY         = LO_OBJDATA
        DESTINATION = LS_DESTINATION   "下载保存路径
      IMPORTING
        RC          = LI_RC.
    IF LI_RC NE 0.
      MESSAGE '下载模板失败' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.


    CREATE OBJECT V_EXCEL 'excel.APPLICATION'.
    IF SY-SUBRC NE 0.
      MESSAGE 'EXCEL创建错误' TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.
    CALL METHOD OF
      V_EXCEL
        'WORKBOOKS' = V_BOOK.
    SET PROPERTY OF V_EXCEL 'VISIBLE' = 1.
    SET PROPERTY OF V_EXCEL 'SheetsInNewWorkbook' = 1.
    "打开excel , 新建使用:CALL METHOD OF book_obj 'Add'   = sheet_obj
    CALL METHOD OF
    V_BOOK
    'Open'   = V_SHEET
    EXPORTING
      #1       = LS_DESTINATION.
    DEFINE  EXECL_FORMAT.
      CALL METHOD OF V_EXCEL 'CELLS' = V_CELL " 单元格位置
        EXPORTING
          #1 = &1
          #2 = &2.
      SET  PROPERTY OF V_CELL 'VALUE' = &3.    " 单元格内容
      CALL METHOD   OF V_CELL 'FONT'  = V_FONT.
      SET  PROPERTY OF V_FONT 'BOLD'  = &4.    " 设置是否为粗体
      SET  PROPERTY OF V_FONT 'SIZE'  = &5.    " 设置字体大小
      SET PROPERTY OF V_FONT 'COLORINDEX'  = &6.    "设置边框宽度
    END-OF-DEFINITION.

    LOOP AT IT_ITEM ASSIGNING <WA>.
      ROW_I = SY-TABIX + 3. " 行
      DO 5 TIMES.
        ASSIGN COMPONENT SY-INDEX OF STRUCTURE <WA> TO <FIELD>.
        COL_I = SY-INDEX.
        LV_TXT = <FIELD>.
        EXECL_FORMAT ROW_I COL_I LV_TXT 1 15  7.
      ENDDO.
    ENDLOOP.

  ENDIF.

  IF R6 = 'X'. "保存文件对话框
    DATA:L_FILENAME TYPE STRING,
         L_PATH     TYPE STRING,
         L_FULLPATH TYPE STRING.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    "调用保存对话框
      EXPORTING
        DEFAULT_EXTENSION    = 'xls'
        DEFAULT_FILE_NAME    = '现金流量码'
*       INITIAL_DIRECTORY    = 'D:\'
      CHANGING
        FILENAME             = L_FILENAME
        PATH                 = L_PATH
        FULLPATH             = L_FULLPATH
      EXCEPTIONS
        CNTL_ERROR           = 1
        ERROR_NO_GUI         = 2
        NOT_SUPPORTED_BY_GUI = 3
        OTHERS               = 4.
    MESSAGE L_FULLPATH TYPE 'I'.
    DATA:L_RC          TYPE I,
         IT_FILE_TABLE TYPE STANDARD TABLE OF FILE_TABLE.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
      EXPORTING
        WINDOW_TITLE = 'window title'
      CHANGING
        FILE_TABLE   = IT_FILE_TABLE
        RC           = L_RC.
    IF L_RC = 1.
    ENDIF.
  ENDIF.


























































  "------------------------------------------------------------old 格式化输出 excle 文件。
*  TYPE-POOLS ole2. " 引用ole2类型池
*  DATA: v_excel   TYPE ole2_object,
*        v_book    TYPE ole2_object,
*        v_cell    TYPE ole2_object,
*        v_range   TYPE ole2_object,
*        v_font    TYPE ole2_object,
*        v_color   TYPE ole2_object,
*        v_column  TYPE ole2_object,
*        v_borders TYPE ole2_object.
*  DATA: BEGIN OF gs_data,
*          werks TYPE werks_d,
*          name1 TYPE name1,
*          lgort TYPE lgort_d,
*          matnr TYPE matnr,
*          maktx TYPE maktx,
*          labst TYPE labst,
*        END OF gs_data.
*  DATA: gt_data LIKE TABLE OF gs_data.
*  " 通过宏来设置指定单元格的内容和字体
*  DEFINE fill_cell.
*    call method of v_excel 'CELLS' = v_cell " 单元格位置
*      exporting
*        #1 = &1
*        #2 = &2.
*    set  property of v_cell 'value' = &3.    " 单元格内容
*
*    call method   of v_cell 'FONT'  = v_font.
*    set  property of v_font 'Bold'  = &4.    " 设置是否为粗体
*    set  property of v_font 'SIZE'  = &5.    " 设置字体大小
*    set property of v_font 'COLORINDEX'  = &6.    "设置边框宽度
*
*
*
*
*  END-OF-DEFINITION.
*  PERFORM get_data.
*  PERFORM excel_ole.
**&---------------------------------------------------------------------*
**&      Form  get_data
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM get_data.
*  gs_data-werks = '101'.
*  gs_data-name1 = '地点01'.
*  gs_data-lgort = '1000'.
*  gs_data-matnr = '1001'.
*  gs_data-maktx = '商品01'.
*  gs_data-labst = 300.
*  APPEND gs_data TO gt_data.
*  gs_data-werks = '101'.
*  gs_data-name1 = '地点01'.
*  gs_data-lgort = '1000'.
*  gs_data-matnr = '1002'.
*  gs_data-maktx = '商品02'.
*  gs_data-labst = 0.
*  APPEND gs_data TO gt_data.
*ENDFORM.                    "get_data
**&---------------------------------------------------------------------*
**&      Form  excel_ole
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM excel_ole.
*  FIELD-SYMBOLS: <wa>    TYPE any,
*                 <field> TYPE any.
*  DATA: lv_txt(50) TYPE c.
*  DATA: row_i TYPE i,
*        col_i TYPE i.
*  "创建Excel对象
*  CREATE OBJECT v_excel 'Excel.Application'.
*  " 添加一个sheet
*  CALL METHOD OF
*    v_excel
*      'Workbooks' = v_book.
*  CALL METHOD OF
*    v_book
*    'ADD'.
*  " 填写首行标题
*  fill_cell 1 1 '当前商品可用库存状态' 1 18  7.
*  "设置标题文本居中
*  SET PROPERTY OF v_cell 'HORIZONTALALIGNMENT' = -4108.
*  " 标题加下划线
*  SET PROPERTY OF v_font 'UNDERLINE' = 2.
*  " 设置表头，表头统一为10号字体，加粗
*  fill_cell 2 1 '地点'     1 10  7.
*  fill_cell 2 2 '地点描述' 1 10  1.
*  fill_cell 2 3 '库位'     1 10  2.
*  fill_cell 2 4 '商品'     1 10  3.
*  fill_cell 2 5 '商品描述' 1 10  4.
*  fill_cell 2 6 '当前库存' 1 10  5.
*  " 选中标题所在的单元格并合并
*  CALL METHOD OF
*      v_excel
*      'RANGE' = v_range
*    EXPORTING
*      #1      = 'A1'
*      #2      = 'F1'.
*  CALL METHOD OF
*    v_range
*    'SELECT'.
*  " 合并单元格
*  SET PROPERTY OF v_range 'MERGECELLS' = 1.
*  " 从內表循环数据，按顺序填到单元格中
*  LOOP AT gt_data ASSIGNING <wa>.
*    row_i = sy-tabix + 2. " 行
*    DO 6 TIMES.
*      col_i = sy-index. " 列
*      ASSIGN COMPONENT sy-index OF STRUCTURE <wa> TO <field>.
*      lv_txt = <field>.
*      fill_cell row_i col_i lv_txt 0 10  6.
*      IF col_i = 6 AND lv_txt <= 0.
*        " 当可用库存为0时，在Excel中将单元格标识为黄色
*        CALL METHOD OF
*          v_cell
*            'INTERIOR' = v_color.
*        SET PROPERTY OF v_color 'COLORINDEX' = 6.
*      ENDIF.
*    ENDDO.
*  ENDLOOP.
*  " 将EXCEL单元格宽度按实际文本长度来设置
*  CALL METHOD OF
*    v_excel
*      'COLUMNS' = v_column.
*  CALL METHOD OF
*    v_column
*    'AUTOFIT'.
*  " 设置excel为可见
*  SET PROPERTY OF v_excel 'Visible' = 1.
*ENDFORM.                    "excel
*ENDFORM.

  "------------------------------------------------------------old 格式化输出 excle 文件。
