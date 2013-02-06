default-window:width = 135.

DEF STREAM s-out. 

OUTPUT STREAM s-out TO c:\temp\bob-first-use.txt .

EXPORT STREAM s-out DELIMITER "," 
    "Part"
    "Description"
    "Date Added"
    "Transaction Type"
    "Quantity"
    "Date" .

FOR EACH pt_mstr NO-LOCK WHERE pt_add >= 9/1/09 AND pt_add <= 7/31/11.

    FOR EACH tr_hist NO-LOCK WHERE
            tr_domain = "qp" 
            AND pt_part = tr_part 
            AND tr_site <> "32" 
            AND  tr_qty_chg <> 0
            USE-INDEX tr_part_eff . 

        IF AVAILABLE tr_hist THEN LEAVE .
    END.
                      
   EXPORT STREAM s-out DELIMITER "," 
        pt_part pt_desc1 pt_add 
        tr_type   WHEN AVAILABLE tr_hist
        ""      WHEN NOT AVAILABLE tr_hist
        tr_qty_chg  WHEN AVAILABLE tr_hist
        ""      WHEN NOT AVAILABLE tr_hist
        tr_effdate   WHEN AVAILABLE tr_hist
        "?"      WHEN NOT AVAILABLE tr_hist  . 


END. 
