DEF VAR v_start AS DATE .
DEF VAR v_end AS DATE .
DEF VAR v_time AS INTEGER . 
DEF VAR v_qty AS DECIMAL.
DEF VAR v_count AS INTEGER.

DEF STREAM s-out . 

DEF TEMP-TABLE bob
    FIELD site AS CHAR
    FIELD TYPE AS CHAR
    FIELD DATE AS DATE
    FIELD part AS CHAR
    FIELD qty AS DECIMAL
    FIELD cust AS CHAR
    INDEX part TYPE part
    INDEX site-part TYPE site part. 

v_time = TIME . 

v_start = 9/1/2011 .
v_end = 7/31/2012 . 

FOR EACH tr_hist NO-LOCK WHERE tr_domain = "qp" AND 
    tr_effdate >= v_start AND tr_effdate <= v_end AND
    (tr_type = "iss-wo"  OR tr_type = "iss-so" OR tr_type = "iss-do") .

   
    IF NOT
        (tr_site = "02" OR tr_site = "HM" OR tr_site = "03" OR
         tr_site = "14" OR tr_site = "DT" OR tr_site = "VT"  )  THEN NEXT.


     IF tr_type = "iss-so"  THEN
         FIND FIRST ih_hist WHERE ih_domain = "qp" AND ih_nbr = tr_nbr
            NO-LOCK NO-ERROR.

     IF AVAILABLE ih_hist AND (ih_proj = "s06"  OR ih_proj = "so7" ) THEN
         NEXT .


/*      DISPLAY tr_site                                             */
/*                                         NOT                      */
/*         (tr_site = "02" OR tr_site = "HM" OR tr_site = "03" OR   */
/*          tr_site = "14" OR tr_site = "DT" OR tr_site = "VT")  .  */
      v_count = v_count + 1 .

      IF v_count MOD 5000 = 0  THEN DISPLAY tr_effdate v_count. 
      PAUSE 0 . 

      CREATE bob.
      ASSIGN
          TYPE = tr_TYPE
          site = tr_site
          part = tr_PART
          QTY = TR_QTY_CHG
          DATE = tr_effdate
          cust = IF (AVAILABLE ih_hist) THEN ih_cust ELSE "" .

/*    DISPLAY tr_site tr_type tr_effdate tr_part tr_qty_chg . */
/*    PAUSE 0 .                                               */
END.

/* OUTPUT STREAM s-out TO c:\temp\al-bob.txt . */
/* FOR EACH bob .                              */
/*     EXPORT STREAM s-out DELIMITER "," bob . */
/* END.                                        */
/* OUTPUT STREAM s-out CLOSE.                  */


v_qty = 0 .
OUTPUT STREAM s-out TO c:\temp\obs-2012-so-no-pr.txt .
EXPORT STREAM s-out DELIMITER "," "Transaction Type" "Part" "Total Quantity" "Site" .
FOR EACH bob  WHERE TYPE = "iss-so"  AND
     (ih_cust <> "13153526" AND ih_cust <> "13153527"  )
    BREAK BY site BY part.
    v_qty = v_qty + qty . 
    IF LAST-OF (part)  THEN DO:
        EXPORT STREAM s-out DELIMITER ","  type part v_qty site .
        v_qty = 0 .
    END.   
END.
OUTPUT STREAM s-out CLOSE. 

v_qty = 0 .
OUTPUT STREAM s-out TO c:\temp\obs-2012-do-no-pr.txt .
EXPORT STREAM s-out DELIMITER "," "Transaction Type" "Part" "Total Quantity" "Site" .
FOR EACH bob  WHERE TYPE = "iss-do" AND
     (cust <> "13153526" AND cust <> "13153527"  ) BREAK BY site BY part.
    v_qty = v_qty + qty . 
    IF LAST-OF (part)  THEN DO:
        EXPORT STREAM s-out DELIMITER ","  TYPE part v_qty site.
        v_qty = 0 .
    END.   
END.
OUTPUT STREAM s-out CLOSE. 

v_qty = 0 .
OUTPUT STREAM s-out TO c:\temp\obs-2012-wo-no-pr.txt .
EXPORT STREAM s-out DELIMITER "," "Transaction Type" "Part" "Total Quantity" "Site" .
FOR EACH bob  WHERE TYPE = "iss-wo"  AND
     (cust <> "13153526" AND  cust <> "13153527"  )
    BREAK BY site BY part.
    v_qty = v_qty + qty . 
    IF LAST-OF (part)  THEN DO:
        EXPORT STREAM s-out DELIMITER ","  type  part v_qty site.
        v_qty = 0 .
    END.   
END.
OUTPUT STREAM s-out CLOSE. 

/* v_qty = 0 .                                                            */
/* OUTPUT STREAM s-out TO c:\temp\obs-2009-do-pr.txt .                    */
/* FOR EACH bob  WHERE TYPE = "iss-do" AND                                */
/*      (cust = "13153526" or cust = "13153527"  ) BREAK BY TYPE BY part. */
/*     v_qty = v_qty + qty .                                              */
/*     IF LAST-OF (part)  THEN DO:                                        */
/*         EXPORT STREAM s-out DELIMITER ","  type  part v_qty .          */
/*         v_qty = 0 .                                                    */
/*     END.                                                               */
/* END.                                                                   */
OUTPUT STREAM s-out CLOSE. 

DISPLAY TIME - v_time . 
