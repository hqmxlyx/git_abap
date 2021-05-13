*&---------------------------------------------------------------------*
*& Report ZGIT012
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT012.

"-------------------------切换发送方式--------------------------”
PERFORM FRM_SENDEMAIL_BINARY."二进制输出附件
PERFORM FRM_SENDEMAIL_DOWNLOAD."下载附件格式输出文件
PERFORM FRM_SENDEMAIL_OO."将本地文件当做附件发送
"PERFORM FRM_SENDEMAIL_002."


"发送邮件 https://blog.csdn.net/syosinnsya/article/details/78460006
DATA GV_METHOD1      LIKE SY-UCOMM.
DATA GS_USER         LIKE SOUDNAMEI1.
DATA GS_USER_DATA    LIKE SOUDATAI1.
DATA GV_OWNER        LIKE SOUD-USRNAM.
DATA GT_RECEIPIENTS  LIKE SOOS1 OCCURS 0 WITH HEADER LINE.
DATA GS_DOCUMENT     LIKE SOOD4 .
DATA GS_HEADER2      LIKE SOOD2.
DATA GS_FOLMAM       LIKE SOFM2.
DATA GT_OBJCNT       LIKE SOLI OCCURS 0 WITH HEADER LINE.
DATA GT_OBJHEAD      LIKE SOLI OCCURS 0 WITH HEADER LINE.
DATA GT_OBJPARA      LIKE SELC OCCURS 0 WITH HEADER LINE.
DATA GT_OBJPARB      LIKE SOOP1 OCCURS 0 WITH HEADER LINE.
DATA GT_ATTACHMENTS  LIKE SOOD5 OCCURS 0 WITH HEADER LINE.
DATA GT_REFERENCES   LIKE SOXRL OCCURS 0 WITH HEADER LINE.
DATA GS_RECIVER      LIKE SOOS6 .
DATA GV_AUTHORITY    LIKE SOFA-USRACC.
DATA GS_REF_DOCUMENT LIKE SOOD4.
DATA GS_NEW_PARENT   LIKE SOODK.
DATA: BEGIN OF GT_FILES OCCURS 10 ,
        TEXT(4096) TYPE C,
      END OF GT_FILES.
DATA : GV_FOLD_NUMBER(12) TYPE C,
       GV_FOLD_YR(2)      TYPE C,
       GV_FOLD_TYPE(3)    TYPE C.
DATA: GS_FOLDER_ID LIKE SOODK,
      GS_ORDER_ID  LIKE SOODK.
DATA: GV_MAIL_TITLE(50).
DATA: GT_RECEIVERS LIKE SOOS1 OCCURS 0 WITH HEADER LINE.


FORM FRM_SENDEMAIL_BINARY.
  DATA: BEGIN OF LT_EMAIL OCCURS 0,
          ZBOX(4)    TYPE C,                "序号
          ZVBELN(20) TYPE C,               "销售订单编号
          ETENR      TYPE  VBEP-ETENR,     "计划行编号
          BSTKD      TYPE  VBKD-BSTKD,     "客户单号
          MATNR      TYPE  VBAP-MATNR,     "物料编号
          ARKTX      TYPE  VBAP-ARKTX,     "物料描述
          KWMENG     TYPE  STRING,         "销售订单数量
          EDATU      TYPE  VBEP-EDATU,     "变更前交货日期
          PSB03      TYPE ZYCOPPSB-PSB03,  "变更后评估日期
          VSART      TYPE  VBKD-VSART, " 出货方式
          PSB04      TYPE ZYCOPPSB-PSB04, "订单评审备注
        END OF LT_EMAIL.

  LT_EMAIL-ZVBELN = '111111'.
  LT_EMAIL-BSTKD = 'sadfasdf'.
  APPEND LT_EMAIL.

  LT_EMAIL-ZVBELN = '1231231231'.
  LT_EMAIL-BSTKD = 'sadfasdf'.
  APPEND LT_EMAIL.

* *邮件发送相关变量
  DATA: I_OBJPACK       LIKE SOPCKLSTI1 OCCURS 0 WITH HEADER LINE,
        I_OBJTXT        LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE,
        I_OBJBIN        LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE,
        I_RECLIST       LIKE SOMLRECI1 OCCURS 0 WITH HEADER LINE,
        I_RECORD        LIKE SOLISTI1 OCCURS 0 WITH HEADER LINE,
        V_OBJHEAD       TYPE SOLI_TAB,
        V_LINES_TXT     TYPE I,
        V_LINES_BIN     TYPE I,
        V_DOCCHGI       TYPE SODOCCHGI1,
        V_LINES_BIN_ALL TYPE I,
        FILELEN         TYPE I.
  DATA: LV_STRING TYPE STRING.
  CONSTANTS:
    GC_TAB  TYPE C VALUE CL_BCS_CONVERT=>GC_TAB,  "CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB
    GC_CRLF TYPE C VALUE CL_BCS_CONVERT=>GC_CRLF. "CL_ABAP_CHAR_UTILITIES=>CR_LF
  DATA: C_MIMETYPE TYPE CHAR64 VALUE 'APPLICATION/MSEXCEL;charset=utf-16le'.
  DATA: V_XATTACH TYPE XSTRING.
  DATA: I_CONTENTS_HEX  LIKE SOLIX   OCCURS 0 WITH HEADER LINE.
  DATA: GT_ZSMAIL LIKE TABLE OF ZSZMAIL WITH HEADER LINE.

  SELECT * FROM ZSZMAIL INTO TABLE GT_ZSMAIL WHERE TCODE = 'MING.HE' . "取邮箱地址
  IF GT_ZSMAIL[] IS INITIAL.
    EXIT.
  ENDIF.

  "邮件标题
  CONCATENATE  SY-DATUM '评审交期变更' INTO V_DOCCHGI-OBJ_DESCR  .

  "正文
  I_OBJTXT = 'Dear All '.
  APPEND I_OBJTXT.
  I_OBJTXT = '         您好：有新的销售订单交期变更，请查阅附件！'.
  APPEND I_OBJTXT.
  I_OBJTXT = ''.
  APPEND I_OBJTXT.
  I_OBJTXT = ''.
  APPEND I_OBJTXT.
  I_OBJTXT = '此邮件系统订单复审时自动转发，请勿直接回复!有疑问时请联系生管相关人员!'.
  APPEND I_OBJTXT.
  I_OBJTXT = '如对评审结果有异议，请在邮件发送后8小时之内提出!'.
  APPEND I_OBJTXT.
  I_OBJTXT = '谢谢!'.
  APPEND I_OBJTXT.

  DESCRIBE TABLE I_OBJTXT LINES V_LINES_TXT.

  I_OBJPACK-TRANSF_BIN = ''.   "二进制传输标志
  I_OBJPACK-HEAD_START = 1.
  I_OBJPACK-HEAD_NUM = 0.
  I_OBJPACK-BODY_START = 1.
  I_OBJPACK-BODY_NUM = V_LINES_TXT.
  I_OBJPACK-DOC_TYPE = 'RAW'.    "正文
  APPEND I_OBJPACK.

  LOOP AT  LT_EMAIL  .
    LT_EMAIL-ZBOX = SY-TABIX.
    MODIFY LT_EMAIL  .
    CLEAR:LT_EMAIL.
  ENDLOOP.

  CONCATENATE LV_STRING
          '序号'     GC_TAB
          '销售订单单号'     GC_TAB
          '计划行'     GC_TAB                                  "#EC NOTEXT
          '客户采购单号'     GC_TAB
          '物料编号'     GC_TAB
          '物料描述'     GC_TAB
          '订单数量'    GC_TAB
          '变更前出货日期' GC_TAB
          '变更后出货日期' GC_TAB
          '出货方式' GC_TAB
          '备注'    GC_CRLF                                   "#EC NOTEXT
          INTO LV_STRING.

  LOOP AT LT_EMAIL.
    CONCATENATE LV_STRING
            LT_EMAIL-ZBOX    GC_TAB
            LT_EMAIL-ZVBELN    GC_TAB
            LT_EMAIL-ETENR    GC_TAB                        "#EC NOTEXT
            LT_EMAIL-BSTKD    GC_TAB
            LT_EMAIL-MATNR     GC_TAB
            LT_EMAIL-ARKTX     GC_TAB
            LT_EMAIL-KWMENG    GC_TAB
            LT_EMAIL-EDATU    GC_TAB
            LT_EMAIL-PSB03     GC_TAB
            LT_EMAIL-VSART    GC_TAB
            LT_EMAIL-PSB04    GC_CRLF                       "#EC NOTEXT
            INTO LV_STRING.
  ENDLOOP.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      TEXT     = LV_STRING
      MIMETYPE = C_MIMETYPE
    IMPORTING
      BUFFER   = V_XATTACH
    EXCEPTIONS
      FAILED   = 1
      OTHERS   = 2.
* Add the file header for utf-16le. .
  IF SY-SUBRC = 0.
    CONCATENATE CL_ABAP_CHAR_UTILITIES=>BYTE_ORDER_MARK_LITTLE
    V_XATTACH INTO V_XATTACH IN BYTE MODE.
  ENDIF.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER     = V_XATTACH
    TABLES
      BINARY_TAB = I_CONTENTS_HEX.

  DESCRIBE TABLE LT_EMAIL LINES V_LINES_BIN.
  I_OBJPACK-TRANSF_BIN = 'X'.
  I_OBJPACK-BODY_START = '1' .
  I_OBJPACK-BODY_NUM = V_LINES_BIN * 2.
  I_OBJPACK-DOC_TYPE = 'XLS'.
  I_OBJPACK-OBJ_NAME = 'text'.
  I_OBJPACK-DOC_SIZE = V_LINES_BIN * 255 * 2.
  I_OBJPACK-OBJ_DESCR =  '复审交期记录.xlsx'."附件名
  APPEND I_OBJPACK.

**接收人
  CLEAR I_RECLIST.
  LOOP AT GT_ZSMAIL.
    I_RECLIST-RECEIVER = GT_ZSMAIL-ADDRESS. "邮箱地址
    I_RECLIST-EXPRESS = 'X'.
    I_RECLIST-REC_TYPE = 'U'.
    I_RECLIST-BLIND_COPY = ''.
    APPEND I_RECLIST.
  ENDLOOP.
*  DATA: LIT_MAILHEX TYPE SOLIX_TAB,
*        L_FILE_SIZE TYPE I.
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
*    EXPORTING
*      FILENAME        = 'C:\temp\设备保养记录表.xlsx'
*      FILETYPE        = 'BIN'
*    IMPORTING
*      FILELENGTH      = L_FILE_SIZE
*    CHANGING
*      DATA_TAB        = LIT_MAILHEX
*    EXCEPTIONS
*      FILE_OPEN_ERROR = 1
*      OTHERS          = 2.
*  IF SY-SUBRC <> 0 .
*    RETURN.
*  ENDIF.
*
*  I_OBJPACK-TRANSF_BIN = 'X'.
*  I_OBJPACK-BODY_START = '1' .
**  I_OBJPACK-BODY_NUM = L_FILE_SIZE * 2.
*  I_OBJPACK-DOC_TYPE = 'XLS'.
*  I_OBJPACK-OBJ_NAME = 'text'.
*  I_OBJPACK-DOC_SIZE = L_FILE_SIZE * 255 * 2.
*  I_OBJPACK-OBJ_DESCR =  '复审交期记录'."附件名
*  APPEND I_OBJPACK.

  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = V_DOCCHGI    "邮件标题
      PUT_IN_OUTBOX              = 'X'
      COMMIT_WORK                = 'X'
    TABLES
      PACKING_LIST               = I_OBJPACK  " 参数设置
      OBJECT_HEADER              = V_OBJHEAD
*     contents_bin               = i_objbin
      CONTENTS_TXT               = I_OBJTXT    "正文
      RECEIVERS                  = I_RECLIST   "接受账号
      CONTENTS_HEX               = I_CONTENTS_HEX "附件内容
*     CONTENTS_HEX               = LIT_MAILHEX "附件内容
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 1
      DOCUMENT_NOT_SENT          = 2
      DOCUMENT_TYPE_NOT_EXIST    = 3
      OPERATION_NO_AUTHORIZATION = 4
      PARAMETER_ERROR            = 5
      X_ERROR                    = 6
      ENQUEUE_ERROR              = 7
      OTHERS                     = 8.
  IF SY-SUBRC = 0.
    WAIT UP TO 2 SECONDS.
    SUBMIT RSCONN01 WITH MODE = 'INT' AND RETURN.
  ENDIF.
ENDFORM.

FORM FRM_SENDEMAIL_DOWNLOAD .
  GV_MAIL_TITLE = '这是邮件标题'.

** 发件人信息 edit
  PERFORM SO_USER_READ.
**邮件信息、属性定义
  PERFORM DOCUMENT_REPOSITORY.
**附件生成
  PERFORM CREAT_ATTACHMENTS.
**send mail
  PERFORM SEND.

ENDFORM.


FORM SO_USER_READ .
  GS_USER-SAPNAME = SY-UNAME.
  CALL FUNCTION 'SO_USER_READ_API1'
    EXPORTING
      USER            = GS_USER
    IMPORTING
      USER_DATA       = GS_USER_DATA
    EXCEPTIONS
      USER_NOT_EXIST  = 1
      PARAMETER_ERROR = 2
      X_ERROR         = 3
      OTHERS          = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  GV_FOLD_TYPE   = GS_USER_DATA-OUTBOXFOL+0(3).
  GV_FOLD_YR     = GS_USER_DATA-OUTBOXFOL+3(2).
  GV_FOLD_NUMBER = GS_USER_DATA-OUTBOXFOL+5(12).

  CLEAR: GT_FILES[], GT_FILES.
  REFRESH : GT_OBJCNT,
  GT_OBJHEAD,
  GT_OBJPARA,
  GT_OBJPARB,
  GT_RECEIPIENTS,
  GT_ATTACHMENTS,
  GT_REFERENCES,
  GT_FILES.
  CLEAR  :    GS_DOCUMENT,
  GS_HEADER2,
  GT_OBJCNT,
  GT_OBJHEAD,
  GT_OBJPARA,
  GT_OBJPARB,
  GT_RECEIPIENTS,
  GT_ATTACHMENTS,
  GT_REFERENCES,
  GT_FILES.
ENDFORM.                    " SO_USER_READ
*&---------------------------------------------------------------------*
*&      Form  DOCUMENT_REPOSITORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOCUMENT_REPOSITORY .
  GV_METHOD1 = 'SAVE'.
  GS_DOCUMENT-FOLTP   = GV_FOLD_TYPE.
  GS_DOCUMENT-FOLYR   = GV_FOLD_YR.
  GS_DOCUMENT-FOLNO   = GV_FOLD_NUMBER.
  GS_DOCUMENT-OBJTP   = GS_USER_DATA-OBJECT_TYP.
*g_document-OBJYR   = '27'.
*g_document-OBJNO   = '000000002365'.
*g_document-OBJNAM = 'MESSAGE'.
  GS_DOCUMENT-OBJDES   = 'mail of sap by program'.
  GS_DOCUMENT-FOLRG   = 'O'.
*g_document-okcode   = 'CHNG'.
  GS_DOCUMENT-OBJLEN = '0'.
*  g_document-file_ext = 'TXT'.
  GS_HEADER2-OBJDES = GV_MAIL_TITLE.
*  g_header-file_ext = 'TXT'.

  CALL FUNCTION 'SO_DOCUMENT_REPOSITORY_MANAGER'
    EXPORTING
      METHOD       = GV_METHOD1
      OFFICE_USER  = SY-UNAME
      REF_DOCUMENT = GS_REF_DOCUMENT
      NEW_PARENT   = GS_NEW_PARENT
    IMPORTING
      AUTHORITY    = GV_AUTHORITY
    TABLES
      OBJCONT      = GT_OBJCNT
      OBJHEAD      = GT_OBJHEAD
      OBJPARA      = GT_OBJPARA
      OBJPARB      = GT_OBJPARB
      RECIPIENTS   = GT_RECEIPIENTS
      ATTACHMENTS  = GT_ATTACHMENTS
      REFERENCES   = GT_REFERENCES
      FILES        = GT_FILES
    CHANGING
      DOCUMENT     = GS_DOCUMENT
      HEADER_DATA  = GS_HEADER2.
ENDFORM.                    " DOCUMENT_REPOSITORY
*&---------------------------------------------------------------------*
*&      Form  CREAT_ATTACHMENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREAT_ATTACHMENTS .
*  "判断文件路径
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_EXIST
*      EXPORTING
*        DIRECTORY            = 文件路径
*      RECEIVING
*        RESULT               = RESULT
*      EXCEPTIONS
*        CNTL_ERROR           = 1
*        ERROR_NO_GUI         = 2
*        WRONG_PARAMETER      = 3
*        NOT_SUPPORTED_BY_GUI = 4
*        OTHERS               = 5.
*  "删除
*      CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_DELETE
*        EXPORTING
*          DIRECTORY               = 文件路径
*        CHANGING
*          RC                      = RC
*        EXCEPTIONS
*          DIRECTORY_DELETE_FAILED = 1
*          CNTL_ERROR              = 2
*          ERROR_NO_GUI            = 3
*          PATH_NOT_FOUND          = 4
*          DIRECTORY_ACCESS_DENIED = 5
*          UNKNOWN_ERROR           = 6
*          NOT_SUPPORTED_BY_GUI    = 7
*          WRONG_PARAMETER         = 8
*          OTHERS                  = 9.

* File from the pc to send..
  GV_METHOD1 = 'ATTCREATEFROMPC'.
*  GV_SAVE_PATHT = P_FILE.
  GT_FILES-TEXT = 'C:\temp\设备保养记录表.xlsx'.
  APPEND GT_FILES.
  CALL FUNCTION 'SO_DOCUMENT_REPOSITORY_MANAGER'
    EXPORTING
      METHOD       = GV_METHOD1
      OFFICE_USER  = GV_OWNER
      REF_DOCUMENT = GS_REF_DOCUMENT
      NEW_PARENT   = GS_NEW_PARENT
    IMPORTING
      AUTHORITY    = GV_AUTHORITY
    TABLES
      OBJCONT      = GT_OBJCNT
      OBJHEAD      = GT_OBJHEAD
      OBJPARA      = GT_OBJPARA
      OBJPARB      = GT_OBJPARB
      RECIPIENTS   = GT_RECEIPIENTS
      ATTACHMENTS  = GT_ATTACHMENTS
      REFERENCES   = GT_REFERENCES
      FILES        = GT_FILES
    CHANGING
      DOCUMENT     = GS_DOCUMENT
      HEADER_DATA  = GS_HEADER2.
ENDFORM.                    " CREAT_ATTACHMENTS
*&---------------------------------------------------------------------*
*&      Form  SEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND .
  CLEAR: GS_FOLDER_ID,GS_ORDER_ID.
  GS_FOLDER_ID-OBJTP = GS_DOCUMENT-FOLTP .
  GS_FOLDER_ID-OBJYR = GS_DOCUMENT-FOLYR.
  GS_FOLDER_ID-OBJNO = GS_DOCUMENT-FOLNO.
  GS_ORDER_ID-OBJTP = GS_DOCUMENT-OBJTP.
  GS_ORDER_ID-OBJYR = GS_DOCUMENT-OBJYR.
  GS_ORDER_ID-OBJNO = GS_DOCUMENT-OBJNO.

*收件人信息可以添加多个收件人-----------------------------------
  REFRESH GT_RECEIVERS.
  GT_RECEIVERS-RECESC = 'U'.
  GT_RECEIVERS-SNDEX  = 'X'.
  GT_RECEIVERS-RECEXTNAM = 'liumk@kusauto.com.cn'.
  APPEND GT_RECEIVERS.

  CALL FUNCTION 'SO_OBJECT_SEND'
    EXPORTING
      FOLDER_ID                  = GS_FOLDER_ID
      OBJECT_ID                  = GS_ORDER_ID
    TABLES
      OBJCONT                    = GT_OBJCNT
      OBJHEAD                    = GT_OBJHEAD
      OBJPARA                    = GT_OBJPARA
      OBJPARB                    = GT_OBJPARB
      RECEIVERS                  = GT_RECEIVERS
      PACKING_LIST               = GT_ATTACHMENTS
    EXCEPTIONS
      ACTIVE_USER_NOT_EXIST      = 1
      COMMUNICATION_FAILURE      = 2
      COMPONENT_NOT_AVAILABLE    = 3
      FOLDER_NOT_EXIST           = 4
      FOLDER_NO_AUTHORIZATION    = 5
      FORWARDER_NOT_EXIST        = 6
      NOTE_NOT_EXIST             = 7
      OBJECT_NOT_EXIST           = 8
      OBJECT_NOT_SENT            = 9
      OBJECT_NO_AUTHORIZATION    = 10
      OBJECT_TYPE_NOT_EXIST      = 11
      OPERATION_NO_AUTHORIZATION = 12
      OWNER_NOT_EXIST            = 13
      PARAMETER_ERROR            = 14
      SUBSTITUTE_NOT_ACTIVE      = 15
      SUBSTITUTE_NOT_DEFINED     = 16
      SYSTEM_FAILURE             = 17
      TOO_MUCH_RECEIVERS         = 18
      USER_NOT_EXIST             = 19
      X_ERROR                    = 20
      OTHERS                     = 21.

  COMMIT WORK.
******直接发送邮件的代码********
  SUBMIT RSCONN01 WITH MODE ='INT'
  WITH OUTPUT = 'X'
  AND RETURN.
ENDFORM.

FORM FRM_SENDEMAIL_OO .
  DATA:LO_DOCUMENT      TYPE REF TO CL_DOCUMENT_BCS,
       L_FILE_SIZE      TYPE I,
       LIT_CONTENTS     TYPE SOLI_TAB,
       L_STRING         TYPE STRING,
       LIT_MAILHEX      TYPE SOLIX_TAB,
       L_TO             TYPE ADR6-SMTP_ADDR,
       L_CC             TYPE ADR6-SMTP_ADDR,
       L_BCS_TO         TYPE REF TO IF_RECIPIENT_BCS,
       L_BCS_CC         TYPE REF TO IF_RECIPIENT_BCS,
       LO_SENDER        TYPE REF TO CL_SAPUSER_BCS,
       L_RESULT         TYPE OS_BOOLEAN,
       W_DOCUMENT       TYPE REF TO CL_BCS,
       L_FILE_SIZE_CHAR TYPE SO_OBJ_LEN,
       L_FILEN          TYPE STRING,
       L_RC             TYPE I,
       L_SUBJECT        TYPE SO_OBJ_DES,
       LO_FAIL          TYPE REF TO CX_BCS.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME        = 'D:\202008印花税.xlsx'
      FILETYPE        = 'BIN'
    IMPORTING
      FILELENGTH      = L_FILE_SIZE
    CHANGING
      DATA_TAB        = LIT_MAILHEX
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0 .
    RETURN.
  ENDIF.

  L_FILE_SIZE_CHAR = L_FILE_SIZE.
  L_STRING = 'Hello,地球人，点开附件有惊喜'.
  APPEND L_STRING TO LIT_CONTENTS.

  TRY .
      CREATE OBJECT LO_DOCUMENT.
      LO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
      I_TYPE = 'HTM'
      I_SUBJECT = '一封来自火星的测试邮件'
      I_LENGTH = L_FILE_SIZE_CHAR
      I_LANGUAGE = SY-LANGU
      I_IMPORTANCE = '1'
      I_TEXT = LIT_CONTENTS
      ).
      L_SUBJECT = '附件.xls'.
      CALL METHOD LO_DOCUMENT->ADD_ATTACHMENT
        EXPORTING
          I_ATTACHMENT_TYPE    = 'BIN'
          I_ATTACHMENT_SUBJECT = L_SUBJECT
          I_ATTACHMENT_SIZE    = L_FILE_SIZE_CHAR
          I_ATT_CONTENT_HEX    = LIT_MAILHEX.

      W_DOCUMENT = CL_BCS=>CREATE_PERSISTENT( ).

      LO_SENDER = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
      W_DOCUMENT->SET_SENDER( LO_SENDER ).
      L_TO = 'hem@kusauto.com.cn'."收件人
      L_BCS_TO = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( L_TO ).
      CALL METHOD W_DOCUMENT->ADD_RECIPIENT
        EXPORTING
          I_RECIPIENT = L_BCS_TO.
      "抄送人
*      L_CC = 'hem@kusauto.com.cn'.
*      L_BCS_CC = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( L_CC ).
*      CALL METHOD W_DOCUMENT->ADD_RECIPIENT
*        EXPORTING
*          I_RECIPIENT = L_BCS_CC
*          I_COPY      = 'X'.

      W_DOCUMENT->SET_SEND_IMMEDIATELY( 'X' )."设置立即发送
      W_DOCUMENT->SEND_REQUEST->SET_LINK_TO_OUTBOX( 'X' )."与outbox关联
      CALL METHOD W_DOCUMENT->SEND(
        EXPORTING
          I_WITH_ERROR_SCREEN = 'X'
        RECEIVING
          RESULT              = L_RESULT ).
    CATCH CX_BCS INTO  LO_FAIL.
  ENDTRY.

  IF L_RESULT = 'X'.
    COMMIT WORK AND WAIT.
    MESSAGE '邮件发送成功！' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE '邮件发送失败！' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SENDEMAIL_002
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SENDEMAIL_002 .
  TYPES: BEGIN OF XML_LINE,
           DATA(255) TYPE X,
         END OF XML_LINE.
  DATA:
    L_XML_TABLE_FORECAST    TYPE TABLE OF XML_LINE,
    L_RC                    TYPE I,
    L_XML_SIZE              TYPE I,
    WA_XML                  TYPE XML_LINE,
    GS_SOLIX                TYPE SOLIX,
    BINARY_CONTENT_FORECAST TYPE SOLIX_TAB,
    SENT_TO_ALL             TYPE OS_BOOLEAN,
    MAIN_TEXT               TYPE BCSY_TEXT,
    SEND_REQUEST            TYPE REF TO CL_BCS,
    DOCUMENT                TYPE REF TO CL_DOCUMENT_BCS,
    RECIPIENT               TYPE REF TO IF_RECIPIENT_BCS,
    BCS_EXCEPTION           TYPE REF TO CX_BCS,
    MAILTO                  TYPE AD_SMTPADR VALUE 'liumk@kusauto.com.cn',
    LIT_MAILHEX             TYPE SOLIX_TAB,
    L_FILE_SIZE             TYPE I.

  DATA: LC_XLS_TYPE       TYPE SO_OBJ_TP VALUE 'XLS',
        LC_CODEPAGE       TYPE ABAP_ENCOD VALUE '4103',
        LV_STRING         TYPE STRING,
        LV_SIZE           TYPE SO_OBJ_LEN,
        LC_ADD_ATTC       TYPE SO_OBJ_DES VALUE 'popup',
        LT_BINARY_CONTENT TYPE SOLIX_TAB.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME        = 'D:\202008印花税.xlsx'
      FILETYPE        = 'BIN'
    IMPORTING
      FILELENGTH      = L_FILE_SIZE
    CHANGING
      DATA_TAB        = LIT_MAILHEX
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0 .
    RETURN.
  ENDIF.

  TRY .
*    -------------create persistent sent request----------------
      SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).
*    -------------create and set document with attachment-------
*    create document object from internal table with text
      APPEND '<div>Mail text!<div>' TO MAIN_TEXT.
      APPEND '<div><table><tr><td>asdfasdf<td><tr><table><div>' TO MAIN_TEXT.
      DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
        I_TYPE = 'HTM'
        I_TEXT = MAIN_TEXT
        I_SUBJECT = 'Test created' ).
*    add the spread sheet as attachment to document object
      DOCUMENT->ADD_ATTACHMENT(
        I_ATTACHMENT_TYPE = 'BIN'
        I_ATTACHMENT_SUBJECT = 'SpreadSheet.xlsx'
        I_ATT_CONTENT_HEX =  LIT_MAILHEX ).
*    send document object to send request
      SEND_REQUEST->SET_DOCUMENT( DOCUMENT ).
*    --------------add recipient (e-mail address)--------------
*    create recipient object
      RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( MAILTO ).
*    add recipient object to send request
      SEND_REQUEST->ADD_RECIPIENT( RECIPIENT ).
*    --------------send document ------------------------------
      SENT_TO_ALL = SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).
      COMMIT WORK.
      IF SENT_TO_ALL IS INITIAL.
        MESSAGE I500(SBCOMS) WITH MAILTO.
      ELSE.
        MESSAGE S022(SO).
      ENDIF.
*    ---------------exception handling ------------------------
    CATCH CX_BCS INTO BCS_EXCEPTION.
      MESSAGE I865(SO) WITH BCS_EXCEPTION->ERROR_TYPE.
  ENDTRY.
ENDFORM.
