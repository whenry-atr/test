default-window:width = 135.
DEF STREAM s-out .

DEF VARIABLE v_tot_qty AS DECIMAL.
DEF VAR v_tot_price AS DECIMAL.
DEF VAR v_count AS INTEGER.

DEFINE TEMP-TABLE t-avg 
    FIELD part AS CHAR
    FIELD qty AS DECIMAL
    FIELD price AS DECIMAL
    FIELD t-date AS DATE
    INDEX bob part. 

OUTPUT STREAM s-out TO c:\temp\avg-rct.txt .
FOR EACH tr_hist NO-LOCK WHERE tr_effdate >= 9/1/11
     AND tr_effdate <= 8/31/12 AND tr_type = "rct-po"  
    AND tr_domain ="qp" AND tr_price <> 0 AND
    (tr_site = "02" OR tr_site = "14" OR tr_site = "03") .
   

FIND FIRST pod_det NO-LOCK WHERE pod_domain = "qp" AND pod_nbr = tr_nbr AND pod_line = pod_line.

IF pod_type <> "" THEN NEXT .

/*14021 = .88956 */
/*     DISPLAY tr_part tr_qty_chg tr_price tr_effdate . */

    CREATE t-avg.
    ASSIGN
        part = tr_part
        qty = tr_qty_chg
        price = tr_price * tr_qty_chg 
        t-date = tr_effdate .
END.


FOR EACH t-avg BREAK BY part.

    IF FIRST-OF (part) THEN do:
        v_tot_price = 0 .
        v_tot_qty = 0.
    END.

    v_tot_qty = v_tot_qty + qty .
    v_tot_price = v_tot_price + price .

    IF LAST-OF (part) THEN
        EXPORT STREAM s-out DELIMITER ","
                t-avg.part v_tot_price / v_tot_qty  v_tot_price v_tot_qty .
END.
