DEF VAR v_count AS INTEGER. 
DEF STREAM s-out.
OUTPUT STREAM s-out TO c:\temp\so_mstr_del.txt .

FOR EACH so_mstr_a NO-LOCK. 
    FIND FIRST so_mstr NO-LOCK WHERE so_nbr = sls_ord AND
        so_domain = "qp" NO-ERROR.
    IF NOT AVAILABLE so_mstr THEN do:
        v_count = v_count + 1.
    END. 
  
END.

  DISPLAY v_count.
