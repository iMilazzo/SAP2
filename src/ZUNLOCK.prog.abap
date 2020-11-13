*&---------------------------------------------------------------------*
*& Report zunlock
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zunlock.

UPDATE usr02 CLIENT SPECIFIED SET locnt = 0 uflag = 0 WHERE mandt = '400' AND bname = 'CONS_SD_17'.

IF sy-subrc EQ 0.

  WRITE: / 'no of records updated ',sy-dbcnt.
  COMMIT WORK.

ENDIF.