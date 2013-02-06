default-window:width = 135.
FOR EACH tr_hist WHERE tr_domain = "qp" 
    AND tr_date >= TODAY - 1  AND tr_type = "iss-so" .

FIND FIRST so_mstr_a WHERE sls_ord = tr_nbr NO-LOCK .
/* IF acceptbo THEN NEXT .  */
FIND FIRST sod_det NO-LOCK WHERE sod_line = tr_line 
    AND sod_domain = "QP" AND sod_nbr = tr_nbr NO-ERROR  .

IF NOT AVAILABLE sod_det THEN NEXT .

/* IF tr_qty_chg <> sod_qty_ord THEN */
    DISPLAY tr_nbr  tr_qty_chg sod_qty_ord sod_qty_ship STRING(tr_time,"hh:mm:ss")
       acceptbo  WITH WIDTH 132. 
