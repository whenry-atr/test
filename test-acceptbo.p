DEFINE BUFFER ihhist FOR ih_hist .

DEFINE TEMP-TABLE t-dups
    FIELD ord AS CHAR
    FIELD inv AS CHAR
    FIELD tdate AS DATE.
    
FOR EACH ih_hist WHERE ih_domain = "qp" AND ih_inv_date > TODAY - 1 NO-LOCK.
    FIND FIRST ih_hist_a WHERE ih_inv_nbr = invoice_no NO-LOCK NO-ERROR.

  
    IF NOT AVAILABLE ih_hist_a THEN NEXT . 
    IF acceptbo = YES THEN NEXT.

    /* are there dups invoices or orders still open after invoicing  */

     FIND FIRST so_mstr NO-LOCK WHERE so_domain = "qp" AND
                so_nbr = ih_hist.ih_nbr  NO-ERROR.
     IF AVAILABLE so_mstr  THEN DO:
         CREATE t-dups.
             ASSIGN
                t-dups.inv = "Sales Ord"
                tdate = so_ord_date
                t-dups.ord = so_nbr.

          CREATE t-dups.
              ASSIGN
                t-dups.inv = ih_inv_nbr 
                tdate = ih_inv_date 
                t-dups.ord = ih_nbr.
     END.

    IF CAN-FIND(FIRST ihhist WHERE ihhist.ih_domain = "qp" AND 
                ihhist.ih_nbr = ih_hist.ih_nbr AND 
                recid(ihhist) <> recid(ih_hist)) THEN  DO:
        FOR EACH ihhist  WHERE ihhist.ih_domain = "qp" AND 
                    ihhist.ih_nbr = ih_hist.ih_nb. 

            IF CAN-FIND(FIRST t-dups WHERE t-dups.inv = ihhist.ih_inv_nbr) THEN NEXT .
            CREATE t-dups.
              ASSIGN
                t-dups.inv = ihhist.ih_inv_nbr 
                tdate = ihhist.ih_inv_date 
                t-dups.ord = ihhist.ih_nbr.
        END.
    END.
    

END.

OUTPUT TO c:\temp\test-acceptbo.txt .
EXPORT DELIMITER "," "Order#" "Inv#"  "Date" .

FOR EACH t-dups BY t-dups.ord:
    EXPORT DELIMITER "," t-dups.
END.
