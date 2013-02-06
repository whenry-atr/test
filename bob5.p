                                          default-window:width = 135.
DEFINE TEMP-TABLE u-track
    FIELD track_no AS CHAR
    INDEX track_no track_no . 

INPUT FROM c:\temp\11-9-ups.txt .
REPEAT:
    CREATE u-track.
    IMPORT u-track .
END.



FOR EACH suh_hist WHERE DATE_processed = 11/9/11 NO-LOCK.
    FIND FIRST so_track WHERE suh_hist.sls_ord = so_track.sls_ord
        AND site = "hm" NO-LOCK NO-ERROR.
    IF NOT AVAILABLE so_track  THEN NEXT .
    IF NOT tracking_no BEGINS("1z") THEN NEXT. 

    FIND FIRST u-track WHERE track_no = tracking_no NO-LOCK NO-ERROR.
    IF NOT AVAILABLE u-track  THEN
        DISPLAY suh_hist.sls_ord tracking_no .
END.

FOR EACH so_track WHERE so_track.sls_ord >= "rma27644"  NO-LOCK .
    FIND FIRST suh_hist WHERE site = "hm" AND suh_hist.sls_ord = so_track.sls_ord.
    DISPLAY date_processed 
        so_track.sls_ord WITH 3 COL WIDTH 132.
END.
