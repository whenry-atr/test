/* Zip Exists  ADdress MAtches   Action */
/*     YES         YES               Make No changes                         */
/*     YES         NO                Test address AND IF hit THEN change ZIP if not then print */
/*     NO          YES               Test address AND IF hit THEN change zip */
/*     NO          NO                Print Only                              */
DEF STREAM s-out .

OUTPUT STREAM s-out TO c:\temp\fix-zip-new.txt .

default-window:width = 220.

DEF VAR msg AS CHAR FORMAT "x(45)" .
DEF VAR v_count AS INTEGER . 
DEF VAR v_state AS CHAR.
DEF VAR v_city AS CHAR .
DEF VAR v_county AS CHAR .
DEF VAR v_ad_cmp_state AS LOGICAL .  
DEF VAR v_ad_cmp_county AS LOGICAL .  
DEF VAR v_ad_cmp_city AS LOGICAL .  

DEF TEMP-TABLE zip_mstr LIKE cszip_mstr 
    FIELD zip_end AS CHAR 
    INDEX address state city county_name 
    INDEX zip zip_code city state county_name .

DEF BUFFER b_zip_mstr FOR TEMP-TABLE zip_mstr . 

FORM
    WITH FRAME a DOWN . 

EXPORT STREAM s-out DELIMITER "," 
    "Result" "Cust #" "Cust Name" "AD Tax Zone" "Tax usage" "AD Address" "AD City" "Zip City" "AD State" "Zip State"
                     "Ad County" "Zip County" 
                      "AD Zip" "Zip Zip" . 

RUN p_load_zip .    
    
/* FOR EACH b_zip_mstr WHERE zip_code >= "06601"  AND zip_code <= "06610" . */
/*     DISPLAY b_zip_mstr WITH WIDTH 132 .                                  */
/* END.                                                                     */
/* QUIT .                                                                   */

FOR EACH ad_mstr WHERE ad_type = "customer" 
    AND ad_domain = "qp" 
/*     AND   (ad_addr >= "13140003" AND ad_addr <= "13150000" )  */
    NO-LOCK .
    /* forget those with "Do not use " or " use acc t ...." in them */
    IF ad_sort MATCHES(" use ") OR ad_sort begins("use") THEN NEXT .
    ASSIGN
        v_state = ""            
        v_city = ""
        v_county = ""
        v_ad_cmp_state = yes
        v_ad_cmp_county = YES
        v_ad_cmp_city   = YES .

    /*if the state is labeled as one we do not validate then forget it and move on */
    FIND FIRST CODE_mstr WHERE CODE_domain = "qp" AND
        CODE_fldname = "ad_state_nv" AND code_value = ad_state NO-LOCK NO-ERROR .
    IF AVAILABLE CODE_mstr OR ad_state = "." THEN NEXT .

    FIND FIRST zip_mstr NO-LOCK WHERE zip_code = substring(ad_zip,1,5)
         AND ad_county = county_name   NO-ERROR .
    IF AVAILABLE zip_mstr THEN DO:                 /* got valid zip */
        ASSIGN
            v_state = state               /*save hits from zip for display */
            v_city = city
            v_county = county_name .
        RUN p_print_line ("Zip hit; Address hit",NO) .   /*hurrah eveything matches */
     NEXT. 
     END. /* everything matches */
   

    FIND FIRST zip_mstr NO-LOCK WHERE zip_code = substring(ad_zip,1,5) NO-ERROR . /* see if the zip is even valid */
    IF AVAILABLE zip_mstr THEN  DO:        /* If there is one for that address then use it */
         ASSIGN
            v_state = state                     /*save hits from zip for display */
            v_city = city
            v_county = county_name .
            /*determine which one(s) did not match */ 
            FIND FIRST zip_mstr NO-LOCK WHERE 
                    ad_state = state 
                AND ad_city = city
                AND ad_county = county_name  NO-ERROR .
            IF AVAILABLE zip_mstr AND zip_code <> ad_zip THEN DO:                 /* got valid zip for aaddress */
               RUN p_print_line ("Zip hit but does not match address; Address hit",YES) .   /*zip not right needs to be changed to match address */
            END.
            ELSE
               RUN p_print_line ("Zip hit but does match address; Address Miss",YES) .
    NEXT .
   END. /*Valid zip code */
  

 /*zip not valid */
  FIND FIRST zip_mstr NO-LOCK WHERE  
           ad_state = state 
       AND ad_city = city
       AND ad_county = county_name  NO-ERROR .
   IF AVAILABLE zip_mstr  THEN DO:
        ASSIGN
          v_state = state                  /*save hits from zip for display */
          v_city = city
          v_county = county_name .
       RUN p_print_line ("Zip miss; Address hit",YES) .  /*but the address does exist so zip to be changed */
   END.
   ELSE  /* Miss miss */
      RUN p_print_line ("Zip Miss; Address Miss",YES) .
    
END .  /* for each ad_mstr of type customer*/

PROCEDURE p_print_line :
    DEF INPUT PARAMETER p-msg AS CHAR FORMAT "x(45)" .
    DEF INPUT PARAMETER p-print AS LOGICAL .
    IF 
        NOT
         p-print THEN RETURN.
    v_count = v_count + 1 .                                       

    EXPORT STREAM s-out DELIMITER "," 
        p-msg                              
        ad_mstr.ad_addr  
        ad_mstr.ad_sort
        ad_mstr.ad_tax_zone
        ad_mstr.ad_tax_usage
        IF ad_mstr.ad_line3  <> "" THEN ad_mstr.ad_line3 ELSE
           ad_mstr.ad_line2
        ad_city                                           
        v_city
        ad_state                                          
        v_state        
        ad_county                                         
        v_county  
        ad_zip    
        IF AVAILABLE zip_mstr THEN zip_mstr.zip_code  ELSE ""   
          .      

                                                                             
END PROCEDURE.


PROCEDURE p_load_zip . 
    DEF VARIABLE v_index AS INTEGER .
    INPUT FROM c:\temp\expanded_city.csv .
    IMPORT ^ .  /*skip header */
    REPEAT:
        CREATE zip_mstr .
        IMPORT DELIMITER "," 
            zip_code zip_end 
            city  county_name  state county
            . /*explode any zip code ranges */ 
        v_index = integer(zip_end) - integer(zip_code) .

        DO WHILE v_index > 0 . 

            CREATE b_zip_mstr.
            BUFFER-COPY zip_mstr TO b_zip_mstr .
            b_zip_mstr.zip_code 
                = string(integer(zip_mstr.zip_code) + v_index, "99999") .
            v_index = v_index - 1 .
           
        END.
    END.     

END.
