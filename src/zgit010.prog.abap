*&---------------------------------------------------------------------*
*& Report ZGIT010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT010.

DATA: LS_RETURN TYPE BAPIRETI,
      LT_RETURN TYPE TABLE OF BAPIRETI,
      LS_MSG    TYPE BAPIRETC.
DATA: LV_LEN1 TYPE I,
      LV_LEN2 TYPE I.
DATA: LV_GUID TYPE BUT000-PARTNER_GUID.
DATA: L_BANK_CTRY    TYPE BAPI1011_KEY-BANK_CTRY,
      L_BANK_KEY     TYPE BAPI1011_KEY-BANK_KEY,
      L_BANK_ADDRESS TYPE BAPI1011_ADDRESS.
DATA: LS_PARTNER      TYPE BUS_EI_EXTERN,
      LV_PARTNER_GUID TYPE BU_PARTNER_GUID,
      LS_ADDRESSES    TYPE BUS_EI_BUPA_ADDRESS,
      LT_ADDRESSES    TYPE BUS_EI_BUPA_ADDRESS_T,
      LS_PHONE        TYPE BUS_EI_BUPA_TELEPHONE,
      LT_PHONE        TYPE BUS_EI_BUPA_TELEPHONE_T,
      LS_FAX          TYPE BUS_EI_BUPA_FAX,
      LT_FAX          TYPE BUS_EI_BUPA_FAX_T,
      LS_SMTP         TYPE BUS_EI_BUPA_SMTP,
      LT_SMTP         TYPE BUS_EI_BUPA_SMTP_T,
      LS_BANKDETAILS  TYPE BUS_EI_BUPA_BANKDETAIL,
      LT_BANKDETAILS  TYPE BUS_EI_BUPA_BANKDETAIL_T,
      LS_ROLE         TYPE BUS_EI_BUPA_ROLES,
      LT_ROLE         TYPE BUS_EI_BUPA_ROLES_T,
      LS_VENDOR       TYPE VMDS_EI_EXTERN,
      LS_DATA         TYPE CVIS_EI_EXTERN,
      LT_DATA         TYPE CVIS_EI_EXTERN_T.
DATA:L_PARTNER TYPE BUT000-PARTNER.
DATA:LS_REMARKS    TYPE BUS_EI_BUPA_COMREM,
     LT_REMARKS    TYPE BUS_EI_BUPA_COMREM_T,
     LT_TAXNUMBERS TYPE BUS_EI_BUPA_TAXNUMBER_T,
     LS_TAXNUMBERS TYPE BUS_EI_BUPA_TAXNUMBER,
     LS_CUSTOMER   TYPE CMDS_EI_EXTERN,
     LT_TEXTS      TYPE CVIS_EI_TEXT_T,
     LS_TEXTS      TYPE CVIS_EI_TEXT,
     LT_TLINE      TYPE TLINE_TAB,
     LS_TLINE      TYPE TLINE,
     LS_SALES      TYPE CMDS_EI_SALES,
     LT_SALES      TYPE CMDS_EI_SALES_T,
     LT_FUNCTIONS  TYPE CMDS_EI_FUNCTIONS_T,
     LS_FUNCTIONS  TYPE CMDS_EI_FUNCTIONS,
     LS_COMPANY    TYPE CMDS_EI_COMPANY,
     LT_COMPANY    TYPE CMDS_EI_COMPANY_T,
     LS_TAX_IND    TYPE CMDS_EI_TAX_IND,
     LT_TAX_IND    TYPE CMDS_EI_TAX_IND_T.
DATA:LS_DFKKBPTAXNUM    TYPE DFKKBPTAXNUM,
     FLAY_UPDATE,
     FLAY_UPDATE_CUSTOM.



* Create vendor
L_PARTNER = 'A0076-29'.

SELECT COUNT(*) FROM BUT000 WHERE PARTNER = L_PARTNER.
IF SY-SUBRC = 0.
  FLAY_UPDATE = 'X'.
ENDIF.

IF  FLAY_UPDATE = 'X'.
  LS_PARTNER-HEADER-OBJECT_TASK = 'U'.
  SELECT SINGLE PARTNER_GUID INTO  LV_GUID FROM BUT000 WHERE PARTNER = L_PARTNER.
ELSE.
  LS_PARTNER-HEADER-OBJECT_TASK = 'I'.
  CALL METHOD CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32
    RECEIVING
      UUID = LV_GUID.
ENDIF.
LS_PARTNER-HEADER-OBJECT_INSTANCE-BPARTNERGUID = LV_GUID.
LS_PARTNER-HEADER-OBJECT_INSTANCE-BPARTNER = L_PARTNER.
*--- Partner / Central data / common
LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CONTROL-CATEGORY = '2'.
LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-TITLE_KEY = '0003'.
*LS_PARTNER-CENTRAL_DATA-COMMN-DATA-BP_CONTROL-GROUPING = 'Z003'. "非生产性供应商
LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CONTROL-GROUPING = 'BP01'. "标准客户

LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-TITLELETTER = '问候111'.   "问候
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_CENTRALDATA-TITLELETTER = ABAP_TRUE.

LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-SEARCHTERM1 = L_PARTNER && 'sorch1'.
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_CENTRALDATA-SEARCHTERM1 = ABAP_TRUE.
LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-SEARCHTERM2 = L_PARTNER && 'sorch2'.
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_CENTRALDATA-SEARCHTERM2 = ABAP_TRUE.

LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_ORGANIZATION-NAME1 = L_PARTNER && 'naem1'.
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_ORGANIZATION-NAME1 = ABAP_TRUE.
LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_ORGANIZATION-NAME3 = L_PARTNER && 'naem3'.
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_ORGANIZATION-NAME3 = ABAP_TRUE.
LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_ORGANIZATION-NAME4 = L_PARTNER && 'naem4'.
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_ORGANIZATION-NAME4 = ABAP_TRUE.


LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_ORGANIZATION-FOUNDATIONDATE = SY-DATUM."记录建立日期
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_ORGANIZATION-FOUNDATIONDATE = ABAP_TRUE.



LS_PARTNER-CENTRAL_DATA-COMMON-DATA-BP_CENTRALDATA-CENTRALARCHIVINGFLAG = ''."归档标记
LS_PARTNER-CENTRAL_DATA-COMMON-DATAX-BP_CENTRALDATA-CENTRALARCHIVINGFLAG = ABAP_TRUE."归档标记



"税号(目前系统有问题，需要打Note)
*LS_TAXNUMBERS-TASK = 'I'.
*LS_TAXNUMBERS-DATA_KEY-TAXTYPE = 'CN0'.
*LS_TAXNUMBERS-DATA_KEY-TAXNUMBER  = 'SE556365974601'."税号
**LS_TAXNUMBERS-DATA_KEY-TAXNUMXL = 'SE556365974601'."税号
*APPEND LS_TAXNUMBERS TO LT_TAXNUMBERS.
*CLEAR:LS_TAXNUMBERS.
*LS_PARTNER-CENTRAL_DATA-TAXNUMBER-TAXNUMBERS = LT_TAXNUMBERS.
*REFRESH:LT_TAXNUMBERS.



IF  FLAY_UPDATE <> 'X'.
*  ------------------------------------------------------------------ddresses1
  LS_ADDRESSES-TASK = 'I'.
  LS_ADDRESSES-DATA_KEY-OPERATION = 'XXDFLT'.
  LS_ADDRESSES-CURRENTLY_VALID = ABAP_TRUE.
  "国家
  LS_ADDRESSES-DATA-POSTAL-DATA-COUNTRY = 'CN'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-COUNTRY = ABAP_TRUE.
  "城市
  LS_ADDRESSES-DATA-POSTAL-DATA-CITY = '北京'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-CITY = ABAP_TRUE.
  "邮编
  LS_ADDRESSES-DATA-POSTAL-DATA-POSTL_COD1 = '111111'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-POSTL_COD1 = ABAP_TRUE.
  "街道
  LS_ADDRESSES-DATA-POSTAL-DATA-STREET = '街道'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-STREET = ABAP_TRUE.
  "地区
  LS_ADDRESSES-DATA-POSTAL-DATA-REGION = '190'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-REGION = ABAP_TRUE.
  "语言
  LS_ADDRESSES-DATA-POSTAL-DATA-LANGU = '1'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-LANGU = ABAP_TRUE.



* phone
  LS_PHONE-CONTACT-DATA-R_3_USER = '1'. "电话
  LS_PHONE-CONTACT-DATAX-R_3_USER = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-TELEPHONE = '0711-123456789'."电话
  LS_PHONE-CONTACT-DATAX-TELEPHONE = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-STD_RECIP = 'X'.
  LS_PHONE-CONTACT-DATAX-STD_RECIP = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-EXTENSION =  '11111'."分机号
  LS_PHONE-CONTACT-DATAX-EXTENSION = ABAP_TRUE.

  "通讯链接注释
  LS_REMARKS-DATA-LANGU = '1'."语言
  LS_REMARKS-DATAX-LANGU = ABAP_TRUE."语言
  LS_REMARKS-DATA-LANGU_ISO = 'ZH'.
  LS_REMARKS-DATAX-LANGU_ISO = ABAP_TRUE.
  LS_REMARKS-DATA-COMM_NOTES = '通讯注释信息'.
  LS_REMARKS-DATAX-COMM_NOTES = ABAP_TRUE.
  APPEND LS_REMARKS TO LT_REMARKS.
  CLEAR:LS_REMARKS.
  LS_PHONE-REMARK-REMARKS = LT_REMARKS.
  APPEND LS_PHONE TO LT_PHONE.

  CLEAR LS_PHONE.
  LS_PHONE-CONTACT-DATA-R_3_USER = '2'."移动电话
  LS_PHONE-CONTACT-DATAX-R_3_USER = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-TELEPHONE = '13725491289'.
  LS_PHONE-CONTACT-DATAX-TELEPHONE = ABAP_TRUE.
  APPEND LS_PHONE TO LT_PHONE.
  CLEAR LS_PHONE.

  LS_ADDRESSES-DATA-COMMUNICATION-PHONE-PHONE = LT_PHONE.

* fax
  LS_FAX-CONTACT-DATA-FAX = '123444123'."传真
  LS_FAX-CONTACT-DATAX-FAX = ABAP_TRUE.
  LS_FAX-CONTACT-DATA-EXTENSION = '123123'."传真分机号
  LS_FAX-CONTACT-DATAX-EXTENSION = ABAP_TRUE.
  APPEND LS_FAX TO LT_FAX.
  LS_ADDRESSES-DATA-COMMUNICATION-FAX-FAX = LT_FAX.

* smtp
  LS_SMTP-CONTACT-DATA-E_MAIL = '123243412@162.COM'.
  LS_SMTP-CONTACT-DATAX-E_MAIL = ABAP_TRUE.
  APPEND LS_SMTP TO LT_SMTP.
  CLEAR LS_SMTP.
  LS_ADDRESSES-DATA-COMMUNICATION-SMTP-SMTP = LT_SMTP.

  APPEND LS_ADDRESSES TO LT_ADDRESSES.
  CLEAR:LS_ADDRESSES.
  REFRESH:LT_REMARKS,LT_PHONE.

*  ------------------------------------------------------------------ddresses1

*  ------------------------------------------------------------------ddresses2
  LS_ADDRESSES-TASK = 'I'.
  LS_ADDRESSES-DATA_KEY-OPERATION = 'HCM001'.
  LS_ADDRESSES-CURRENTLY_VALID = ABAP_TRUE.
  "国家
  LS_ADDRESSES-DATA-POSTAL-DATA-COUNTRY = 'CN'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-COUNTRY = ABAP_TRUE.
  "城市
  LS_ADDRESSES-DATA-POSTAL-DATA-CITY = '上海'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-CITY = ABAP_TRUE.
  "邮编
  LS_ADDRESSES-DATA-POSTAL-DATA-POSTL_COD1 = '123456'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-POSTL_COD1 = ABAP_TRUE.
  "街道
  LS_ADDRESSES-DATA-POSTAL-DATA-STREET = '上海街道'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-STREET = ABAP_TRUE.
  "地区
  LS_ADDRESSES-DATA-POSTAL-DATA-REGION = '010'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-REGION = ABAP_TRUE.
  "语言
  LS_ADDRESSES-DATA-POSTAL-DATA-LANGU = '1'.
  LS_ADDRESSES-DATA-POSTAL-DATAX-LANGU = ABAP_TRUE.



* phone
  LS_PHONE-CONTACT-DATA-R_3_USER = '1'. "电话
  LS_PHONE-CONTACT-DATAX-R_3_USER = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-TELEPHONE = '0711-123456789'."电话
  LS_PHONE-CONTACT-DATAX-TELEPHONE = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-STD_RECIP = 'X'.
  LS_PHONE-CONTACT-DATAX-STD_RECIP = ABAP_TRUE.
  LS_PHONE-CONTACT-DATA-EXTENSION =  '11111'."分机号
  LS_PHONE-CONTACT-DATAX-EXTENSION = ABAP_TRUE.

  "通讯链接注释
  LS_REMARKS-DATA-LANGU = '1'."语言
  LS_REMARKS-DATAX-LANGU = ABAP_TRUE."语言
  LS_REMARKS-DATA-LANGU_ISO = 'ZH'.
  LS_REMARKS-DATAX-LANGU_ISO = ABAP_TRUE.
  LS_REMARKS-DATA-COMM_NOTES = '通讯注释信息2'.
  LS_REMARKS-DATAX-COMM_NOTES = ABAP_TRUE.
  APPEND LS_REMARKS TO LT_REMARKS.
  CLEAR:LS_REMARKS.
  LS_PHONE-REMARK-REMARKS = LT_REMARKS.
  APPEND LS_PHONE TO LT_PHONE.

  LS_ADDRESSES-DATA-COMMUNICATION-PHONE-PHONE = LT_PHONE.
  APPEND LS_ADDRESSES TO LT_ADDRESSES.
  CLEAR:LS_ADDRESSES.
  REFRESH:LT_REMARKS,LT_PHONE.
*  ------------------------------------------------------------------ddresses2


  LS_PARTNER-CENTRAL_DATA-ADDRESS-ADDRESSES = LT_ADDRESSES.

** 银行数据信息
*SELECT COUNT(*) FROM BNKA WHERE BANKS = 'CN'
*      AND  BANKL = <FS_OUT>-BANKL.
*IF SY-SUBRC = 0.
  LS_BANKDETAILS-TASK = 'I'.
  LS_BANKDETAILS-DATA-BANK_CTRY = 'CN'.   "银行国家代码
  LS_BANKDETAILS-DATA-BANK_KEY = '0000000011'.    "银行代码
  LS_BANKDETAILS-DATA-BANK_ACCT = '银行账号'.  "银行帐户号码
  LS_BANKDETAILS-DATA-BANKACCOUNTNAME = '账号名称'."银行账号名称
  LS_BANKDETAILS-DATA-BANK_REF = '参考明细'.
  LS_BANKDETAILS-DATA-ACCOUNTHOLDER = '账号持有人'.   "账户持有人

  LS_BANKDETAILS-DATAX-BANK_CTRY = ABAP_TRUE.
  LS_BANKDETAILS-DATAX-BANK_KEY = ABAP_TRUE.
  LS_BANKDETAILS-DATAX-BANK_ACCT = ABAP_TRUE.
  LS_BANKDETAILS-DATAX-BANKACCOUNTNAME = ABAP_TRUE.
  LS_BANKDETAILS-DATAX-BANK_REF = ABAP_TRUE.
  LS_BANKDETAILS-DATAX-ACCOUNTHOLDER = ABAP_TRUE.
  APPEND LS_BANKDETAILS TO LT_BANKDETAILS.
  CLEAR: LS_BANKDETAILS.
  LS_PARTNER-CENTRAL_DATA-BANKDETAIL-BANKDETAILS = LT_BANKDETAILS.
ENDIF.
*ELSE.
*  L_BANK_CTRY = <FS_OUT>-BANKS.
*  L_BANK_KEY = <FS_OUT>-BANKL.
*  L_BANK_ADDRESS-BANK_NAME = <FS_OUT>-BANK_NAME.
*  CALL FUNCTION 'BAPI_BANK_CREATE'
*    EXPORTING
*      BANK_CTRY                    = L_BANK_CTRY
*      BANK_KEY                     = L_BANK_KEY
*      BANK_ADDRESS                 = L_BANK_ADDRESS
**     BANK_METHOD                  =
*
**     BANK_FORMATTING              =
*                                     *
*      BANK_ADDRESS1                =
*                                     *
*      I_XUPDATE                    = 'X'
*                                     *
*      I_CHECK_BEFORE_SAVE          =
*                                     *
*      BANK_IBAN_RULE               =
*                                     *
*      BANK_B2B_SUPPORTED           =
*                                     *
*      BANK_COR1_SUPPORTED          =
*                                     *
*      BANK_R_TRANSACTION_SUPPORTED =
*                                     *
*      BANK_INTERNAL_BANK           =
*                                     * IMPORTING
*                                     *
*      RETURN                       =
*                                     *
*      BANKCOUNTRY                  =
*                                     *
*      BANKKEY                      =.
*  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*    EXPORTING
*      WAIT = 'X'.
*  LS_BANKDETAILS-TASK = 'I'.
*  LS_BANKDETAILS-DATA-BANK_CTRY = <FS_OUT>-BANKS.   "银行国家代码
*  LS_BANKDETAILS-DATA-BANK_KEY = <FS_OUT>-BANKL.    "银行代码
*  LS_BANKDETAILS-DATA-BANK_ACCT = <FS_OUT>-ACCNAME+0(18).  "银行帐户号码
*  LS_BANKDETAILS-DATA-BANK_REF = <FS_OUT>-ACCNAME+18(20).
*  LS_BANKDETAILS-DATA-ACCOUNTHOLDER = <FS_OUT>-KOINH.   "账户持有人
*
*  LS_BANKDETAILS-DATAX-BANK_CTRY = ABAP_TRUE.
*  LS_BANKDETAILS-DATAX-BANK_KEY = ABAP_TRUE.
*  LS_BANKDETAILS-DATAX-BANK_ACCT = ABAP_TRUE.
*  LS_BANKDETAILS-DATAX-BANK_REF = ABAP_TRUE.
*  LS_BANKDETAILS-DATAX-ACCOUNTHOLDER = ABAP_TRUE.
*  APPEND LS_BANKDETAILS TO LT_BANKDETAILS.
*  CLEAR: LS_BANKDETAILS.
*  LS_PARTNER-CENTRAL_DATA-BANKDETAIL-BANKDETAILS = LT_BANKDETAILS.
*ENDIF.



*  供应商中心数据
*LS_VENDOR-HEADER-OBJECT_TASK = 'I'.
*LS_VENDOR-HEADER-OBJECT_INSTANCE-LIFNR =  L_PARTNER.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-NAME = 'asdfasarda'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-NAME = ABAP_TRUE.
*
*"搜索项
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-SORT1 = 'SORT1'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-SORT1 = ABAP_TRUE.
*"国家
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-COUNTRY = 'CN'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-COUNTRY = ABAP_TRUE.
*"城市
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-CITY = '北京'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-CITY = ABAP_TRUE.
*"邮编
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-POSTL_COD1 = '12323123'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-POSTL_COD1 = ABAP_TRUE.
*"街道
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-STREET = 'asdasd'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-STREET = ABAP_TRUE.
*"地区
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-REGION = '190'.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-REGION = ABAP_TRUE.
*"语言
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATA-LANGU = SY-LANGU.
*LS_VENDOR-CENTRAL_DATA-ADDRESS-POSTAL-DATAX-LANGU = ABAP_TRUE.

"税号
*LS_VENDOR-CENTRAL_DATA-CENTRAL-DATA-STENR = 'asdfasdasdasdf'.
*LS_VENDOR-CENTRAL_DATA-CENTRAL-DATAX-STENR = ABAP_TRUE.

"---------------------------------------------------------------------------财务试图
SELECT COUNT(*) FROM KNA1 WHERE KUNNR = L_PARTNER.
IF SY-SUBRC = 0.
  FLAY_UPDATE_CUSTOM = 'X'.
  LS_CUSTOMER-HEADER-OBJECT_TASK = 'U'.
ELSE.
  LS_CUSTOMER-HEADER-OBJECT_TASK = 'I'.

  "-------------------------------------------角色
  LS_ROLE-TASK     = 'I'.
*LS_ROLE-DATA_KEY = 'FLVN00'.
*LS_ROLE-DATA-ROLECATEGORY = 'FLVN00'.
  LS_ROLE-DATA_KEY = 'FLCU00'.
  LS_ROLE-DATA-ROLECATEGORY = 'FLCU00'.
  LS_ROLE-DATA-VALID_FROM = SY-DATUM.
  LS_ROLE-DATA-VALID_TO = '99991231'.
  LS_ROLE-CURRENTLY_VALID = ABAP_TRUE.
  LS_ROLE-DATAX-VALID_FROM = ABAP_TRUE.
  LS_ROLE-DATAX-VALID_TO = ABAP_TRUE.
  APPEND LS_ROLE TO LT_ROLE.
  CLEAR LS_ROLE.
  LS_PARTNER-CENTRAL_DATA-ROLE-ROLES = LT_ROLE.

  LS_ROLE-TASK     = 'I'.
*LS_ROLE-DATA_KEY = 'FLVN01'.
*LS_ROLE-DATA-ROLECATEGORY = 'FLVN01'.
  LS_ROLE-DATA_KEY = 'FLCU01'.
  LS_ROLE-DATA-ROLECATEGORY = 'FLCU01'.
  LS_ROLE-DATA-VALID_FROM = SY-DATUM.
  LS_ROLE-DATA-VALID_TO = '99991231'.
  LS_ROLE-CURRENTLY_VALID = ABAP_TRUE.
  LS_ROLE-DATAX-VALID_FROM = ABAP_TRUE.
  LS_ROLE-DATAX-VALID_TO = ABAP_TRUE.
  APPEND LS_ROLE TO LT_ROLE.
  CLEAR LS_ROLE.
  LS_PARTNER-CENTRAL_DATA-ROLE-ROLES = LT_ROLE.
ENDIF.




LS_CUSTOMER-HEADER-OBJECT_INSTANCE-KUNNR = L_PARTNER."客户编号


LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-BEGRU = 'A011' ."权限组
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-NIELS = '01' ."尼尔森标识
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-KUKLA = '01' ."客户分类
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-KONZS = 'B1000' ."组代码
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATA-BRAN1 = 'Z001'."行业代码



LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-BEGRU = ABAP_TRUE ."权限组
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-NIELS = ABAP_TRUE ."尼尔森标识
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-KUKLA = ABAP_TRUE ."客户分类
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-KONZS = ABAP_TRUE ."组代码
LS_CUSTOMER-CENTRAL_DATA-CENTRAL-DATAX-BRAN1 = ABAP_TRUE."行业代码


IF FLAY_UPDATE_CUSTOM <> 'X'.
  LS_TEXTS-DATA_KEY-TEXT_ID = '0001'.
  LS_TEXTS-DATA_KEY-LANGU = '1'.
  LS_TEXTS-DATA_KEY-LANGUISO = 'ZH'.

  LS_TLINE-TDFORMAT = '/'.
  LS_TLINE-TDLINE = '客户特殊要求-通用'.
  APPEND LS_TLINE TO LT_TLINE.
  CLEAR:LS_TLINE.
  LS_TEXTS-DATA = LT_TLINE.
  APPEND LS_TEXTS TO LT_TEXTS.
  CLEAR:LS_TEXTS,LT_TLINE[].

  LS_TEXTS-DATA_KEY-TEXT_ID = '0002'.
  LS_TEXTS-DATA_KEY-LANGU = '1'.
  LS_TEXTS-DATA_KEY-LANGUISO = 'ZH'.

  LS_TLINE-TDFORMAT = '/'.
  LS_TLINE-TDLINE = '物流文本'.
  APPEND LS_TLINE TO LT_TLINE.
  CLEAR:LS_TLINE.
  LS_TEXTS-DATA = LT_TLINE.
  APPEND LS_TEXTS TO LT_TEXTS.
  CLEAR:LS_TEXTS,LT_TLINE[].


  LS_TEXTS-DATA_KEY-TEXT_ID = '0003'.
  LS_TEXTS-DATA_KEY-LANGU = '1'.
  LS_TEXTS-DATA_KEY-LANGUISO = 'ZH'.

  LS_TLINE-TDFORMAT = '/'.
  LS_TLINE-TDLINE = '物流文本111'.
  APPEND LS_TLINE TO LT_TLINE.
  CLEAR:LS_TLINE.
  LS_TEXTS-DATA = LT_TLINE.
  APPEND LS_TEXTS TO LT_TEXTS.
  CLEAR:LS_TEXTS,LT_TLINE[].

  LS_CUSTOMER-CENTRAL_DATA-TEXT-TEXTS = LT_TEXTS."销售文本
  REFRESH:LT_TEXTS,LT_TEXTS.

ENDIF.


LS_TAX_IND-TASK = 'M'.
LS_TAX_IND-DATA_KEY-ALAND = 'CN'.
LS_TAX_IND-DATA_KEY-TATYP = 'MWST'."销项税

LS_TAX_IND-DATA-TAXKD = '1'."税分类
LS_TAX_IND-DATAX-TAXKD = ABAP_TRUE."税分类
APPEND LS_TAX_IND TO LT_TAX_IND.
CLEAR:LS_TAX_IND.
LS_CUSTOMER-CENTRAL_DATA-TAX_IND-TAX_IND = LT_TAX_IND.
REFRESH:LT_TAX_IND.

*"---------------------------------------------------------------------------销售试图


LS_SALES-TASK = 'M'.
LS_SALES-DATA_KEY-VKORG = '1100'."销售组织
LS_SALES-DATA_KEY-VTWEG = '10'."销售组织
LS_SALES-DATA_KEY-SPART = '00'."销售产品组

LS_SALES-DATA-BZIRK = 'AS10'."销售区域
LS_SALES-DATA-KDGRP = '10'."客户组
LS_SALES-DATA-VKBUR = '1010'."销售部门
LS_SALES-DATA-VKGRP = 'M01'."销售组
LS_SALES-DATA-EIKTO = '7890'."客户处我方账号
LS_SALES-DATA-WAERS = 'CNY'."货币
LS_SALES-DATA-KALKS = '2'."定价过程
LS_SALES-DATA-KZAZU = 'X'."订单组合----------------------------------------------------------------------
LS_SALES-DATA-VWERK = '1101'."交货工厂
LS_SALES-DATA-VSBED = '01'."装运条件
LS_SALES-DATA-INCO1 = 'EXW'."国际贸易条款
LS_SALES-DATA-INCO2_L = 'Eindhoven'."国际贸易条款位置1
LS_SALES-DATA-ZTERM = 'Z001'."付款条款
LS_SALES-DATA-KTGRD = '01'."客户科目主分配

LS_SALES-DATAX-BZIRK = ABAP_TRUE."销售区域
LS_SALES-DATAX-KDGRP = ABAP_TRUE."客户组
LS_SALES-DATAX-VKBUR = ABAP_TRUE."销售部门
LS_SALES-DATAX-VKGRP = ABAP_TRUE."销售组
LS_SALES-DATAX-EIKTO = ABAP_TRUE."客户处我方账号
LS_SALES-DATAX-WAERS = ABAP_TRUE."货币
LS_SALES-DATAX-KALKS = ABAP_TRUE."定价过程
LS_SALES-DATAX-KZAZU = ABAP_TRUE."订单组合
LS_SALES-DATAX-VWERK = ABAP_TRUE."交货工厂
LS_SALES-DATAX-VSBED = ABAP_TRUE."装运条件
LS_SALES-DATAX-INCO1 = ABAP_TRUE."国际贸易条款
LS_SALES-DATAX-INCO2_L = ABAP_TRUE."国际贸易条款位置1
LS_SALES-DATAX-ZTERM = ABAP_TRUE."付款条款
LS_SALES-DATAX-KTGRD = ABAP_TRUE."客户科目主分配

"---------------------送达方
LS_FUNCTIONS-DATA_KEY-PARVW = 'WE'."合作伙功能

LS_FUNCTIONS-DATA-DEFPA = 'X'."缺省的合作伙伴
LS_FUNCTIONS-DATA-PARTNER = L_PARTNER."合作伙伴编号

LS_FUNCTIONS-DATAX-DEFPA = ABAP_TRUE."缺省的合作伙伴
LS_FUNCTIONS-DATAX-PARTNER = ABAP_TRUE."合作伙伴编号
APPEND LS_FUNCTIONS TO LT_FUNCTIONS.
CLEAR:LS_FUNCTIONS.


"---------------------收票方
LS_FUNCTIONS-DATA_KEY-PARVW = 'RE'."合作伙功能

LS_FUNCTIONS-DATA-PARTNER = L_PARTNER."合作伙伴编号

LS_FUNCTIONS-DATAX-PARTNER = ABAP_TRUE."合作伙伴编号
APPEND LS_FUNCTIONS TO LT_FUNCTIONS.
CLEAR:LS_FUNCTIONS.

"---------------------付款方
LS_FUNCTIONS-DATA_KEY-PARVW = 'RG'."合作伙功能

LS_FUNCTIONS-DATA-PARTNER = L_PARTNER."合作伙伴编号

LS_FUNCTIONS-DATAX-PARTNER = ABAP_TRUE."合作伙伴编号
APPEND LS_FUNCTIONS TO LT_FUNCTIONS.
CLEAR:LS_FUNCTIONS.


"---------------------售达方
LS_FUNCTIONS-DATA_KEY-PARVW = 'AG'."合作伙功能

LS_FUNCTIONS-DATA-PARTNER = L_PARTNER."合作伙伴编号

LS_FUNCTIONS-DATAX-PARTNER = ABAP_TRUE."合作伙伴编号
APPEND LS_FUNCTIONS TO LT_FUNCTIONS.
CLEAR:LS_FUNCTIONS.

"--------------------- 业务员
LS_FUNCTIONS-DATA_KEY-PARVW = 'VE'."合作伙功能

LS_FUNCTIONS-DATA-PARTNER = '0000060051'."合作伙伴编号

LS_FUNCTIONS-DATAX-PARTNER = ABAP_TRUE."合作伙伴编号
APPEND LS_FUNCTIONS TO LT_FUNCTIONS.
CLEAR:LS_FUNCTIONS.

LS_SALES-FUNCTIONS-FUNCTIONS = LT_FUNCTIONS.
APPEND LS_SALES TO LT_SALES.
REFRESH LT_FUNCTIONS.


CLEAR:LS_SALES.
LS_CUSTOMER-SALES_DATA-SALES = LT_SALES.
REFRESH:LT_SALES.
*
*"------------------------------------------------------------公司代码
LS_COMPANY-TASK = 'M'.
LS_COMPANY-DATA_KEY-BUKRS = '1100'.
LS_COMPANY-DATA-AKONT = '1122010000'."统驭科目
LS_COMPANY-DATA-ZTERM = 'Z001'."付款条款
LS_COMPANY-DATA-ZWELS = 'C'."付款方式

LS_COMPANY-DATAX-AKONT = ABAP_TRUE."统驭科目
LS_COMPANY-DATAX-ZTERM = ABAP_TRUE."付款条款
LS_COMPANY-DATAX-ZWELS = ABAP_TRUE."付款方式
APPEND LS_COMPANY TO LT_COMPANY.
CLEAR LS_COMPANY.

LS_CUSTOMER-COMPANY_DATA-COMPANY = LT_COMPANY.
REFRESH:LT_COMPANY.

LS_DATA-PARTNER = LS_PARTNER.
LS_DATA-VENDOR = LS_VENDOR.
LS_DATA-CUSTOMER = LS_CUSTOMER.
APPEND LS_DATA TO LT_DATA.


*SET UPDATE TASK LOCAL.
CL_MD_BP_MAINTAIN=>MAINTAIN(
 EXPORTING
   I_DATA   = LT_DATA
 IMPORTING
   E_RETURN = LT_RETURN ).

LOOP AT LT_RETURN INTO LS_RETURN.
  LOOP AT LS_RETURN-OBJECT_MSG INTO LS_MSG WHERE TYPE = 'E' OR TYPE = 'A'.
    "CONCATENATE LV_MSG1 LS_MSG-MESSAGE INTO LV_MSG1.
  ENDLOOP.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDLOOP.
IF SY-SUBRC <> 0.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDIF.

LS_DFKKBPTAXNUM-PARTNER = L_PARTNER.
LS_DFKKBPTAXNUM-TAXTYPE = 'CN0'.
LS_DFKKBPTAXNUM-TAXNUM  = 'SE556365974601'.
MODIFY DFKKBPTAXNUM FROM LS_DFKKBPTAXNUM.
CLEAR LS_DFKKBPTAXNUM.
IF SY-SUBRC = 0.
  COMMIT WORK.
ENDIF.