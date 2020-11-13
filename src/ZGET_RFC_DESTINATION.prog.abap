*&---------------------------------------------------------------------*
*& Report zget_rfc_destination
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zget_rfc_destination.

DATA lo_destination_finder TYPE REF TO /iwbep/if_destin_finder.

DATA lo_dp_facade TYPE REF TO /iwbep/if_mgw_dp_int_facade.

DATA lv_destination TYPE rfcdest.

* Get RFC destination

lo_dp_facade         ?= /iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).

lo_destination_finder = lo_dp_facade->get_destination_finder( ).

lv_destination        = lo_destination_finder->get_rfc_destination_via_rout( ).