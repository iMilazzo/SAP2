*&---------------------------------------------------------------------*
*& Report zim_consume_cds_param
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zim_consume_cds_param.


DATA: p_curr TYPE sflight-currency.

cl_demo_input=>new(  )->add_field( CHANGING field = p_curr )->request(  ).

SELECT * FROM zcds_view_param( in_curr = @p_curr ) INTO TABLE @DATA(tl_sflight).

cl_demo_output=>display( tl_sflight ).