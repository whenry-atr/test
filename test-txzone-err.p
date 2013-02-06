DEF VAR v_index AS INTEGER .
DEF VAR v_zip AS CHAR .
DEF VAR v_cust AS CHAR .
DEF VAR v_line AS CHAR FORMAT "x(132)" .
DEF VAR v_valid_vertex_zip AS LOGICAL .
DEF VAR v_valid_uspo_zip AS LOGICAL.
DEF VAR v_valid_vertex_zip_city AS LOGICAL .
DEF VAR v_valid_uspo_zip_city AS LOGICAL.


DEF TEMP-TABLE uspo_zip_mstr LIKE cszip_mstr 
    FIELD city_alias_abrev  AS CHAR
    FIELD city_alias_name   AS CHAR
    INDEX address state city county_name 
    INDEX city zip_code city
    INDEX state zip_code state
    INDEX zip zip_code city state county_name 
    INDEX city-name city .



DEF TEMP-TABLE vertex_zip_mstr LIKE cszip_mstr 
    FIELD zip_end AS CHAR 
    INDEX address state city county_name 
    INDEX city zip_code city
    INDEX state zip_code state
    INDEX zip zip_code city state county_name .

DEF BUFFER b_vertex_zip_mstr FOR TEMP-TABLE vertex_zip_mstr . 
DEF BUFFER b_uspo_zip_mstr FOR TEMP-TABLE uspo_zip_mstr .


RUN p_load_vertex .

RUN p_load_uspo .


INPUT FROM c:\temp\txzone-err.txt .
OUTPUT TO c:\temp\txzone-err-test.txt .
EXPORT DELIMITER ","
    "Customer" "Zip" "City" "County"  "St" "Valid USPO Zip" "Valid VERTEX Zip"
    "Valid USPO Zip & City" "Valid Vertex Zip & City" .
REPEAT:
    IMPORT UNFORMATTED v_line .
    v_cust = SUBSTRING(v_line,1,8) .
    v_zip = trim(SUBSTRING(v_line,86,10)) .
    FIND FIRST ad_mstr NO-LOCK WHERE ad_domain = "qp" AND ad_addr = v_cust NO-ERROR.
    IF NOT AVAILABLE ad_mstr THEN NEXT .

    ASSIGN
    v_valid_uspo_zip = CAN-FIND(FIRST uspo_zip_mstr WHERE ad_zip = uspo_zip_mstr.zip_code) 
    v_valid_vertex_zip = CAN-FIND(FIRST vertex_zip_mstr WHERE ad_zip = vertex_zip_mstr.zip_code) 
    v_valid_uspo_zip_city = CAN-FIND(FIRST uspo_zip_mstr WHERE ad_zip = uspo_zip_mstr.zip_code
                                     AND ad_city = uspo_zip_mstr.city) 
    v_valid_vertex_zip_City= CAN-FIND(FIRST vertex_zip_mstr WHERE ad_zip = vertex_zip_mstr.zip_code
                                       AND ad_city = vertex_zip_mstr.city ) .


    EXPORT DELIMITER "," 
        v_cust ad_zip ad_city ad_county ad_state
        v_valid_uspo_zip       v_valid_vertex_zip
         v_valid_uspo_zip_city v_valid_vertex_zip_City 
        . 
END.





PROCEDURE p_load_uspo . 
    DEF VARIABLE v_index AS INTEGER .
    INPUT FROM c:\temp\zip_codes.csv .
    IMPORT ^ .  /*skip header */
    REPEAT:
        CREATE uspo_zip_mstr .
        IMPORT DELIMITER "," 
            zip_code  
            city  state county_name
            ^ ^ city_alias_abrev city_alias_name .
        /* There is a record for every city with the same name as the city for the alias.  Here I change on the others
           the city to equal the alias.  Ny doing so I create a record for each alias so the vertex couty can be inserted
           This allow the correct county into QAD if QAD is using the alias */
        IF city <> city_alias_name THEN 
            ASSIGN city = city_alias_name .
    END.     
    INPUT CLOSE .

END.


PROCEDURE p_load_vertex . 
    DEF VARIABLE v_index AS INTEGER .
    INPUT FROM c:\temp\expanded_city.csv .
    IMPORT ^ .  /*skip header */
    REPEAT:
        CREATE vertex_zip_mstr .
        IMPORT DELIMITER "," 
            zip_code zip_end 
            city  county_name  state county
            . /*explode any zip code ranges */ 
        v_index = integer(zip_end) - integer(zip_code) .

        DO WHILE v_index > 0 .
            CREATE b_vertex_zip_mstr.
            BUFFER-COPY vertex_zip_mstr TO b_vertex_zip_mstr .
            b_vertex_zip_mstr.zip_code 
                = string(integer(vertex_zip_mstr.zip_code) + v_index, "99999") .
            v_index = v_index - 1 .   
        END.
    END.     
    INPUT CLOSE .
END.
