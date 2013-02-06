OUTPUT TO c:\temp\ord-qty-list.txt .
EXPORT DELIMITER "," "Part" "Description" "Order Qty" 
    "Rounting run Time" "Mfg Lead Time" "Item Site Detail Flag" .

FOR EACH pt_mstr WHERE  pt_status = "active" NO-LOCK .
    FIND FIRST ptp_det WHERE ptp_part = pt_part AND pt_domain = "qp" 
        AND ptp_site = "02" NO-LOCK NO-ERROR.   

    IF (AVAILABLE ptp_det AND (ptp_ord_qty = 0 OR ptp_pm_code <> "m"
                               OR ptp_run = 0))
       OR 
       (NOT AVAILABLE ptp_det AND (pt_pm_code <> "m" OR pt_ord_qty = 0
                                   OR pt_run = 0))    
        THEN NEXT. 

    EXPORT DELIMITER ","   pt_part   pt_desc1
        IF NOT AVAILABLE ptp_det THEN pt_ord_qty ELSE ptp_ord_qty
        IF NOT AVAILABLE ptp_det THEN pt_run ELSE ptp_run
        IF NOT AVAILABLE ptp_det THEN pt_mfg_lead ELSE ptp_mfg_lead
        AVAILABLE ptp_det .

END.
