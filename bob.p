DEF VAR v_part AS CHAR. 




INPUT FROM c:\temp\web-parts.csv . 
IMPORT ^ .
OUTPUT TO c:\temp\ImageLoad.csv . 

REPEAT :
    IMPORT DELIMITER "," v_part. 
    FIND FIRST cp_mstr WHERE cp_domain = "qp" AND cp_cust = "" AND
        cp_part = v_part NO-LOCK NO-ERROR.
    IF NOT AVAILABLE cp_mstr THEN  NEXT.
        EXPORT DELIMITER ","  v_part cp_cust_part + ".jpg" .  
END.
