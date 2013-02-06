DISABLE TRIGGERS FOR LOAD OF pi_mstr . 
DEFINE STREAM s-out .
OUTPUT STREAM s-out TO c:\temp\list-to-puerto.txt .
DEFINE STREAM s-pi-list .
OUTPUT STREAM s-pi-list TO c:\temp\pi_list.txt .
default-window:width = 135.

DEFINE BUFFER pi_puerto  FOR pi_mstr. 

DISABLE TRIGGERS FOR LOAD OF pi_puerto . 

EXPORT STREAM s-out DELIMITER "," 
   "Part" "Puerto List Price"   "List List Price" .

FOR EACH PI_MSTR NO-LOCK WHERE PI_LIST = "H-list" AND
    PI_CS_CODE = "H-custs"  AND pi_amt_Type = "1" AND pi_part_type = "6"  . 
    

    FOR EACH pi_puerto NO-LOCK WHERE pi_puerto.pi_domain = "qp"  AND
         pi_puerto.pi_list = "h-puerto" AND  pi_puerto.pi_cs_code = "h-puerto"
         AND pi_mstr.pi_part_code =  pi_puerto.pi_part_code and
         pi_puerto.pi_amt_type = "1" AND pi_puerto.pi_part_type = "6" .

/*     DISPLAY */
        IF pi_puerto.pi_list_price <> pi_mstr.pi_list_price THEN DO:
          EXPORT STREAM s-pi-list pi_puerto.
          EXPORT STREAM s-out DELIMITER "," pi_puerto.pi_part_code
              pi_puerto.pi_list_price pi_mstr.pi_list_price 
              pi_puerto.pi_start pi_puerto.pi_expire. 

/*           pi_puerto.pi_list_price = pi_mstr.pi_list_price. */
        END.
    END.


END.



