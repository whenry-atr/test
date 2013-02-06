
DEF STREAM s-so_mstr.
DEF STREAM s-sod_det.
DEF STREAM s-sod_det_a .
DEF STREAM s-so_mstr_a .

INPUT STREAM s-so_mstr  FROM c:\temp\so_mstr.txt .
INPUT STREAM s-so_mstr_a FROM c:\temp\so_mstr_a.txt .
INPUT STREAM s-sod_det FROM c:\temp\so_det.txt .
INPUT STREAM s-sod_det_a FROM c:\temp\so_det_a.txt .
             
DISABLE TRIGGERS FOR LOAD OF sod_det.
DISABLE TRIGGERS FOR LOAD OF so_mstr. 

REPEAT TRANSACTION:
    CREATE so_mstr .
    IMPORT STREAM s-so_mstr so_mstr .
    IF so_nbr = "" THEN DELETE so_mstr.
END.

REPEAT TRANSACTION:
    CREATE so_mstr_a .
    IMPORT STREAM s-so_mstr_a so_mstr_a NO-ERROR .
    IF sls_ord = "" THEN DELETE so_mstr_a.
END.

REPEAT TRANSACTION:
    CREATE sod_det .
    IMPORT STREAM s-sod_det sod_det NO-ERROR .
    IF sod_nbr = "" THEN DELETE sod_det.
END.

REPEAT TRANSACTION:
    CREATE sod_det_a .
    IMPORT STREAM s-sod_det_a sod_det_a NO-ERROR .
    IF sod_det_a.sls_ord  = "" THEN DELETE sod_det_a .
END.
