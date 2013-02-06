default-window:width = 135.
FOR EACH ad_mstr WHERE ad_edi_tpid <> "" 
     AND ad_name BEGINS  "us" no-lock .

    FOR EACH ih_hist WHERE ih_domain = "qp" 
        AND ih_inv_date > 6/1/11 AND ih_cust = ad_addr NO-LOCK .
       IF AVAILABLE ih_hist THEN
        DISPLAY ad_addr ad_name ih_inv_nbr ih_trl1_amt ih_trl1_cd 
           ih_inv_date WITH WIDTH 132. 
    END.
END.
