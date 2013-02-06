default-window:width = 135.
FOR EACH so_mstr_a WHERE shiptec no-lock.
    FIND FIRST so_mstr WHERE so_nbr = sls_ord AND so_domain = "qp" NO-ERROR .
    IF NOT AVAILABLE so_mstr THEN NEXT. 
    IF so_rmks <> 'web'  THEN NEXT .
    DISPLAY ord_entry_mthd so_rmks so_nbr so_fr_terms WITH WIDTH 132.
END.

