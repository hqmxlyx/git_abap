*&---------------------------------------------------------------------*
*& Report ZGIT009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT009.


DATA: EXCEL       TYPE OLE2_OBJECT,
      WORKBOOK    TYPE OLE2_OBJECT,
      APPLICATION TYPE OLE2_OBJECT,
      SHEETS      TYPE OLE2_OBJECT,
      SHEET       TYPE OLE2_OBJECT,
      NEWSHEET    TYPE OLE2_OBJECT,
      CELL        TYPE OLE2_OBJECT,
      RANGE       TYPE OLE2_OBJECT,
      ROWS        TYPE OLE2_OBJECT.


CREATE OBJECT EXCEL 'EXCEL.APPLICATION' .
SET PROPERTY OF EXCEL 'VISIBLE' = 1 ."1 可见  2 不可见
GET PROPERTY OF EXCEL 'WORKBOOKS' = WORKBOOK.
CALL METHOD OF WORKBOOK 'OPEN'
  EXPORTING
    #1 = 'C:\USERS\ZY184632.KUSAUTO\DESKTOP\TEXT.XLSX'.

GET PROPERTY OF WORKBOOK 'APPLICATION' = APPLICATION.

"-------------------------指定 SHEET 并激活操作
CALL METHOD OF APPLICATION 'WORKSHEETS' = SHEETS
    EXPORTING
      #1 = 'SHEET3'."这里SHEET3为要操作的SHEET的名字。
CALL METHOD OF SHEETS 'ACTIVATE '.
"------------------------指定 SHEET 并激活操作


CALL METHOD OF EXCEL 'CELLS' = CELL
    EXPORTING
      #1 = 2
      #2 = 2.

DATA:BREAKLINE TYPE CHAR2,
     STR       TYPE STRING.
"自动换行符
BREAKLINE = CL_ABAP_CHAR_UTILITIES=>CR_LF.

STR = '换行例子' && BREAKLINE  &&  '开始换行'.
SET PROPERTY OF CELL 'VALUE'=  STR .


"------------------------------切换到第二个SHEET 进行操作
CALL METHOD OF APPLICATION 'WORKSHEETS' = SHEET
    EXPORTING
      #1 = 'SHEET2'."这里SHEET3为要操作的SHEET的名字。
CALL METHOD OF SHEET 'ACTIVATE '.

CALL METHOD OF EXCEL 'CELLS' = CELL
    EXPORTING
      #1 = 1
      #2 = 1.
SET PROPERTY OF CELL 'VALUE'=  '切换到第二个SHEET进行操作'.


"-----------------复制指定数据粘贴到新增的SHEET中
CALL METHOD OF EXCEL 'RANGE' = CELL
     EXPORTING
     #1 = 'A1'
     #2 = 'F12'.
CALL METHOD OF CELL 'COPY'.

"-----------------复制指定数据粘贴到新增的SHEET中

"------------------------------切换到第二个SHEET 进行操作


"----------------------增加SHEET 进行操作
CALL METHOD OF APPLICATION 'SHEETS' = SHEET.
CALL METHOD OF SHEET 'ADD' = SHEET.
SET PROPERTY OF SHEET 'NAME' = '新的SHEET名称' .
"正对当期SHEET 进行选择
CALL METHOD OF SHEET 'RANGE' = CELL
     EXPORTING
     #1 = 'A1'
     #2 = 'F12'.

CALL METHOD OF SHEET 'PASTE'.


"插入一行
CALL METHOD OF EXCEL
 'ROWS'      = ROWS
 EXPORTING
   #1          = '2'.
CALL METHOD OF ROWS'INSERT'.


"----------------------增加SHEET 进行操作


"----------------------保存并退出
"文档不是下载下来的直接定制位置进行保存
*CALL METHOD OF SHEET 'SAVEAS'
*  EXPORTING
*    #1 = 'C:\USERS\ZY184632.KUSAUTO\DESKTOP\TEXT1.XLSX' "保存的路径
*    #2 = 1.

"文档是下载下来的直接保存
SET PROPERTY OF EXCEL 'SCREENUPDATING' = 1.
GET PROPERTY OF EXCEL 'ACTIVEWORKBOOK' = WORKBOOK.
CALL METHOD OF WORKBOOK 'SAVE'.
CALL METHOD OF WORKBOOK 'CLOSE'.
CALL METHOD OF EXCEL 'QUIT'.

**退出
CALL METHOD OF APPLICATION 'QUIT'.
"----------------------保存并退出

FREE: EXCEL,
      WORKBOOK,
      APPLICATION,
      SHEETS,
      SHEET,
      NEWSHEET,
      CELL,
      RANGE,
      ROWS.
