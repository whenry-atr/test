DEFINE BUFFER pimstr FOR pi_mstr . 
default-window:width = 135.
DEF VAR v_count AS INTEGER.

DEFINE STREAM s-out .
OUTPUT STREAM s-out TO c:\temp\pi_dups.txt .

FOR EACH pi_mstr WHERE pi_list = "h-list" AND pi_cs_code = "h-custs" 
    AND pi_amt_type = "1" NO-LOCK. 
    v_count = v_count + 1 . 
    IF v_count MOD 300 = 0  THEN DISPLAY v_count WITH DOWN.  PAUSE 0 .
    FOR EACH pimstr WHERE pimstr.pi_domain = "qp" AND
        pi_mstr.pi_list  = pimstr.pi_list AND pi_mstr.pi_cs_code = pimstr.pi_cs_code
        AND pimstr.pi_part_code = pi_mstr.pi_part_code AND pi_part_Type = "6"
        AND RECID(pimstr) <> RECID(pi_mstr)  .
       EXPORT STREAM s-out pimstr.pi_list pimstr.pi_cs_code 
           pimstr.pi_part_code pimstr.pi_start pimstr.pi_expire .   
    END.
END.
