/*     Geocode Hit  Zip matches Matches GEO
          YES         YES                                  Great we are cool
          YES         no,yes  (geo hit zip)                CHange the Geo to what matche zip
          YES         no,no                                Print it 
          NO          yes     geo hit                      change the geo code to what matches zip           
*/


default-window:width = 135.
DEF TEMP-TABLE geocodes
    FIELD geocode AS CHAR FORMAT "x(25)" 
    FIELD city AS CHAR
    FIELD zip_start AS CHAR
    FIELD zip_end AS CHAR 
    INDEX geocode geocode .

DEFINE BUFFER b-geocodes FOR geocodes .

DEF VAR v_st AS CHAR.
DEF VAR v_county AS CHAR.
DEF VAR v_city AS CHAR.
DEF VAR v_count AS INTEGER .

FUNCTION  f-zfill RETURNS CHAR (p_string AS CHAR, p_length AS INTEGER) 
        FORWARD.

RUN p-load-geo . 

FOR EACH ad_mstr WHERE ad_domain = "qp" AND ad_type = "customer" NO-LOCK .
    /*drop canada or other non US */
    IF ad_tax_zone BEGINS("CAN") 
           OR (ad_country <> "USA"  AND ad_country <> "UNITED STATES OF AMERICA") 
        THEN NEXT .

    FIND FIRST geocodes WHERE ad_zip = zip_start NO-LOCK NO-ERROR .
    IF  NOT AVAILABLE geocodes THEN DO:
        v_count = v_count + 1 .
        DISPLAY ad_tax_zone ad_city ad_county ad_zip ad_country
        WITH WIDTH 132  .
    END. 
END.

/* DISPLAY v_count . */

PROCEDURE p-load-geo.  
    DEF VAR v_index AS INTEGER . 
    INPUT FROM c:\temp\geocodes.csv .

    IMPORT ^ . /* skip header lines */
    REPEAT:
        CREATE geocodes .
        IMPORT DELIMITER "," 
            v_st v_county v_city ^ ^ city zip_start zip_end .   
        geocode = f-zfill(v_st,2) + f-zfill(v_county,3) + f-zfill(v_city,4) . 

        /*forget Canada (non numeric) */
        IF zip_start > "99999"  THEN DO:
            DELETE geocodes.
            NEXT .
        END.

        /*explode any zip code ranges */
        v_index = integer(zip_end) - integer(zip_start) .
        DO WHILE v_index > 0 .
            CREATE b-geocodes.
            BUFFER-COPY geocodes TO b-geocodes.
            b-geocodes.zip_start = string( integer(geocodes.zip_start) + v_index) .
            b-geocodes.zip_end = b-geocodes.zip_start .
            v_index = v_index - 1 .
        END.
    END.
END PROCEDURE .

FUNCTION f-zfill RETURNS CHAR .
    RETURN FILL("0",p_length - LENGTH( p_string)) + p_string .
END FUNCTION . 



