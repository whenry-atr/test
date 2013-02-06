/* xxcalc16.p - CALCULATE TAX FOR AR INVOICE FROM INVOICE HISTORY            */
/* Copyright 1986-2002 QAD Inc., Carpinteria, CA, USA.                       */
/* All rights reserved worldwide.  This is an unpublished work.              */
/*V8:ConvertMode=Maintenance                                                 */
/*K1Q4*/ /*V8:RunMode=Character,Windows                                      */
/* REVISION: 8.6        CREATED:       08/19/97   BY: *K0HJ* Jeff Wootton    */
/* REVISION: 8.6        MODIFIED:      10/23/97   BY: *K0JV* Surendra Kumar  */
/* REVISION: 8.6        MODIFIED:      05/20/98   BY: *K1Q4* Alfred Tan      */
/* REVISION: 9.1        MODIFIED:      08/12/00   BY: *N0KC* myb             */
/* REVISION: 9.1        MODIFIED:      02/18/02   BY: *M1NG* Niall Shanahan  */
/* REVISION:            MODIFIED:      09/30/02   BY: *RSH*                  */
/*****************************************************************************/


         {mfdeclre.i}
         {txcaldef.i}

         /* SET RECORD ACCESS VARIABLE FROM TXCALC PARAMETER(S) */
         /*K0JV*/ define variable vq-txc-ref        as character     NO-UNDO.
         mstr_ref = txc_ref.

         /* FIND TRANSACTION */
         find first ih_hist where ih_inv_nbr = mstr_ref
         no-lock no-error.
         if not available ih_hist then do:
/*M1NG* REPLACE mfmsg**.i WITH pxmsg.i *
.            {mfmsg.i 1999 4 mstr_ref} /* INVOICE HISTORY DOES NOT EXIST */
*M1NG*/
/*M1NG*/    {pxmsg.i
               &MSGNUM = 1999
               &ERRORLEVEL = 4

            }
            undo.
         end.
/*rsh*/  assign cmvd-addr = ih_cust.
         /* SET TAX DATE */
         if ih_tax_date <> ? then
            tax_date = ih_tax_date.
         else
            tax_date = ih_inv_date.

         tax_gl_date = ih_inv_date.

         find ct_mstr where ct_code = ih_cr_terms no-lock no-error.
         if available ct_mstr then inv_disc_pct = ct_disc_pct.

/*RSH* add these lines on the lines of jzj code*/
         if txc_tr_type = "16" and vq-post then
         assign vq-txc-ref = txc_ref
                   txc_ref = txc_nbr
                   txc_nbr = vq-txc-ref.
         {txtrlchk.i
            &mstr_prefix = "ih"
            output last-trlr}
/*RSH END*/
/*K0JV*/  /* ADD QUANTITY */
         /* SET TAX VARIABLES AND CALC4~ULATE TAX */

        {xxcalca.i &det_prefix = "idh"
                     &mstr_prefix = "ih"     /* ih_hist.ih */ 
                     &det_file    = "idh_hist"
                     &det_key     = "idh_inv_nbr"
                     &det_index   = "idh_invln"
                     &tax_qty     = "(idh_qty_inv
                                    * (idh_price * (1 - (ih_disc_pct / 100))))"
                     &taxable     = "idh_taxable"
                     &ship_to1    = "ih_ship"
                     &ship_to2    = "ih_cust"
                     &ship_from1  = "idh_site"
                     &ship_from2  = """"
                     &qty         = "idh_qty_inv"}
             /* INCLUDE FILE TO LOOP THROUGH TRAILERS */
             {txcaltrl.i &mstr_prefix = "ih"
                     &ship_to1    = "ih_ship"
                     &ship_to2    = "ih_cust"
                     &ship_from1  = "ih_site"
                     &ship_from2  = """"}
               
/*EZ0364*RSH* based on jzj logic add these lines*/
/*K0JV*/ /* IF THE TRANSACTION TYPE IS '16', FLIP THE VALUES OF TXC_REF
 *              AND TXC_NBR BACK */

 /*K0JV*/    if txc_tr_type = "16" and vq-post then 
 /*K0JV*/        assign vq-txc-ref = txc_ref
 /*K0JV*/                txc_ref = txc_nbr
 /*K0JV*/                txc_nbr = vq-txc-ref.
 /*EZ0364*RSH* END ADD */
