DEF STREAM s-so.
DEF STREAM s-wo.
DEF STREAM s-do.
DEF STREAM s-avg . 
DEF STREAM s-test.
DEF STREAM s-first-rec.

OUTPUT STREAM s-so TO c:\temp\2010-so.txt .
OUTPUT STREAM s-wo TO c:\temp\2010-wo.txt .
OUTPUT STREAM s-avg TO c:\temp\2010-AVG.txt .
OUTPUT STREAM s-test TO c:\temp\2010-test.txt .
OUTPUT STREAM s-first-rec TO c:\temp\2010-first-rec.txt .
OUTPUT STREAM s-do TO c:\temp\2010-do.txt .

DEF VAR v_entity AS CHAR .
DEF VAR v_cnt AS INT .
DEF VAR v_time AS INT .
DEF VAR v_start_date AS DATE . 

DEF TEMP-TABLE t-items
    FIELD part AS CHAR
    FIELD entity AS CHAR
    FIELD price AS DEC 
    FIELD qty AS DECIMAL
    FIELD nbr AS CHAR
    FIELD inv AS CHAR
    FIELD LINE AS INTEGER 
    FIELD tdate AS DATE
    INDEX bob entity part . 

v_start_date = 9/1/09 .

v_time = TIME .

/* RUN p-so .     */
/* RUN p-wo .     */
/* RUN p-avg    . */
/* RUN p-do. */
RUN p-first-rec .


PROCEDURE p-first-rec .
    EXPORT STREAM s-first-rec DELIMITER ","
        "Part" "Date Added" "Transaction Type" "Transaction Date" .

    FOR EACH pt_mstr NO-LOCK WHERE pt_domain = "qp" 
        AND pt_added >= v_start_date  . 
        FIND FIRST tr_hist WHERE tr_domain = "qp" 
            AND tr_part = pt_part AND
             (tr_type = "rct-po" OR tr_type = "rct-wo") NO-LOCK
             USE-INDEX tr_part_eff  NO-ERROR.
        EXPORT STREAM s-first-rec DELIMITER ","  
                pt_part pt_added 
                tr_type  WHEN AVAILABLE tr_hist 
                tr_effdate WHEN AVAILABLE tr_hist . 
    END.


END PROCEDURE. 



PROCEDURE p-do .
    EMPTY TEMP-TABLE t-items .
    EXPORT STREAM s-do DELIMITER "," 
        "Entity" "Part" "Qty" .
    FOR EACH tr_hist WHERE tr_domain = "qp" AND tr_type = "iss-do" 
        AND tr_effdate >= v_start_date AND tr_effdate <= 8/31/10 
        AND tr_ship_type = "" NO-LOCK .

        CREATE t-items.

        IF tr_site = "02" OR tr_site = "03" or tr_site = "14" or
           tr_site = "hm" OR tr_site = "dt" OR tr_site = "vt" THEN
           v_entity = "HM" .
        ELSE IF tr_site = "32" OR tr_site = "34" OR tr_site = "ca" THEN
            v_entity = "CA" .
        ELSE IF tr_site = "13" OR tr_site = "PS"  THEN
            v_entity = "PS" .

        v_cnt = v_cnt + 1 . 
        ASSIGN
            entity = v_entity
            part = tr_part 
            qty = tr_qty_chg 
            nbr = tr_nbr 
            tdate = tr_date
            LINE = tr_line.
    END.
    FOR EACH t-items BREAK BY entity BY part .
        ACCUMULATE qty (TOTAL by entity  BY part) .
        IF LAST-OF(part) THEN  DO:
            EXPORT STREAM s-do DELIMITER "," 
                entity
                part
                ACCUM TOTAL  BY part qty  .
        END.
/*        DISPLAY STREAM s-test entity part  qty . */
    END.
END PROCEDURE .


PROCEDURE p-avg .
    EMPTY TEMP-TABLE t-items .
    EXPORT STREAM s-avg DELIMITER "," 
        "Entity" "Part" "Qty" "Qty * Price" .
    FOR EACH tr_hist WHERE tr_domain = "qp" AND tr_type = "rct-po" 
        AND tr_effdate >= v_start_date AND tr_effdate <= 8/31/10 
        AND tr_ship_type = ""  NO-LOCK .
        CREATE t-items.

        IF NOT 
            (tr_site = "02" OR tr_site = "03" or tr_site = "14" or
           tr_site = "hm" OR tr_site = "dt" OR tr_site = "vt")
             THEN NEXT.

        IF tr_price = 0  THEN NEXT .

        v_cnt = v_cnt + 1 . 
        ASSIGN
            entity = v_entity
            part = tr_part 
            price = tr_price
            qty = tr_qty_chg
            nbr = tr_nbr 
            tdate = tr_date      
            LINE = tr_line.
    END.
    FOR EACH t-items BREAK BY entity BY part .
        ACCUMULATE qty (TOTAL by entity  BY part) price * qty (TOTAL BY entity BY part) .
        IF LAST-OF(part) THEN  DO:
            EXPORT STREAM s-avg DELIMITER "," 
                entity
                part
                ACCUM TOTAL  BY part qty 
                ACCUM TOTAL  BY part price * qty .
        END.
       DISPLAY STREAM s-test entity part  qty price price * qty.
    END.
END PROCEDURE .


PROCEDURE p-so .
    EMPTY TEMP-TABLE t-items .
    EXPORT STREAM s-so DELIMITER "," 
        "Entity" "Part" "Qty" .
    FOR EACH tr_hist WHERE tr_domain = "qp" AND tr_type = "iss-so" 
        AND tr_effdate >= v_start_date AND tr_effdate <= 8/31/10 
        AND tr_ship_type = "" NO-LOCK .

        CREATE t-items.

        IF tr_site = "02" OR tr_site = "03" or tr_site = "14" or
           tr_site = "hm" OR tr_site = "dt" OR tr_site = "vt" THEN
           v_entity = "HM" .
        ELSE IF tr_site = "32" OR tr_site = "34" OR tr_site = "ca" THEN
            v_entity = "CA" .
        ELSE IF tr_site = "13" OR tr_site = "PS"  THEN
            v_entity = "PS" .

        v_cnt = v_cnt + 1 . 
        ASSIGN
            entity = v_entity
            part = tr_part 
            qty = tr_qty_chg 
            nbr = tr_nbr 
            tdate = tr_date      
            LINE = tr_line.
    END.
    FOR EACH t-items BREAK BY entity BY part .
        ACCUMULATE qty (TOTAL by entity  BY part) .
        IF LAST-OF(part) THEN  DO:
            EXPORT STREAM s-so DELIMITER "," 
                entity
                part
                ACCUM TOTAL  BY part qty  .
        END.
/*        DISPLAY STREAM s-test entity part  qty . */
    END.
END PROCEDURE .

PROCEDURE p-wo .
    EXPORT STREAM s-wo DELIMITER "," 
        "Entity" "Part" "Qty"  .
    EMPTY TEMP-TABLE t-items .
    FOR EACH tr_hist WHERE tr_domain = "qp" AND tr_type = "iss-wo" 
        AND tr_effdate >= v_start_date AND tr_effdate <= 8/31/10
        AND tr_ship_type = ""  NO-LOCK .
        CREATE t-items.
        IF tr_site = "02" OR tr_site = "03" or tr_site = "14" or
           tr_site = "hm" OR tr_site = "dt" OR tr_site = "vt" THEN
           v_entity = "HM" .
        ELSE IF tr_site = "32" OR tr_site = "34" OR tr_site = "ca" THEN
            v_entity = "CA" .
        ELSE IF tr_site = "13" OR tr_site = "PS"  THEN
            v_entity = "PS" .

        v_cnt = v_cnt + 1 . 
        ASSIGN
            entity = v_entity
            part = tr_part 
            qty = tr_qty_chg
            nbr = string(tr_trnbr)
            tdate = tr_date        
            LINE = tr_line.
    END.
    FOR EACH t-items BREAK BY entity BY part .
        ACCUMULATE qty (TOTAL by entity  BY part) .
        IF LAST-OF(part) THEN  DO:
            EXPORT STREAM s-wo DELIMITER "," 
                entity
                part
                ACCUM TOTAL  BY part qty  FORMAT "->>>,>>>,>>9.99" .
        END.
/*        DISPLAY STREAM s-test nbr entity part  qty FORMAT "->>>,>>>,>>9.99" . */
    END.
END PROCEDURE .
