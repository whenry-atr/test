
OUTPUT TO c:\temp\bob-price2.txt .
EXPORT DELIMITER "," "Part" "First Date Received" .


FOR EACH pt_mstr NO-LOCK WHERE pt_domain = "qp" 
    AND pt_pm_code = "p" .
   
    FIND FIRST tr_hist NO-LOCK WHERE tr_domain = "qp" AND tr_type = "rct-po" 
        AND tr_effdate > 1/1/2008 AND tr_part = pt_part 
        USE-INDEX tr_part_eff  NO-ERROR.
    IF NOT AVAILABLE tr_hist THEN NEXT .
    

    EXPORT DELIMITER ","
        pt_part tr_effdate.

END.

