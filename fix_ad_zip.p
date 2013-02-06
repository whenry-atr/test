/* Zip Exists  ADdress MAtches   Action */
/*     YES         YES               Make No changes                         */
/*     YES         NO                Test address AND IF hit THEN change ZIP if not then print */
/*     NO          YES               Test address AND IF hit THEN change zip */
/*     NO          NO                Print Only                              */

OUTPUT TO c:\temp\fix-zip.txt .
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
    INDEX address state city county_name 
    INDEX zip zip_code city state county_name .

FORM
    WITH FRAME a DOWN . 

EXPORT DELIMITER "," "Result" "Cust #" "Cust Name" "AD Address" "AD City" "Zip City" "AD State" "Zip State"
                     "Ad County" "Zip County" "Cmp St" "Cmp County" "Cmp City" 
                      "AD Zip" "Zip Zip" . 

RUN p_load_zip .    
    
FOR EACH ad_mstr WHERE ad_type = "customer" NO-LOCK .
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

    FIND FIRST zip_mstr NO-LOCK WHERE zip_code = substring(ad_zip,1,5)  NO-ERROR .
    IF AVAILABLE zip_mstr THEN DO:                 /* got valid zip */
        ASSIGN
            v_state = state               /*save hits from zip for display */
            v_city = city
            v_county = county_name .
        IF  ad_state = state        
            AND ad_city = city         
            AND ad_county = county_name  THEN  RUN p_print_line ("Zip hit; Address hit",NO) .   /*hurrah eveything matches */
        ELSE  DO: /* If there is one for that address then use it */
            /*determine which one(s) did not match */

            IF ad_state <> state THEN v_ad_cmp_state = NO .  
            IF  ad_county <>  county_name THEN  v_ad_cmp_county = NO .  
            IF ad_city <> city THEN     v_ad_cmp_city = NO .

            FIND FIRST zip_mstr NO-LOCK WHERE 
                    ad_state = state 
                AND ad_city = city
                AND ad_county = county_name  NO-ERROR .
            IF AVAILABLE zip_mstr AND zip <> ad_zip THEN DO:                 /* got valid zip for aaddress */
               RUN p_print_line ("Zip hit but does not match address; Address hit",YES) .   /*zip not right needs to be changed to match address */
            END.
            ELSE
               RUN p_print_line ("Zip hit but does match address; Address Miss",YES) .
        END.
   END. /*Valid zip code */
   ELSE DO:  /*zip not valid */
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
    END.
END .  /* for each ad_mstr of type customer*/

PROCEDURE p_print_line :
    DEF INPUT PARAMETER p-msg AS CHAR FORMAT "x(45)" .
    DEF INPUT PARAMETER p-print AS LOGICAL .
    IF NOT p-print THEN RETURN.
    v_count = v_count + 1 .                                       

    EXPORT DELIMITER "," 
        p-msg                              
        ad_mstr.ad_addr  
        ad_mstr.ad_sort
        IF ad_mstr.ad_line3  <> "" THEN ad_mstr.ad_line3 ELSE
           ad_mstr.ad_line2
        ad_city                                           
        v_city
        ad_state                                          
        v_state        
        ad_county                                         
        v_county 
        v_ad_cmp_state
        v_ad_cmp_county
        v_ad_cmp_city 
        ad_zip    
        IF AVAILABLE zip_mstr THEN zip_mstr.zip  ELSE ""   
          .      

/*     DISPLAY     p-msg             LABEL "Result"                                                          */
/*                 ad_mstr.ad_addr                                                                           */
/*                 ad_city                                                                                   */
/*                 IF AVAILABLE zip_mstr THEN zip_mstr.city  ELSE ""     LABEL "Zmast City"   FORMAT "x(15)" */
/*                 ad_state                                                    FORMAT "x(2)"                 */
/*                 IF AVAILABLE zip_mstr THEN state  ELSE ""             LABEL "ZState"  FORMAT "x(6)"       */
/*                 ad_county                                                                                 */
/*                 IF AVAILABLE zip_mstr THEN county_name  ELSE ""      LABEL "Zmast County"  FORMAT "x(15)" */
/*                 ad_zip                                               FORMAT "x(5)"                        */
/*                 IF AVAILABLE zip_mstr THEN zip  ELSE ""              LABEL "Zzip"  FORMAT "x(5)"          */
/*                 v_count                                              LABEL "#" FORMAT ">>,>>9"            */
/*             WITH FRAME a DOWN WIDTH 218.                                                                  */
/*     DOWN 1 WITH FRAME a .                                                                                 */
END PROCEDURE.


PROCEDURE p_load_zip . 
    INPUT FROM c:\temp\zip-codes.csv .
    IMPORT ^ .  /*skip header */
    REPEAT:
        CREATE zip_mstr .
        IMPORT DELIMITER "," 
            zip_code city state county_name
            ^ ^ ^ ^ ^ ^ ^ ^ ^
            county.
    END.

    MESSAGE "load done" . 
END.
