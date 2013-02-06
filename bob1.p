/* wow I do not understand GIT */


FOR EACH ih_hist 
/*     FIELDS(ih_inv_nbr ih_inv_date ih_fr_terms) */
    WHERE ih_domain = "qp" 
   and ih_inv_date > 9/1/04 AND ih_inv_date < 8/31/5
    .
    IF LENGTH(ih_fr_terms)  > 8 THEN  DO:
        DISPLAY ih_inv_nbr ih_inv_date ih_fr_terms FORMAT "x(15)" 
           LENGTH(ih_fr_terms) . 
    UPDATE ih_fr_terms .

    END. 
END.
