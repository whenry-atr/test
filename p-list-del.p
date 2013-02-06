default-window:width = 135.
DEFINE VAR p-list AS CHAR. 
DEF VAR ana-code AS CHAR .
DEF VAR part AS CHAR . 
DEF VAR curr AS CHAR . 

DEF STREAM s-in . 
DEF STREAM s-out .
DEF STREAM s-pi-out.
DEF STREAM s-pid-out .

OUTPUT STREAM s-out TO c:\temp\miss-items.txt .
OUTPUT STREAM s-pi-out TO c:\temp\del-pi-mstr.txt .
OUTPUT STREAM s-pid-out TO c:\temp\del-pid-det.txt .
INPUT STREAM s-in FROM c:\temp\list-price-del.csv . 

IMPORT STREAM s-in ^ .

DEFINE BUFFER pimstr FOR pi_mstr . 

DISABLE TRIGGERS FOR LOAD OF pid_det .
DISABLE TRIGGERS FOR LOAD OF pi_mstr .


REPEAT WITH FRAME bob:
    IMPORT STREAM s-in DELIMITER ","
        p-list
        ana-code
        part
        curr .

    FIND pi_mstr WHERE pi_domain = "qp"
        AND pi_list = p-list 
        AND pi_cs_type = "9"
        AND pi_cs_code = ana-code
        AND pi_part_type = "6"
        AND pi_part_code = part
        AND pi_curr = curr
         .

       FOR EACH pid_det WHERE pid_domain = "qp"
           AND pid_list_id  = pi_list_id .
           EXPORT STREAM s-pid-out DELIMITER "," pid_Det .
/*            DELETE pid_det . */
       END.

   EXPORT STREAM s-pi-out DELIMITER "," pi_mstr .
/*    DELETE pi_mstr . */
   
END.
