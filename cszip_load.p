default-window:width = 135.
DEF VAR v_count AS INTEGER .
DEF VAR v_count1 AS INTEGER .
DEF VAR v_count2 AS INTEGER .
DEF VAR v_count3 AS INTEGER . 
DEF VAR v_count4 AS INTEGER . 

DEF TEMP-TABLE uspo_zip_mstr LIKE cszip_mstr 
    FIELD city_alias_abrev  AS CHAR
    FIELD city_alias_name   AS CHAR
    INDEX address state city county_name 
    INDEX zip-city zip_code city
    INDEX zip-state zip_code state
    INDEX zip-st-city zip_code  state city county_name 
    INDEX city-name city .


DEF TEMP-TABLE vertex_zip_mstr LIKE cszip_mstr 
    FIELD zip_end AS CHAR 
    INDEX address state city county_name 
    INDEX city zip_code city
    INDEX state zip_code state
    INDEX zip zip_code city state county_name .

DEF BUFFER b_vertex_zip_mstr FOR TEMP-TABLE vertex_zip_mstr . 
DEF BUFFER b_uspo_zip_mstr FOR TEMP-TABLE uspo_zip_mstr .

/* Load the temp table with all of the Vertex information */
RUN p_load_vertex .

/*Load a similar table for the USPO data*/
RUN p_load_uspo .

/*Modify the county names in the USPO table to be the names from vertex*/
RUN p_load_vertex_county_name .

/*modify the existing cszip_mstr to match current */
RUN p_load_cszip .

/*update the QAD county name to match those in the USPO table by using 
  the modified cszip */
RUN p_update_qad_county.


PROCEDURE p_update_qad_county.
    DISABLE TRIGGERS FOR LOAD OF ad_mstr .
    FOR EACH ad_mstr  WHERE ad_domain = "qp" AND
        ( ad_type = "customer"  OR ad_type = "ship-to" ).

        /* Must match city name and zip for vertex purposes  */
        FIND FIRST cszip_mstr NO-LOCK  WHERE
            cszip_mstr.zip_code = ad_zip  AND
              ad_city = cszip_mstr.city  NO-ERROR .

        IF AVAILABLE(cszip_mstr) AND
            ad_county <>  cszip_mstr.county_name
            THEN DO:
               v_count4 = v_count4 + 1 .
               ad_county =  trim(cszip_mstr.county_name) .
        END.
    END.
END PROCEDURE .




PROCEDURE p_load_cszip .
    /* Are there records in our file that are not in the USPO one */
    FOR EACH cszip_mstr .
        FIND FIRST uspo_zip_mstr WHERE
           cszip_mstr.zip_code = uspo_zip_mstr.zip_code AND
           cszip_mstr.city = uspo_zip_mstr.city AND
           cszip_mstr.state = uspo_zip_mstr.state NO-ERROR .
        IF  NOT AVAILABLE uspo_zip_mstr THEN DO:
            v_count = v_count + 1  .
            DELETE cszip_mstr .
        END.
    END.


    /* Are there records which uspo has that we do not */
    FOR EACH uspo_zip_mstr.
        FIND  cszip_mstr WHERE
           cszip_mstr.zip_code = uspo_zip_mstr.zip_code AND
           cszip_mstr.city = uspo_zip_mstr.city AND
           cszip_mstr.state = uspo_zip_mstr.state NO-ERROR .
        IF  NOT AVAILABLE cszip_mstr THEN DO:
            v_count1 = v_count1 + 1  .
            CREATE cszip_mstr .
            BUFFER-COPY uspo_zip_mstr TO cszip_mstr .
        END.
        /*got a hit , is everthing the same */ 
        ELSE DO:
            v_count2 = v_count2 + 1 . 
            IF 
                cszip_mstr.county_name <> uspo_zip_mstr.county_name OR
                cszip_mstr.county <> uspo_zip_mstr.county OR
                cszip_mstr.post_type <> uspo_zip_mstr.post_type 
                THEN DO:
                v_count3 = v_count3 + 1 .

                ASSIGN
                    cszip_mstr.county   = uspo_zip_mstr.county
                    cszip_mstr.county_name =  uspo_zip_mstr.county_name
                    cszip_mstr.post_type =  uspo_zip_mstr.post_type .
            END.
        END.
    END.

    DISPLAY "Extra in cszip need to delete " v_count   SKIP
            "missing from cszip ned to create " v_count1      SKIP
            "Yes in cszip " v_count2                             SKIP
            "To be updated from uspo " v_count3 SKIP 
             "AD masters updated with changed county names " v_count4 WITH NO-LABEL. 

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
            city  state county_name ^
            ^  city_alias_abrev city_alias_name 
            ^ ^ ^ ^ county 
            ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ post_type.
        /*eliminate all the records we do not need */
         IF 
             post_type <> "P"  AND 
             post_type <> "b"  AND
             post_type <> "u"  AND
             post_type <> "n"  
         THEN DO:
             DELETE uspo_zip_mstr .
             NEXT .
         END.

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
