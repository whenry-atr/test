default-window:width = 135.

/* Stream for the group price load */
DEF STREAM s-out-grp .
/* Stream for the list prist load */
DEF STREAM s-out-list .
DEF VAR v_um_conv AS DEC . 
DEF TEMP-TABLE t-spec
    FIELD spec_cust AS CHAR 
    FIELD spec_parts AS CHAR FORMAT "x(40)" . 

DEF TEMP-TABLE t-plist
    FIELD plist AS CHAR
    FIELD part AS CHAR
    FIELD amt AS DEC 
    INDEX plist plist . 

DEFINE BUFFER tplist FOR t-plist .

OUTPUT STREAM s-out-grp TO c:\temp\web-price-grp.csv .
OUTPUT STREAM s-out-list TO c:\temp\web-price-list.csv .

EXPORT STREAM s-out-list DELIMITER "," "SKU" "PRICE" .
EXPORT STREAM s-out-grp  DELIMITER ","  "##CPPG" "sku" "customer_group" "price" "website" .

FOR EACH pt_mstr_a WHERE web_ord_allow  NO-LOCK .
    FIND FIRST pt_mstr NO-LOCK WHERE pt_domain = "qp" AND pt_part = part .
    /* If the default Unit Of Measure is 'EA' the price needs to be converted
       to the case price */
    v_um_conv = 1 .
    IF pt_um = "EA"  THEN DO:
        FIND FIRST um_mstr NO-LOCK WHERE um_domain = "QP" AND um_part = pt_part AND
            um_um = pt_um AND um_alt_um = "CS"  NO-ERROR .
        IF AVAILABLE um_mstr THEN v_um_conv = um_conv . .
    END.

    FOR EACH pi_mstr NO-LOCK
        WHERE pi_domain = "qp"  AND pi_part_type = "6" AND pi_cs_type = "9"
           AND pi_list MATCHES("H*") AND  pi_part_code = part.
        /* Export the list prices */
        IF pi_list = "H-List" AND  pi_cs_code = "H-Custs" THEN  DO:
            EXPORT STREAM s-out-list DELIMITER "," pi_part_code pi_list_price * v_um_conv.
        END.
        /* Export the group price items */
        ELSE DO:
            FOR EACH pid_det WHERE pid_domain = "qp" AND pid_list_id = pi_list_id.
                /* IF this is a 'special' then store the customer for later processing */
                IF pi_list = "H-SPEC"  THEN DO:
                    FIND FIRST t-spec WHERE spec_cust = pi_cs_code NO-ERROR .
                    IF NOT AVAILABLE t-spec  THEN  DO:
                        CREATE t-spec.
                        ASSIGN
                            spec_cust = pi_cs_code .
                    END.
                    spec_parts = spec_parts + "," + pi_part_code .
                    /* This is an H-Spec so we have created the correct 'special' for that customer and we are done */
                    NEXT .
                END.
                CREATE t-plist.
                ASSIGN
                    part = pi_part_code
                    plist = pi_list
                    amt = pid_amt * v_um_conv .
            END.
        END.
    END.
END.




/* OUTPUT TO c:\temp\tspec.txt .  */
/* FOR EACH t-spec.               */
/*     EXPORT t-spec .            */
/* END.                           */
/*                                */
/* OUTPUT TO c:\temp\tplist.txt . */
/* FOR EACH t-plist.              */
/*     EXPORT t-plist .           */
/* END.                           */


/* INPUT FROM c:\temp\tplist.txt . */
/* REPEAT:                         */
/*     CREATE t-plist.             */
/*     IMPORT t-plist.             */
/* END.                            */
/*                                 */
/*                                 */
/* DEF VAR v_count AS INTEGER .    */
/*                                 */
/* INPUT FROM c:\temp\tspec.txt .  */
/* REPEAT:                         */
/*     v_count = v_count + 1 .     */
/*     CREATE t-spec.              */
/*     IMPORT t-spec.              */
/*     IF v_count = 10 THEN        */
/*     LEAVE .                     */
/* END.                            */



/* For each customer that had a special price item we must add their 'regular' price list items to that new
   group.  First find their 'regular' price list by looking for 'H' list items.  Then go back to the temp table
   previously generated and create a copy for this special price group. While doing this make certain to not 
   have duplicates by leaving out the parts that were added to the group file because they were specified
   as different on the H-Spec */
FOR EACH t-spec.
    FOR EACH ls_mstr WHERE ls_domain = "qp" AND ls_addr = spec_cust NO-LOCK .
        IF ls_type BEGINS("H-") THEN DO:
            FOR EACH t-plist NO-LOCK WHERE ls_type = plist .
                IF LOOKUP(t-plist.part,spec_parts) = 0  THEN DO:
                    CREATE tplist .
                    ASSIGN
                        tplist.part = t-plist.part
                        tplist.amt = t-plist.amt
                        tplist.plist = "H-" + spec_cust .
                END.
            END.
       END.     
    END.
END.



FOR EACH t-plist NO-LOCK.
    EXPORT STREAM s-out-grp DELIMITER ","
        "CPPG"
        t-plist.part
        t-plist.plist
        t-plist.amt
        "admin" .
END.
