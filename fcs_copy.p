DISABLE TRIGGERS FOR LOAD OF fcs_sum . 

default-window:width = 135.
DEF VAR v_i AS INTEGER. 

FOR EACH pt_mstr WHERE pt_domain = "qp" AND pt_prod_line = "E713" NO-LOCK .

    FOR EACH fcs_sum WHERE fcs_domain = "qp" AND fcs_site = "32" and
        fcs_year = 2012 AND fcs_part = pt_part . 
        v_i = v_i + 1 . 
        DISPLAY fcs_part .
    /*     DISPLAY fcs_site fcs_part  */
    /*         fcs_fcst_qty[32]       */
    /*         fcs_fcst_qty[33]       */
    /*         fcs_fcst_qty[34]       */
    /*         fcs_fcst_qty[35]       */
    /* /*            fcs_fcst_qty */  */
    /*          WITH 3 COL WIDTH 132. */
    
/*     ASSIGN                                      */
/*         /*September */                          */
/*            fcs_fcst_qty[36] =  fcs_fcst_qty[32] */
/*            fcs_fcst_qty[37] =  fcs_fcst_qty[33] */
/*            fcs_fcst_qty[38] =  fcs_fcst_qty[34] */
/*            fcs_fcst_qty[39] =  fcs_fcst_qty[35] */
/*         /*October */                            */
/*            fcs_fcst_qty[40] =  fcs_fcst_qty[32] */
/*            fcs_fcst_qty[41] =  fcs_fcst_qty[33] */
/*            fcs_fcst_qty[42] =  fcs_fcst_qty[34] */
/*            fcs_fcst_qty[43] =  fcs_fcst_qty[35] */
/*            fcs_fcst_qty[44] =  fcs_fcst_qty[35] */
/*         /*November */                           */
/*            fcs_fcst_qty[45] =  fcs_fcst_qty[32] */
/*            fcs_fcst_qty[46] =  fcs_fcst_qty[33] */
/*            fcs_fcst_qty[47] =  fcs_fcst_qty[34] */
/*            fcs_fcst_qty[48] =  fcs_fcst_qty[35] */
/*         .                                       */
    END.

END. 

DISPLAY v_i . 
