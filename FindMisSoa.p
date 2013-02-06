FOR EACH so_mstr NO-LOCK. 
    FIND FIRST so_mstr_a WHERE sls_ord = so_nbr NO-LOCK NO-ERROR. 
    IF NOT AVAILABLE so_mstr_a THEN
        DISPLAY so_nbr.
END.
