DEF STREAM S-OUT. 

OUTPUT STREAM s-out TO c:\temp\comp-vertex-uspo.txt .

default-window:width = 220.

DEF VAR msg AS CHAR FORMAT "x(45)" .
DEF VAR v_count AS INTEGER . 
DEF VAR v_state AS CHAR.
DEF VAR v_city AS CHAR .
DEF VAR v_county AS CHAR .
DEF VAR v_ad_cmp_state AS LOGICAL .  
DEF VAR v_ad_cmp_county AS LOGICAL .  
DEF VAR v_ad_cmp_city AS LOGICAL .  

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


/* DEF VAR v_zip AS CHAR .                                                                  */
/* REPEAT:                                                                                  */
/*     UPDATE v_zip WITH FRAME a.                                                           */
/*     FIND FIRST uspo_zip_mstr WHERE v_zip = uspo_zip_mstr.zip_code NO-ERROR .             */
/*     FIND FIRST vertex_zip_mstr WHERE v_zip = vertex_zip_mstr.zip_code NO-ERROR .         */
/*     DISPLAY                                                                              */
/*         IF AVAILABLE uspo_zip_mstr  THEN "USPO YES" ELSE "USPO NO"   FORMAT "x(12)"      */
/*          IF AVAILABLE vertex_zip_mstr  THEN "VERTEX YES" ELSE "VERTEX NO" FORMAT "x(12)" */
/*              WITH FRAME a DOWN.                                                          */
/*    DOWN  WITH FRAME a .                                                                  */
/* END.                                                                                     */
/*                                                                                          */
/*                                                                                          */
/*                                                                                          */
/*                                                                                          */
/* QUIT .                                                                                   */

RUN p_load_vertex_county_name . 

OUTPUT TO c:\temp\vertex_exp.txt .
FOR EACH vertex_zip_mstr.
    EXPORT DELIMITER "," vertex_zip_mstr.
END.
OUTPUT CLOSE .

OUTPUT TO c:\temp\uspo_exp.txt .
FOR EACH uspo_zip_mstr.
    EXPORT DELIMITER "," uspo_zip_mstr.
END.
OUTPUT CLOSE .


/* FOR EACH uspo_zip_mstr WHERE zip_code = "53226" . */
/*    DISPLAY uspo_zip_mstr WITH 3 COL WIDTH 132 .   */
/* END.                                              */



RUN p_update_qad_county.

PROCEDURE p_update_qad_county.
    DISABLE TRIGGERS FOR LOAD OF ad_mstr . 
    FOR EACH ad_mstr  WHERE ad_domain = "qp" AND
        ( ad_type = "customer"  OR ad_type = "ship-to" )
        .

        /* Must match city name and zip for vertex purposes  */
        FIND FIRST uspo_zip_mstr NO-LOCK  WHERE
            uspo_zip_mstr.zip_code = ad_zip  AND 
              ad_city = uspo_zip_mstr.city  NO-ERROR .

        IF AVAILABLE(uspo_zip_mstr) AND 
            ad_county <>  uspo_zip_mstr.county_name
                THEN DO:

/*             DISPLAY ad_addr ad_county uspo_zip_mstr.county_name . */

            ad_county =  uspo_zip_mstr.county_name .
        END.
    END.
END PROCEDURE .


PROCEDURE p_load_vertex_county_name.
    FOR EACH uspo_zip_mstr .
        FIND FIRST vertex_zip_mstr WHERE vertex_zip_mstr.zip_code =
            uspo_zip_mstr.zip_code AND 
                vertex_zip_mstr.city = uspo_zip_mstr.city 
            NO-LOCK NO-ERROR.
        /*If not possible then take whatever matches zip */
        IF NOT AVAILABLE vertex_zip_mstr THEN  
            FIND FIRST vertex_zip_mstr WHERE vertex_zip_mstr.zip_code =
            uspo_zip_mstr.zip_code NO-LOCK NO-ERROR.
        IF AVAILABLE(vertex_zip_mstr) THEN uspo_zip_mstr.county_name = 
            vertex_zip_mstr.county_name .
    END.
END PROCEDURE .


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

/*     /*test for alias match city for every alias */                                        */
/*     FOR EACH uspo_zip_mstr NO-LOCK WHERE city_alias_name <> city .                        */
/*         FIND FIRST b_uspo_zip_mstr WHERE b_uspo_zip_mstr.city = uspo_zip_mstr.city        */
/*             AND b_uspo_zip_mstr.city = b_uspo_zip_mstr.city_alias_name NO-LOCK NO-ERROR . */
/*     END.                                                                                  */
/*                                                                                           */
/*     IF NOT AVAILABLE b_uspo_zip_mstr THEN do:                                             */
/*         DISPLAY                                                                           */
/*         uspo_zip_mstr .                                                                   */
/*         DISPLAY                                                                           */
/*         b_uspo_zip_mstr.                                                                  */
/*     END.                                                                                  */


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

PROCEDURE p_print_line :
    DEF INPUT PARAMETER p-msg AS CHAR FORMAT "x(45)" .
    DEF INPUT PARAMETER p-print AS LOGICAL .
    IF 
        NOT
         p-print THEN RETURN.
    v_count = v_count + 1 .                                       

    EXPORT STREAM s-out DELIMITER "," 
        p-msg  
        vertex_zip_mstr.zip_code  WHEN AVAILABLE(vertex_zip_mstr)
        USPO_zip_mstr.zip_code    WHEN AVAILABLE(uspo_zip_mstr)
        vertex_zip_mstr.city      WHEN AVAILABLE(vertex_zip_mstr)
        USPO_zip_mstr.city         WHEN AVAILABLE(uspo_zip_mstr)
        vertex_zip_mstr.state      WHEN AVAILABLE(vertex_zip_mstr)
        USPO_zip_mstr.state     WHEN AVAILABLE(uspo_zip_mstr)  
        .      

END PROCEDURE.

PROCEDURE test-uspo .

    EXPORT STREAM s-out DELIMITER "," 
        "Result" "Vertex Zip" "USPO Zip"  "Vertex City" "USPO City" "Vertex state" "USPO State" .

    FOR EACH uspo_zip_mstr.
        FIND FIRST vertex_zip_mstr WHERE 
            uspo_zip_mstr.zip_code = vertex_zip_mstr.zip_code NO-LOCK NO-ERROR.
        IF NOT AVAILABLE(vertex_zip_mstr) THEN
            RUN p_print_line("Zip Miss; USPO Zip Code not in Vertex", YES) .
        IF AVAILABLE(vertex_zip_mstr)  THEN DO:
            FIND FIRST vertex_zip_mstr WHERE 
                uspo_zip_mstr.city = vertex_zip_mstr.city AND
                uspo_zip_mstr.zip_code = vertex_zip_mstr.zip_code NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE vertex_zip_mstr THEN DO:
                FIND FIRST vertex_zip_mstr WHERE 
                    uspo_zip_mstr.zip_code = vertex_zip_mstr.zip_code NO-LOCK NO-ERROR.
                    RUN p_print_line("Zip Hit; USPO City not in Vertex", yes ).
            END.
            FIND FIRST vertex_zip_mstr WHERE 
                uspo_zip_mstr.state = vertex_zip_mstr.state AND
                uspo_zip_mstr.zip_code = vertex_zip_mstr.zip_code NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE vertex_zip_mstr THEN
                    RUN p_print_line("Zip Hit; USPO state not in Vertex", yes ).
        END.
    END.
END PROCEDURE .
