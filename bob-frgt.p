default-window:width = 135.

DEF STREAM s-out.
DEF VAR v_sim AS CHAR.

OUTPUT STREAM s-out TO c:\temp\bob-frgt-curr.txt .
EXPORT STREAM s-out DELIMITER "," "Part" "Cost Element" "Total Cost (TL + LL)" "Site" "Cost Set".

v_sim = "current" .


FOR EACH spt_det NO-LOCK WHERE spt_domain = "qp" AND spt_site = "02" AND 
    spt_sim = v_sim AND spt_element BEGINS("FRGT")  . 
/*     DISPLAY */
    EXPORT STREAM s-out DELIMITER "," 
        spt_part spt_element spt_cst_tl + spt_cst_ll spt_site spt_sim 
/*         WITH WIDTH 132 */
        .
END.
