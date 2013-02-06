 default-window:width = 135.
OUTPUT  TO c:\temp\change-price-manual.txt .
DISABLE TRIGGERS FOR LOAD OF pi_mstr . 
FOR EACH pi_mstr WHERE
    pi_domain = "qp" AND 
    pi_list = "h-aaa" AND
    pi_cs_code = "h-custs" .

    EXPORT pi_mstr. 
    pi_manual = YES .


END.
