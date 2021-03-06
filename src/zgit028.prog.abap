*&---------------------------------------------------------------------*
*& Report ZGIT028
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT028.
DATA: JSON_SER TYPE REF TO CL_TREX_JSON_SERIALIZER,
      JSON_DES TYPE REF TO CL_TREX_JSON_DESERIALIZER.
DATA: JSONSTR TYPE STRING.
DATA: BEGIN OF ITAB OCCURS 0,
        MATNR LIKE MAKT-MATNR,
        MAKTX LIKE MAKT-MAKTX,
      END OF ITAB.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ITAB
    FROM MAKT UP TO 10 ROWS.


***内表->JSON
  CREATE OBJECT JSON_SER
    EXPORTING
      DATA = ITAB[].
  CALL METHOD JSON_SER->SERIALIZE.
  CALL METHOD JSON_SER->GET_DATA
    RECEIVING
      RVAL = JSONSTR.

  WRITE: JSONSTR.

***JSON->内表
  CREATE OBJECT JSON_DES.
  CALL METHOD JSON_DES->DESERIALIZE
    EXPORTING
      JSON = JSONSTR
    IMPORTING
      ABAP = ITAB[].
