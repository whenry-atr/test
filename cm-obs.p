OUTPUT TO c:\temp\cm-obs-tr.txt .
INPUT FROM c:\temp\cm-obs.txt . 
DEF VAR v_part AS CHAR . 
DEF BUFFER psmstr FOR ps_mstr .

REPEAT:
    IMPORT v_part . 

    FOR EACH ps_mstr NO-LOCK WHERE ps_par = v_part AND ps_domain = "qp" .

        FIND LAST 
            tr_hist WHERE tr_domain =  "qp" AND tr_part = v_part AND 
            tr_type = "iss-wo" NO-ERROR. 

        IF AVAILABLE tr_hist THEN   
        EXPORT DELIMITER ","  
            v_part ps_mstr.ps_comp tr_effdate tr_qty_chg  .
                
    END.                     
    
END.




