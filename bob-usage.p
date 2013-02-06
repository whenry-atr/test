DEF VAR v_time AS INTEGER.

DEF TEMP-TABLE t-hist
    FIELD part LIKE tr_part
    FIELD qty LIKE tr_qty_chg
    FIELD dte LIKE tr_effdate 
    INDEX dte dte .
                       
v_time = TIME .
FOR EACH tr_hist NO-LOCK WHERE
    tr_domain = "qp" AND (tr_type = "iss-wo"  OR tr_type = "iss-so" )
     AND ( tr_site = "02" OR tr_site = "03" )
     AND tr_effdate >= 1/1/10 .
    CREATE t-hist .
    ASSIGN 
        part = tr_part
        qty  = tr_qty_chg
        dte  = tr_effdate .

END.

DISPLAY TIME - v_time . 
