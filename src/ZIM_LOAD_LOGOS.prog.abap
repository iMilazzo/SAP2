*&---------------------------------------------------------------------*
*& Report zim_load_logos
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zim_load_logos.

DATA : IT_PHOTO TYPE   ZTEST_PHOTO_T,
       WA_PHOTO TYPE   ZTEST_PHOTO_S.

DATA   : WA_ZTEST_PHOTO TYPE ZTEST_PHOTO,
         IT_ZTEST_PHOTO TYPE TABLE OF ZTEST_PHOTO.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS : S_PERNR FOR WA_ZTEST_PHOTO-PERNR NO INTERVALS .
PARAMETERS     : P_PRINT TYPE CHAR1 RADIOBUTTON GROUP RDA1 DEFAULT 'X' USER-COMMAND COM,
               P_UPLOAD TYPE CHAR1 RADIOBUTTON GROUP RDA1.
SELECTION-SCREEN end OF BLOCK b1.

IF P_PRINT IS NOT INITIAL.

* selecting the data from the table..
  SELECT PERNR PHOTO FROM  ZTEST_PHOTO INTO CORRESPONDING FIELDS OF TABLE IT_ZTEST_PHOTO
                         WHERE PERNR IN  S_PERNR .
  LOOP AT IT_ZTEST_PHOTO INTO WA_ZTEST_PHOTO.
    WA_PHOTO-PERNR = WA_ZTEST_PHOTO-PERNR.
    WA_PHOTO-PHOTO = WA_ZTEST_PHOTO-PHOTO.
    APPEND WA_PHOTO TO IT_PHOTO.
  ENDLOOP.

  DATA :FP_OUTPUTPARAMS   TYPE SFPOUTPUTPARAMS.

  FP_OUTPUTPARAMS-NODIALOG = 'X'. "'X'.
  FP_OUTPUTPARAMS-PREVIEW  = 'X'. "'X'.
*  fp_docparams-FILLABLE    = 'N'.
*fp_outputparams-DEVICE   = 'ZLOCA'.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      IE_OUTPUTPARAMS = FP_OUTPUTPARAMS
    EXCEPTIONS
      CANCEL          = 1
      USAGE_ERROR     = 2
      SYSTEM_ERROR    = 3
      INTERNAL_ERROR  = 4
      OTHERS          = 5.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION '/1BCDWB/SM00000027'
   EXPORTING
*   /1BCDWB/DOCPARAMS        =
      IT_PHOTO                 =  IT_PHOTO
* IMPORTING
*   /1BCDWB/FORMOUTPUT       =
* EXCEPTIONS
*   USAGE_ERROR              = 1
*   SYSTEM_ERROR             = 2
*   INTERNAL_ERROR           = 3
*   OTHERS                   = 4
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'FP_JOB_CLOSE'
*   IMPORTING
*     E_RESULT             =
      EXCEPTIONS
        USAGE_ERROR           = 1
        SYSTEM_ERROR          = 2
        INTERNAL_ERROR        = 3
        OTHERS                = 4.
  IF SY-SUBRC <> 0.

  ENDIF.
ELSE.
  DATA: LR_MIME_REP TYPE REF TO IF_MR_API.

  DATA: LV_FILENAME TYPE STRING.
  DATA: LV_PATH     TYPE STRING.
  DATA: LV_FULLPATH TYPE STRING.
  DATA: LV_CONTENT  TYPE XSTRING.
  DATA: LV_LENGTH   TYPE  I.
  DATA: LV_RC TYPE SY-SUBRC.

  DATA: LT_FILE TYPE FILETABLE.
  DATA: LS_FILE LIKE LINE OF LT_FILE.


  DATA: LT_DATA TYPE STANDARD TABLE OF X255.


  CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG(
    CHANGING
      FILE_TABLE              =  LT_FILE  " Table Holding Selected Files
      RC                      =  LV_RC  ). " Return Code, Number of Files or -1 If Error Occurred
  READ TABLE LT_FILE INTO LS_FILE INDEX 1.
  IF SY-SUBRC = 0.
    LV_FILENAME = LS_FILE-FILENAME.
  ENDIF.

  CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD(
    EXPORTING
      FILENAME                = LV_FILENAME    " Name of file
      FILETYPE                = 'BIN'
    IMPORTING
      FILELENGTH              =  LV_LENGTH   " File length
    CHANGING
      DATA_TAB                = LT_DATA    " Transfer table for file contents
    EXCEPTIONS
      OTHERS                  = 19 ).


  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      INPUT_LENGTH = LV_LENGTH
*    first_line   = 0
*    last_line    = 0
    IMPORTING
      BUFFER       = LV_CONTENT
    TABLES
      BINARY_TAB   = LT_DATA
    EXCEPTIONS
      FAILED       = 1
      OTHERS       = 2.

  WA_ZTEST_PHOTO-PERNR = S_PERNR-low.
  WA_ZTEST_PHOTO-PHOTO =  LV_CONTENT.

  MODIFY ZTEST_PHOTO FROM WA_ZTEST_PHOTO .

  if sy-subrc = 0.
   MESSAGE 'Successfully Uploaded' TYPE 'I' DISPLAY LIKE 'S'.
   ENDIF.
ENDIF.