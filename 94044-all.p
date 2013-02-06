default-window:width = 135.

DISABLE TRIGGERS FOR LOAD OF IN_mstr .
DISABLE TRIGGERS FOR LOAD OF sod_det .
FIND FIRST IN_mstr WHERE IN_domain = "qp" AND IN_site = "02"
    AND in_part = "94044"  .

DISPLAY IN_mstr WITH 3 COL WIDTH 132 .
UPDATE IN_qty_all   .

FOR EACH sod_det WHERE sod_domain = "qp" AND sod_part = "94044"
/*     NO-LOCK */
    .
/*     DISPLAY sod_det WITH 3 COL WIDTH 132 . */
    DISPLAY sod_nbr sod_line sod_qty_all sod_qty_pick sod_qty_ship sod_qty_ord
        sod_due_date
        WITH WIDTH 132. 
    IF sod_qty_all = ?  THEN
    UPDATE sod_qty_all VALIDATE ( TRUE, "" ) .
END.


/* FOR EACH lad_det WHERE lad_domain = "qp" AND lad_part = "94044" AND */
/*     lad_site = "02" NO-LOCK.                                        */
/*     DISPLAY lad_det WITH 3 COL WIDTH 132 .                          */
/* END.                                                                */

/*                                                                  */
/* FOR EACH ld_det WHERE ld_domain = "qp" AND ld_part = "94044" AND */
/*     ld_site = "02" NO-LOCK.                                      */
/*     DISPLAY ld_det WITH 3 COL WIDTH 132 .                        */
/* END.                                                             */
