
DEF STREAM s-so_mstr.
DEF STREAM s-sod_det.
DEF STREAM s-sod_det_a .
DEF STREAM s-so_mstr_a .

OUTPUT STREAM s-so_mstr TO c:\temp\so_mstr.txt .
OUTPUT STREAM s-so_mstr_a TO c:\temp\so_mstr_a.txt .
OUTPUT STREAM s-sod_det TO c:\temp\so_det.txt .
OUTPUT STREAM s-sod_det_a TO c:\temp\so_det_a.txt .

FOR EACH so_mstr_a NO-LOCK WHERE shiptec .
    FOR EACH sod_det NO-LOCK WHERE sod_nbr = sls_ord AND sod_domain = "qp".
        EXPORT STREAM s-sod_det sod_det.
    END.
    FOR EACH so_mstr NO-LOCK WHERE so_nbr = sls_ord AND  so_domain = "qp" .
        EXPORT STREAM s-so_mstr so_mstr .
    END.
    FOR EACH sod_det_a NO-LOCK WHERE sod_det_a.sls_ord = so_mstr_a.sls_ord  .
        EXPORT STREAM s-sod_det_a sod_det_a .
    END.

    EXPORT STREAM s-so_mstr_a  so_mstr_a.
END.
