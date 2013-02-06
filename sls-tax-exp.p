default-window:width = 135.

DEF VAR v_tax AS DECIMAL .
DEF VAR v_taxable AS DECIMAL .
DEF STREAM s-out .
OUTPUT STREAM s-out TO c:\temp\sept-sls-tax.txt .

FOR EACH ih_hist WHERE ih_domain = "qp" AND ih_inv_date >= 6/1/10 
    AND ih_tax_usage = "tax" 
    AND ih_inv_date <= 6/30/10   NO-LOCK .    

    ASSIGN
        v_tax = 0
        v_taxable = 0 .

    FIND FIRST ad_mstr WHERE ad_domain = "qp" AND ad_addr = ih_ship NO-LOCK .
    
    FOR EACH tx2d_det WHERE tx2d_domain = "qp" AND tx2d_ref = ih_inv_nbr
        AND tx2d_tr_type = "16" 
        NO-LOCK .
        ASSIGN
            v_tax = v_tax + tx2d_tax_amt
            v_taxable = v_taxable + tx2d_taxable_amt .
/*        DISPLAY ad_state ad_zip .              */
/*        DISPLAY tx2d_det WITH 3 COL WIDTH 132. */
    END.
    EXPORT STREAM s-out DELIMITER ","
        ih_inv_nbr ad_state ad_zip v_tax v_taxable .
END.
