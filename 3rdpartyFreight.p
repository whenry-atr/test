
default-window:width = 135.

DEF VAR v_inv_total AS DEC . 
DEFINE STREAM s-out . 

OUTPUT STREAM s-out TO c:\temp\cust-freight.txt .

EXPORT 
    STREAM s-out DELIMITER "," 
    "Invoice #"  "Order #" "Cust #" "Cust Name" "Invoice Date" "Invoice Total $" "Freight Terms" 
    "Freight Policy" "Shiptec Freight $" "Invoice Freight $" "Freight Weight" "Ship Via" "Ship Via Name" 
    "Project" .
FOR EACH ih_hist NO-LOCK WHERE
    ih_domain = "QP" AND ih_inv_date >= 9/1/10 AND ih_inv_date <= 8/31/11 .

    IF ih_fr_terms <> "3rdparty" AND ih_fr_terms <> "collect" THEN NEXT .

/*     FIND FIRST suh_hist WHERE sls_ord = ih_nbr AND site = "hm"  NO-LOCK NO-ERROR. */
    FIND FIRST ih_hist_a WHERE invoice_no = ih_inv_nbr NO-LOCK NO-ERROR.
    FIND FIRST cm_mstr WHERE cm_addr = ih_cust AND cm_domain = "qp" NO-LOCK .
    FIND FIRST cm_mstr_a WHERE cm_addr = addr NO-LOCK.
    FIND  CODE_mstr
        WHERE CODE_domain = "qp" AND CODE_fldname = "so_shipvia" 
        AND CODE_value =  ih_shipvia NO-LOCK
        NO-ERROR .

   v_inv_total = 0 .

   FOR EACH idh_hist WHERE idh_domain = "qp" AND idh_inv_nbr = ih_inv_nbr NO-LOCK .
       v_inv_total =  v_inv_total + (idh_qty_inv * idh_price * idh_um_conv) .
   END.

   EXPORT  
        STREAM s-out DELIMITER "," 
        ih_inv_nbr ih_nbr ih_cust cm_sort ih_inv_date 
        v_inv_total
        ih_fr_terms 
        IF AVAILABLE ih_hist_a THEN freight_policy ELSE ""
        IF AVAILABLE ih_hist_a THEN freight_paid ELSE 0
        ih_trl1_amt
        IF AVAILABLE ih_hist_a THEN freight_weight ELSE 0 
        ih_shipvia 
        IF AVAILABLE CODE_mstr THEN code_cmmt ELSE ""
        ih_project 
         .
END.
