DEF VAR v_part AS CHAR. 
DEF VAR v_pos AS INTEGER . 
DEF STREAM s-image . 
DEF STREAM s-in .
DEF STREAM s-dir .
DEF STREAM s-gall. 

DEF TEMP-TABLE t-imageList
    FIELD imageName AS CHAR FORMAT "x(40)" . 

INPUT STREAM s-in FROM c:\temp\web-parts.csv .
INPUT STREAM s-dir FROM OS-DIR("c:\temp\images") . 
OUTPUT STREAM s-image TO c:\temp\productImageLoad.csv . 
OUTPUT STREAM s-gall TO c:\temp\galleryImageLoad.csv .

EXPORT STREAM s-image DELIMITER "," "sku",..aasda
EXPORT STREAM s-gall DELIMITER "," "##CPI" "sku" "image_url" "label" "position" .

RUN p-getImageList . 

RUN p-create-file . 


PROCEDURE p-getImageList.
    DEF VAR v_bob AS CHAR . 
    REPEAT:
        CREATE t-imageList.
        IMPORT STREAM s-dir imageName .
    END.
END.



PROCEDURE p-create-file. 
    IMPORT STREAM s-in ^ .
    
    REPEAT :
        IMPORT STREAM s-in DELIMITER "," v_part. 
        FIND FIRST cp_mstr WHERE cp_domain = "qp" AND cp_cust = "" AND
            cp_part = v_part NO-LOCK NO-ERROR.
        IF NOT AVAILABLE cp_mstr THEN  NEXT.
        v_pos = 0 .
        FOR EACH t-imageList WHERE imageName BEGINS(cp_cust_part) .
            /* If this is a the bas image write the correct file*/
            IF imageName = cp_cust + ".jpg" THEN
            /*if not a base image it must be a gallery aditional image */
            ELSE do:
                v_pos = v_pos + 1 . 
                EXPORT STREAM s-gall ;klkl;lk;.  
            END.
        END.
    END.
    
END PROCEDURE. 
