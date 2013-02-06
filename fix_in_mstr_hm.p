
OUTPUT TO c:\temp\in_mstr_bad_hm.d . 

DISABLE TRIGGERS FOR LOAD OF IN_mstr .

FOR EACH IN_mstr WHERE IN_domain = "qp" AND
    IN_site = "hm" AND IN_qty_oh = 0 AND IN_qty_nonet = 0 . 
    EXPORT 
        IN_mstr .
/*     DELETE IN_mstr . */
END.
