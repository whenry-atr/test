DEF VAR v_cnt AS INTEGER .
DEF VAR v_time AS INTEGER .

v_time = TIME .

DEFINE STREAM s-out .
OUTPUT STREAM s-out TO c:\temp\sod_det_a_del.d.


FOR EACH sod_det_a NO-LOCK .
    IF CAN-FIND( FIRST so_mstr NO-LOCK WHERE sls_ord = so_nbr
        AND so_domain = "qp") THEN NEXT .

    v_cnt = v_cnt + 1 .

    EXPORT STREAM s-out sod_det_a .

/*     DELETE sod_det_a .             */


    IF v_cnt MOD 2000 = 0 THEN DISPLAY v_cnt . PAUSE 0 .

END.

DISPLAY v_cnt (TIME - v_time) . 
