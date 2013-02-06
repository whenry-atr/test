default-window:width = 135.
OUTPUT TO c:\temp\fix-sod-frt-class.txt .
EXPORT DELIMITER "," "Order#" "Part" "Ord Line" "prev fr class" "new fr class" .

DISABLE TRIGGERS FOR LOAD OF sod_det .
FOR EACH sod_det . 
    FIND pt_mstr NO-LOCK WHERE pt_domain = "qp" AND pt_part = sod_part 
        NO-ERROR . 
    IF NOT AVAILABLE pt_mstr THEN NEXT . 
    IF sod_fr_class <> pt_fr_class  THEN DO:
        EXPORT DELIMITER "," sod_nbr sod_part sod_line sod_fr_class pt_fr_class.
/*         sod_fr_class = pt_fr_class . */
    END.
        
END.
