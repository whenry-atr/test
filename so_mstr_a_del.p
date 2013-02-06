DEF VAR v_cnt AS INTEGER .


OUTPUT TO c:\temp\so_mstr_a_del.d .

FOR EACH so_mstr_a .
    FIND FIRST so_mstr NO-LOCK WHERE sls_ord = so_nbr 
        AND so_domain = "qp" NO-ERROR. 

    IF AVAILABLE so_mstr  THEN NEXT .

    EXPORT so_mstr_a . 

    DELETE so_mstr_a .

END.
