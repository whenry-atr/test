DEF VARIABLE v_count AS INTEGER. 
DEFINE STREAM s-out.
OUTPUT STREAM s-out TO c:\so_mstr_a.txt APPEND. 


FOR EACH so_mstr_a .
    FIND FIRST so_mstr NO-LOCK WHERE so_nbr = sls_ord AND so_domain = "qp" 
        NO-ERROR .
    IF NOT AVAILABLE so_mstr THEN DO:
        EXPORT STREAM s-out so_mstr_a .
        v_count = v_count + 1 . 
        DISPLAY v_count sls_ord . PAUSE 0 .
        DELETE so_mstr_a.   
        IF v_count = 5000 THEN QUIT .
    END.
   
END.


DISPLAY v_count .
