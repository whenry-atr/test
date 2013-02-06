INPUT FROM c:\temp\call-close2.csv .

DEF VAR v_call AS CHAR .


DEF STREAM s-out .

/* OUTPUT STREAM s-out TO c:\temp\ca_mstr_close2.d . */

DISABLE TRIGGERS FOR LOAD OF ca_mstr . 

REPEAT:
    IMPORT DELIMITER "," v_call .
    FIND FIRST ca_mstr WHERE ca_domain = "qp" AND ca_nbr = v_call .
    
/*    EXPORT STREAM s-out ca_mstr.                               */
/*                                                              */
/*    ASSIGN                                                    */
/*        ca_status = "closed"                                  */
/*        ca_cls_date = TODAY                                   */
/*        ca_cls_time = replace(string(TIME,"hh:mm"),":","")  . */

/*     ca_cls_time = REPLACE(ca_cls_time," ","")  . */


    DISPLAY
        ca_nbr
        ca_cls_date
        ca_cls_time
        ca_created
        ca_status
        ca_comp_date .
END.
