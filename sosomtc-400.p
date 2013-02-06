/* sosomtc2.p - SO TRAILER UPDATE LOWER FRAME                           */
/* Copyright 1986-2004 QAD Inc., Carpinteria, CA, USA.                  */
/* All rights reserved worldwide.  This is an unpublished work.         */
/* $Revision: 1.16 $                                                */
/*V8:ConvertMode=Maintenance                                            */
/* REVISION: 7.3      LAST MODIFIED: 02/22/93   BY: afs *G692**/
/* REVISION: 7.3      LAST MODIFIED: 06/11/93   BY: WUG *GB74**/
/* REVISION: 7.4      LAST MODIFIED: 08/19/93   BY: pcd *H009* */
/* REVISION: 7.4      LAST MODIFIED: 11/03/93   BY: bcm *H208**/
/* REVISION: 7.4      LAST MODIFIED: 10/28/94   BY: dpm *GN67**/
/* REVISION: 7.4      LAST MODIFIED: 11/14/94   BY: str *FT44**/
/* REVISION: 7.3      LAST MODIFIED: 03/16/95   BY: WUG *G0CW**/
/* REVISION: 8.5      LAST MODIFIED: 10/03/95   BY: taf *J053**/
/* REVISION: 8.5      LAST MODIFIED: 05/07/97   BY: *J1P5* Ajit Deodhar */
/* REVISION: 8.6      LAST MODIFIED: 05/20/98   BY: *K1Q4* Alfred Tan   */
/* REVISION: 9.1      LAST MODIFIED: 10/01/99   BY: *N014* Patti Gaultney */
/* REVISION: 9.1      LAST MODIFIED: 02/04/00   BY: *N07M* Vijaya Pakala  */
/* REVISION: 9.1      LAST MODIFIED: 03/24/00   BY: *N08T* Annasaheb Rahane */
/* REVISION: 9.1      LAST MODIFIED: 04/25/00   BY: *N0CG* Santosh Rao      */
/* REVISION: 9.1      LAST MODIFIED: 08/12/00   BY: *N0KN* myb              */
/* REVISION: 9.1      LAST MODIFIED: 11/03/00   BY: *L15F* Kaustubh K       */
/* Old ECO marker removed, but no ECO header exists *F0PN*                  */
/* Old ECO marker removed, but no ECO header exists *G013*                  */
/* Revision: 1.14  BY: Katie Hilbert DATE: 04/01/01 ECO: *P002* */
/* $Revision: 1.16 $ BY: Paul Donnelly (SB) DATE: 06/28/03 ECO: *Q00L* */
/*-Revision end---------------------------------------------------------------*/
/*ALDN* March 2008 */ 
/*    * Added Credit Card Processing                                          */ 
/*    * Move out due date if on hold                                          */
/*    * Ship Via immediately after credit card info                           */  

/******************************************************************************/
/* All patch markers and commented out code have been removed from the source */
/* code below. For all future modifications to this file, any code which is   */
/* no longer required should be deleted and no in-line patch markers should   */
/* be added.  The ECO marker should only be included in the Revision History. */
/******************************************************************************/

{mfdeclre.i}
{gplabel.i} /* EXTERNAL LABEL INCLUDE */

define shared variable  rndmthd like rnd_rnd_mthd.
define shared variable  prepaid_fmt as character no-undo.
define shared variable  so_recno    as   recid.
define shared variable  undo_mtc2   like mfc_logical.
define shared variable  new_order   like mfc_logical.
define shared frame     d.
define        variable  valid_acct  like mfc_logical.
define        variable  old_rev     like so_rev.
define        variable retval as integer no-undo.

{mfsotrla.i}
{sosomt01.i}  /* Define shared form for frame d */
so_prepaid:format = prepaid_fmt.
{sototfrmx.i} 

for first so_mstr
      fields( so_domain so_ar_acct so_ar_cc so_bol so_cr_card so_cr_init
             so_curr so_disc_pct so_inv_mthd
             so_fob so_fst_id so_partial
             so_prepaid so_print_pl so_to_inv
             so_print_so so_pst_id so_pst_pct so_rev so_shipvia
             so_stat so_tax_pct so_tr1_amt so_trl3_cd
             so_trl1_cd so_trl2_amt so_trl2_cd so_trl3_amt)
      where recid(so_mstr) = so_recno no-lock:
end. /* FOR FIRST so_mstr */

old_rev = so_rev.

do transaction on error undo, retry:

   find first so_mstr
      where recid(so_mstr) = so_recno exclusive-lock no-error.

   hide frame setd_sub no-pause.

 RUN p-set-ih .

   edi_ack = substring(so_inv_mthd,3,1) = "e".

   set
      so_cr_init
      so_cr_card
      so_stat when (so_stat =  "") WITH FRAME d.
   SETLOOP:
   DO ON ERROR UNDO, RETRY:
       /*ALDN - Broke set statement and added update credit card */  
       IF so_cr_card:SCREEN-VALUE > "" THEN
           RUN update_credit_card_info (INPUT so_nbr). 
       RUN disp_wt.
    
       SET
          so_shipvia
          so_rev
          so_partial
          so_print_so
          so_print_pl
          print_ih
          edi_ih            edi_edipo_ih
          so_ar_acct
          so_ar_sub
          so_ar_cc
          so_prepaid
          so_fob
          so_bol
       with frame d.
    
       /* If the shipvia is set to 100 (best way) and the freight terms is 3rdparty or collect then the
          cust pd account number  could be being used with the wring carrier.  In case the user needs to
          eithr change the shipvia to be something else or return to the previous frame and change the freight term*/
    
       IF so_shipvia = "100"  AND (so_fr_term = "3rdparty" OR so_fr_term = "collect")THEN DO:
           {pxmsg.i &MSGTEXT="""Shipvia=100 not allowed with 3rdparty/collect, change or go Back to terms"""
                    &ERR0RLEVEL=3}
           NEXT-PROMPT so_shipvia WITH FRAME d.
           UNDO, RETRY  .
       END.
   END.
   if (so_prepaid <> 0 ) then do:
      /* VALIDATE SO_PREPAID ACCORDING TO THE DOC CURRENCY ROUND MTHD*/
      {gprun.i ""gpcurval.p"" "(input so_prepaid,
                     input rndmthd,
                     output retval)"}
      if (retval <> 0) then do:
         next-prompt so_prepaid with frame d.
         undo, retry.
      end.
   end.

   if print_ih then do:
      if edi_ih then substring(so_inv_mthd,1,1) = "b".
      else substring(so_inv_mthd,1,1) = "p".
   end.
   else do:
      if edi_ih then substring(so_inv_mthd,1,1) = "e".
      else substring(so_inv_mthd,1,1) = "n".
   end.
   if edi_ack then substring(so_inv_mthd,3,1) = "e".
   else substring(so_inv_mthd,3,1) = "n".

   /* INITIALIZE SETTINGS */
   {gprunp.i "gpglvpl" "p" "initialize"}

   /* SET PROJECT VERIFICATION TO NO */
   {gprunp.i "gpglvpl" "p" "set_proj_ver" "(input false)"}

   /* ACCT/SUB/CC/PROJ VALIDATION */
   {gprunp.i "gpglvpl" "p" "validate_fullcode"
      "(input  so_ar_acct,
        input  so_ar_sub,
        input  so_ar_cc,
        input  """",
        output valid_acct)"}

   if valid_acct = no then do:
      next-prompt so_ar_acct with frame d.
      undo, retry.
   end.

   /* ACCOUNT CURRENCY MUST EITHER BE TRANSACTION CURR OR BASE CURR */
   if so_curr <> base_curr then do:

      for first ac_mstr
            fields( ac_domain ac_code ac_curr)
             where ac_mstr.ac_domain = global_domain and  ac_code = so_ar_acct
             no-lock:
      end.  /* FOR FIRST AC_MSTR */
      if available ac_mstr and
         ac_curr <> so_curr and ac_curr <> base_curr then do:
         {pxmsg.i &MSGNUM=134 &ERRORLEVEL=3}
         /*ACCT CURRENCY MUST MATCH TRANSACTION OR BASE CURR*/
         next-prompt so_ar_acct with frame d.
         undo, retry.
      end.
   end. /* IF SO_CURR <> BASE_CURR */

   /* Check for new revision and flip the print so flag. */
   if not new_order and old_rev <> so_rev then
      so_print_so = yes.
   
   /*MOVE OUT DUE DATE IF ON HOLD*/
   {gprun.i ""sosocdue.p"" "(so_nbr, true)"}
   
   /* This is not needed therefore I have commented it */
   /*RUN SEL MRP FOR SPECIAL MARKETS*/ 
   /*{gprun.i ""sosomrpx.p"" "(input so_nbr, '', '')"}*/

   undo_mtc2 = false.

end.
hide frame setd_sub no-pause.

/*ALDN Credit Card encrypt/Decrypt function */
{cccrptf.i}
{gprunpdf.i "gpccpl" "p"}

PROCEDURE update_credit_card_info. 
   DEF INPUT PARAMETER v_nbr LIKE so_nbr NO-UNDO. 
   
   DEF BUFFER som FOR so_mstr. 

   define variable vcCreditCard like socc_cc_nbr no-undo.
   define variable vOldTransactionNbr like socc__qadc01 no-undo.
   define variable vError as logical no-undo.
 
   FIND FIRST som NO-LOCK 
       WHERE som.so_domain = global_domain 
         AND som.so_nbr = v_nbr  NO-ERROR. 


    FIND FIRST ad_mstr NO-LOCK 
        WHERE ad_domain = global_domain 
          AND ad_addr = som.so_bill NO-ERROR. 
    FIND FIRST socc_mstr 
       WHERE socc_domain = som.so_domain
         AND socc_nbr    = som.so_nbr NO-ERROR. 
    IF NOT AVAILABLE socc_mstr THEN DO:
          CREATE socc_mstr. 
          ASSIGN 
               socc_domain = som.so_domain
               socc_nbr    = som.so_nbr 
                socc_billing_name    = ad_name
                socc_billing_addr1   = ad_line1
                socc_billing_addr2   = ad_line2
                socc_billing_addr3   = ad_line3
                socc_billing_city    = ad_city 
                socc_billing_state   = ad_state
                socc_billing_zip     = ad_zip 
                socc_billing_country = ad_country. 
          if recid (socc_mstr) = -1 then .
    END. /* IF NOT AVAILABLE socc_mstr THEN DO:*/ 

/*{gprun.i ""soccmt.p"" "(input so_nbr)"}. */
    IF socc_card_type = "" THEN
       socc_card_type = som.so_cr_card. 

    form
      vcCreditCard          colon 23
      socc_card_type        colon 62 skip
      socc_cc_expire_date   colon 23 skip
      socc_auth_date        colon 33 skip
      socc_auth_expire_date colon 33 skip
      socc_auth_nbr         colon 33 skip
      socc_auth_amt         colon 33 
    with frame bx side-labels OVERLAY width 80 ROW 14.
    /*N0Q0*/ /* SET EXTERNAL LABELS */
    /*N0Q0*/ setFrameLabels(frame bx:handle).
    
    form
      cctr_tx_type     colon 29
      cctr_status      colon 29
    with frame cx side-labels width 80 overlay row 14.
    /*N0Q0*/ /* SET EXTERNAL LABELS */
    /*N0Q0*/ setFrameLabels(frame cx:handle).
    
    view frame bx.

    MAINBLOCK:
    do on error undo, leave :
       hide frame cx.

          vcCreditCard = socc_cc_nbr.
          display
            vcCreditCard
            socc_card_type
            socc_cc_expire_date
            socc_auth_date
            socc_auth_expire_date
            socc_auth_nbr
            socc_auth_amt
          with frame bx.
    
       do on error undo, retry:
          vOldTransactionNbr = socc_auth_nbr.
          set
            vcCreditCard
            socc_card_type
            socc_cc_expire_date
            socc_auth_date
            socc_auth_expire_date
            socc_auth_nbr
            socc_auth_amt
          with frame bx.
    
          /*If it has not changed then it must still be encrypted so go ahead and
            decrypt at this point since we did not do so before */
          IF vcCreditCard = socc_cc_nbr THEN
              vcCreditcard = decryptCreditCardNbr(vcCreditCard) .

          {gprunp.i "gpccpl" "p" "validateCreditCardNumber"
                    "(input vcCreditCard, output vError)"}
          if vError THEN do:
            next-prompt vcCreditCard with frame bx.
            undo, retry.
          end.
    
          /*if socc_auth_nbr = "" then
          do:
            {mfmsg.i 3865 3} /*Authorization number can not be blank*/
            next-prompt socc_auth_nbr with frame bx.
            undo, retry.
          end.  */
    
        
          if socc_cc_expire_date = ? THEN do:
             {mfmsg.i 3477 3} /*Expire Date field is mandatory*/
             next-prompt socc_cc_expire_date with frame bx.
             undo, retry.
          end.
    
          if socc_cc_expire_date < today THEN do:
            {mfmsg.i 3480 2} /*CC expiration date less than current date*/
          end.
    
          if socc_auth_date = ? then do:
            {mfmsg.i 3478 3} /*Authorization Date field is mandatory*/
             next-prompt socc_auth_date with frame bx.
             undo, retry.
          end.
    
          if socc_auth_date < today then do:
            {mfmsg.i 3481 2} /*Authorization Date less than current date*/
          end.
    
          if socc_auth_expire_date = ? then  do:
            {mfmsg.i 3479 3} /*Authorization Expire Date field is mandatory*/
             next-prompt socc_auth_expire_date with frame bx.
             undo, retry.
          end.
    
          if socc_auth_expire_date < today THEN do:
            {mfmsg.i 3482 2} /*Authorization expiration date
                                     less than current date*/
          end.
          socc_cc_nbr = encryptCreditCardNbr(vcCreditCard).
          
    
          assign
             socc_mod_date = today
             socc_mod_userid = global_userid.
    
          /*Create Credit card transaction history record if
            authorization number is changed*/
          if vOldTransactionNbr <> socc_auth_nbr then do:
             create cctr_hist. cctr_hist.cctr_domain = global_domain.
             cctr_trnbr = next-value(cctr_sq01).
             if recid(cctr_hist) = -1 then .
    
             update
               cctr_tx_type
               cctr_status
             with frame cx.
             assign
               cctr_nbr = socc_nbr
               cctr_cc_nbr = socc_cc_nbr
               cctr_tx_date = today
               cctr_cust_txn = socc_auth_nbr
               cctr_amt = socc_auth_amt
               cctr_auth_expire_date = socc_auth_expire_date
               cctr_internal_tx = no
               cctr_tx_time = string(time,"hh:mm:ss")
               cctr_mod_date = today
               cctr_mod_userid = global_userid
             .
             hide frame cx.
          end.
       end. /*do on error ...*/
    
    end. /*MAINBLOCK*/
    hide frame bx.

END. /* procedure update_credit_card_info */

/*ALDN */
PROCEDURE disp_wt. 

         DEFINE VARIABLE v_Message     AS CHARACTER FORMAT "X(40)" NO-UNDO.
         DEFINE VARIABLE v_TotalCube   AS DECIMAL                  NO-UNDO.
         DEFINE VARIABLE v_TotalWeight AS DECIMAL                  NO-UNDO.
         define variable v_totalcarton as integer                  no-undo.
         define variable v_cartons     as integer                  no-undo.
         DEFINE VARIABLE v_qty_order   AS DECIMAL                  NO-UNDO. 
         define variable old_fr_terms  like so_fr_terms.

         DEF BUFFER ptm FOR pt_mstr.
         DEF BUFFER sodx FOR sod_det. 

         assign v_TotalCube = 0.0
                v_TotalWeight = 0.0
                v_totalcarton = 0.
                
         FOR EACH sodx NO-LOCK 
              WHERE sodx.sod_domain = global_domain 
                AND sodx.sod_nbr = so_mstr.so_nbr: 
           FIND FIRST ptm  NO-LOCK 
           WHERE ptm.pt_domain = global_domain 
             AND ptm.pt_part = sodx.sod_part NO-ERROR. 

           IF AVAILABLE ptm THEN DO:
             v_qty_order = sod_qty_ord * sod_um_conv.
             if v_qty_order = 0 then
               v_cartons = 0.
             else do:
               find first um_mstr where um_domain = global_domain 
                                    AND um_part = ptm.pt_part 
                                  and um_um     = ptm.pt_um
                                  and ((um_alt_um = "cs")
                                       or (um_alt_um = "CA"))
                                  no-lock no-error.
               if available(um_mstr) then do:
                 v_cartons = truncate(v_qty_order / um_conv,0).
                 if (v_qty_order / um_conv) > v_cartons then
                   v_cartons = v_cartons + 1.
               end.
               else do:
                 v_cartons = v_qty_order.
               end.
             end.
               
             ASSIGN v_TotalCube   = v_TotalCube
                                  + (v_qty_order
                                  * ptm.pt_size)
                    v_TotalWeight = v_TotalWeight
                                  + (v_qty_order
                                  * ptm.pt_ship_wt)
                    v_totalcarton = v_totalcarton + v_cartons.  
           END. /*IF AVAILABLE ptm THEN*/
         END. /*FOR EACH sodx WHERE sodx.sod_nbr = so_mstr.so_nbr... */
    
         ASSIGN v_Message
           = "TOT WT: "
           + STRING(v_TotalWeight)
           + " :: "
           + "TOT CUBE: "
           + STRING(v_TotalCube)
           + " :: TOT CARTONS: "
           + string(v_totalcarton).
           
         {pxmsg.i &MSGTEXT=v_message &ERRORLEVEL=1} 

END. /*PROCEDURE disp_wt:*/

PROCEDURE p-set-ih .
    /* Codes have been created to allow mixed (EDI-Print) invoiceing for a customer.
       The two new codes allow for EDI invoice (810) when the order received EDI (850)
       and print invoice when the order came in manually.  The codes are 
       C - EDI received orders are both printed and EDI's 
       D - EDI received orders are only EDI's
       They are possible when the flage (edi_edipo_ih) is set to indicate that EDI invoices
       are only sent when the order came in via EDI.
       
       Note that in both above cases non EDI received orders are printed */
       ASSIGN
           edi_ih = NO
           edi_edipo_ih = NO
           print_ih = NO .   
    
       IF so_mstr.so_inv_mthd = "E" OR
          so_mstr.so_inv_mthd = "B" OR 
          so_mstr.so_inv_mthd = "C" OR
          so_mstr.so_inv_mthd = "D" THEN 
            edi_ih = YES.
       IF so_mstr.so_inv_mthd = "B" OR 
          so_mstr.so_inv_mthd = "C" OR
          so_mstr.so_inv_mthd = "P"  THEN 
            print_ih = YES .
       IF so_mstr.so_inv_mthd = "C" OR
          so_mstr.so_inv_mthd = "D" THEN 
             edi_edipo_ih = YES .

END PROCEDURE.

PROCEDURE p-set-invmthd .

    DEFINE OUTPUT PARAMETER p_err_msg AS CHAR.
    /*If the order is never intended to go out EDI (i.e . edi_ih = NO) there is no point
    in edi_edipo_ih = YES so this condition returns an error message */
    IF edi_edipo_ih AND NOT edi_ih THEN DO:
        p_err_msg = "'EDI Inv when EDI PO' flag cannot be YES if invoices not EDI " .
        RETURN.
    END.

    IF NOT edi_edipo_ih THEN DO:
        /* regular codes apply */
        if print_ih then do:
            if edi_ih then ad_mstr.ad_inv_mthd = "b".
            else so_mstr.so_inv_mthd = "p".
        end.
        else do:
            if edi_ih then so_mstr.so_inv_mthd = "e".
            else so_mstr.so_inv_mthd = "n".
        end.
     END. /*if not edi_edipo_ih */
     ELSE DO:
        IF edi_ih AND print_ih THEN  so_mstr.so_inv_mthd = "C" .
        IF edi_ih AND NOT print_ih   THEN so_mstr.so_inv_mthd = "D" .
     END.
     
END PROCEDURE .
