DEF TEMP-TABLE demand
    FIELD part AS CHAR
    FIELD company AS CHAR
    FIELD division AS CHAR
    FIELD department AS CHAR .

DEF VAR v_part AS CHAR . 
DEF VAR v_company AS CHAR . 
DEF VAR v_division AS CHAR . 
DEF VAR v_department AS CHAR . 

DEF STREAM s-in . 
INPUT STREAM s-in FROM C:\Temp\demand.txt .

DEF STREAM s-in2.
INPUT STREAM s-in2 FROM C:\Temp\DmdSol\demand-load-monthly.csv .

IMPORT STREAM s-in ^ . 
REPEAT.
    CREATE demand.
    IMPORT STREAM s-in DELIMITER "," part company division 
          ^ ^ department. 
END.

/* FOR EACH demand BY part. */
/*     DISPLAY demand  .    */
/*     .                    */
/* END.                     */


REPEAT:
    IMPORT STREAM s-in2 DELIMITER "," v_part v_company v_division v_department . 
    FIND FIRST demand WHERE 
        v_part = part    AND
        v_company = company AND
        v_division = division  AND
        v_department = department
        NO-LOCK NO-ERROR. 

    IF NOT AVAILABLE demand  
/*         AND v_company = "hm" */
        THEN
        DISPLAY v_part v_company v_division v_department (COUNT).

    PAUSE 0 . 

END.

