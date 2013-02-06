
OUTPUT TO c:\temp\bob-price1.txt .

EXPORT DELIMITER "," "Part" "Supplier #" "Date Received" "Quantity Received"
    "Site" "Price" .

FOR EACH tr_hist NO-LOCK WHERE tr_domain = "qp" AND
    tr_effdate >= 9/1/09 AND 
     (tr_type = "rct-po" ).
   IF tr_price = 0  THEN NEXT .
   FIND FIRST po_mstr NO-LOCK WHERE po_domain = "qp" AND
       po_nbr = tr_nbr .
   
/*    DISPLAY */
   EXPORT DELIMITER "," 
        tr_part  po_vend tr_effdate tr_qty_chg tr_site tr_price.

END.

