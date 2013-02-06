default-window:width = 135.

DEF VAR v_cnt AS INTEGER.
DEF VAR v_rec_cnt AS INTEGER.

DEFINE TEMP-TABLE t-for LIKE fcs_sum .

DEF STREAM s-del.
OUTPUT STREAM s-del TO c:\temp\fcs-del.txt .
DEF STREAM s-chg.
OUTPUT STREAM s-chg TO c:\temp\fcs-chg.txt .

DISABLE TRIGGERS FOR LOAD OF fcs_sum . 


INPUT FROM c:\temp\fcs_sum.txt .

REPEAT:
    CREATE t-for.
    IMPORT t-for .
END.




FOR EACH fcs_sum WHERE fcs_domain = "qp" 
    AND (fcs_year = 2011  OR fcs_year = 2012):

    v_rec_cnt = v_rec_cnt + 1 .

    DISPLAY v_rec_cnt fcs_part fcs_year fcs_site. PAUSE 0 .

    FIND FIRST t-for WHERE t-for.fcs_domain = "qp" AND
        t-for.fcs_site = fcs_sum.fcs_site AND
        t-for.fcs_part = fcs_sum.fcs_part AND
        t-for.fcs_year = fcs_sum.fcs_year NO-LOCK NO-ERROR.
    IF NOT AVAILABLE t-for  THEN DO:
        EXPORT STREAM s-del fcs_sum.
        delete fcs_sum .
    END.
    ELSE DO:
        EXPORT STREAM s-chg fcs_sum .
        DO v_cnt = 1 TO 52 .
            fcs_sum.fcs_fcst_qty[v_cnt] = t-for.fcs_fcst_qty[v_cnt] .
        END.
    END.
END.
