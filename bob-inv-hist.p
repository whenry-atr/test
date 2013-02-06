default-window:width = 135.
DEFINE STREAM s-out . 
OUTPUT STREAM s-out TO c:\temp\bob-inv.csv .


/* detail sales history */
/* RUN bob1. */

/*trailer code data */
RUN bob2 .


PROCEDURE bob1.
FOR EACH ih_hist WHERE ih_domain = "qp" AND 
    ih_inv_date >= 9/1/11 AND
    ih_inv_date <= 12/31/11
/*     ih_inv_date >= 1/1/12 AND */
/*     ih_inv_date <= 6/20/12    */

    NO-LOCK .
   FOR EACH idh_hist WHERE idh_domain = "qp" AND
       idh_inv_nbr = ih_inv_nbr 
    AND
        (idh_site = "02" OR idh_site = "03" OR idh_site = "14")
       NO-LOCK.
       FIND FIRST pt_mstr WHERE pt_domain = "qp" 
           AND pt_part = idh_part NO-LOCK NO-ERROR. 

   
/*     DISPLAY */
    EXPORT STREAM s-out DELIMITER ","  
        ih_site
        ih_inv_nbr
        idh_line
        ih_inv_date
        idh_part
        pt_desc1    WHEN AVAILABLE pt_mstr  
        pt_prod_line  WHEN AVAILABLE pt_mstr 
        pt_comm_code   WHEN AVAILABLE pt_mstr 
        idh_qty_inv
        idh_um_conv
        idh_price
        idh_qty_inv * idh_price * idh_um_conv
        idh_project 
        ih_cust
        ih_bill
        ih_ship
        idh_acct

/*         WITH WIDTH 132 */
         . 
   END.
END.

END PROCEDURE.












PROCEDURE bob2.
FOR EACH ih_hist WHERE ih_domain = "qp" AND 
/*     ih_inv_date >= 9/1/11 AND */
/*     ih_inv_date <= 12/31/11   */
    ih_inv_date >= 1/1/12 AND
    ih_inv_date <= 6/20/12
    NO-LOCK .

/*     DISPLAY */
    EXPORT STREAM s-out DELIMITER ","  
        ih_inv_nbr
        ih_inv_date
        ih_cust
        ih_bill
        ih_ship
        Ih_nbr
        ih_bol
        ih_shipvia
        ih_trl1_cd
        ih_trl1_amt
        ih_trl2_cd
        ih_trl2_amt
        ih_trl3_cd
        ih_trl3_amt

/*         WITH WIDTH 132 */
         . 

END.

END PROCEDURE.

