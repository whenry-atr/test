default-window:width = 135.
                   
FOR EACH ptp_det WHERE ptp_domain = "qp" AND ptp_pm_code = "m" AND
   ( ptp_mfg_lead <> 0  /*OR ptp_part = "10099" */ ) AND ptp_site = "02" NO-LOCK .       
    FIND FIRST pt_mstr NO-LOCK WHERE pt_part = ptp_part . 
    IF pt_status <> "active" THEN NEXT .
    IF pt_desc1 BEGINS "kit" THEN NEXT .
    DISPLAY pt_part ptp_mfg_lead pt_desc1 pt_status ptp_mod_date (COUNT).
    
END.


