FOR EACH ih_hist WHERE ih_domain = "qp" AND ih_inv_date > 7/01/10 NO-LOCK.
  
    IF not (
         ih_rmks = "web" AND NOT (ih_po BEGINS("exe") OR ih_po BEGINS("oas") )
         )
         THEN NEXT .

    FOR EACH idh_hist WHERE idh_domain = "qp" AND idh_inv_nbr = ih_inv_nbr NO-LOCK .
        FIND FIRST sod_det_a WHERE sls_ord = ih_nbr AND sls_line = idh_line
            NO-LOCK NO-ERROR.

/*         IF AVAILABLE sod_det_a THEN NEXT . */

        DISPLAY ih_nbr idh_line idh_part ih_rmks ih_inv_date ih_po.

    END.
END.
