/* sosotrle.p - DISPLAY INVOICE TRAILER                                       */
/* Copyright 1986-2007 QAD Inc., Carpinteria, CA, USA.                        */
/* All rights reserved worldwide.  This is an unpublished work.               */
/* REVISION: 8.5      CREATED:       08/05/96   BY: jpm *J13Q*                */
/* REVISION: 8.6      CREATED:       11/25/96   BY: jzw *K01X*                */
/* REVISION: 8.6      CREATED:       10/09/97   BY: *K0JV* Surendra Kumar     */
/* REVISION: 8.6   LAST MODIFIED:    01/15/98   BY: *J2B2* Manish  K.         */
/* REVISION: 8.6E  LAST MODIFIED:    02/23/98   BY: *L007* A. Rahane          */
/* REVISION: 8.6E  LAST MODIFIED:    03/13/98   BY: *J2B5* Samir Bavkar       */
/* REVISION: 8.6E  LAST MODIFIED:    05/05/98   BY: *L00L* Ed vdGevel         */
/* REVISION: 8.6E  LAST MODIFIED:    05/09/98   BY: *L00Y* Jeff Wootton       */
/* REVISION: 8.6E  LAST MODIFIED:    07/16/98   BY: *L024* sami Kureishy      */
/* REVISION: 8.6E  LAST MODIFIED:    01/22/99   BY: *J38T* Poonam Bahl        */
/* REVISION: 8.6E  LAST MODIFIED:    02/10/99   BY: *L0D4* Satish Chavan      */
/* REVISION: 8.6E  LAST MODIFIED:    02/16/99   BY: *J3B4* Madhavi Pradhan    */
/* REVISION: 8.6E  LAST MODIFIED:    05/07/99   BY: *J3DQ* Niranjan R.        */
/* REVISION: 9.0   LAST MODIFIED:    02/24/00   BY: *M0K0* Ranjit Jain        */
/* REVISION: 9.1   LAST MODIFIED:    03/24/00   BY: *N08T* Annasaheb Rahane   */
/* REVISION: 9.1   LAST MODIFIED:    03/30/99   BY: *N06R* Sandy Brown        */
/* REVISION: 9.1   LAST MODIFIED:    04/25/00   BY: *N0CG* Santosh Rao        */
/* REVISION: 9.1   LAST MODIFIED:    07/06/00   BY: *N0F4* Mudit Mehta        */
/* REVISION: 9.1   LAST MODIFIED:    09/05/00   BY: *N0RF* Mark Brown         */
/* REVISION: 9.1   LAST MODIFIED:    09/06/00   BY: *N0D0* Santosh Rao        */
/* REVISION: 9.1   LAST MODIFIED:    10/11/00   BY: *N0WC* Mudit Mehta        */
/* Revision: 1.27       BY: Katie Hilbert       DATE: 04/01/01  ECO: *P002*   */
/* Revision: 1.28       BY: Sandeep P.          DATE: 04/06/01  ECO: *M14W*   */
/* Revision: 1.29       BY: Vihang Talwalkar    DATE: 06/13/01  ECO: *M17R*   */
/* Revision: 1.30       BY: Ellen Borden        DATE: 07/09/01  ECO: *P007*   */
/* Revision: 1.31       BY: Kaustubh K.         DATE: 07/26/01  ECO: *M1DS*   */
/* Revision: 1.32       BY: Seema Tyagi         DATE: 12/27/01  ECO: *M1RR*   */
/* Revision: 1.33       BY: Mark Christian      DATE: 02/07/02  ECO: *N18X*   */
/* Revision: 1.34       BY: Jean Miller         DATE: 04/10/02  ECO: *P058*   */
/* Revision: 1.35       BY: Vinod Nair          DATE: 11/19/02  ECO: *P0K0*   */
/* Revision: 1.36       BY: Laurene Sheridan    DATE: 12/10/02  ECO: *M219*   */
/* Revision: 1.37       BY: Mamata Samant       DATE: 01/23/03  ECO: *N23T*   */
/* Revision: 1.38       BY: Manish Dani         DATE: 02/20/03  ECO: *N27Z*   */
/* Revision: 1.39       BY: Vandna Rohira       DATE: 04/28/03  ECO: *N1YL*   */
/* Revision: 1.41       BY: Paul Donnelly (SB)  DATE: 06/28/03  ECO: *Q00L*   */
/* Revision: 1.42       BY: Vivek Gogte         DATE: 08/02/03  ECO: *N2GZ*   */
/* Revision: 1.43       BY: Sunil Fegade        DATE: 12/10/03  ECO: *P1F7*   */
/* Revision: 1.44       BY: Rajaneesh S.        DATE: 01/15/04  ECO: *P1GK*   */
/* Revision: 1.45       BY: Manish Dani         DATE: 09/20/04  ECO: *P2L3*   */
/* Revision: 1.46       BY: Sachin Deshmukh     DATE: 09/22/04  ECO: *P2LR*   */
/* Revision: 1.46.2.2   BY: Sandeep Panchal  DATE: 01/09/06  ECO: *P3HZ* */
/* Revision: 1.46.2.3   BY: Ashwini G.       DATE: 03/28/06  ECO: *P4ML* */
/* Revision: 1.46.2.4   BY: Prashant Menezes   DATE: 10/03/06 ECO: *P4ZG*  */
/* $Revision: 1.46.2.5 $   BY: Anuradha K.        DATE: 06/28/07 ECO: *P60R*  */

/*-Revision end---------------------------------------------------------------*/
/*ALDN* March 2008                                                           */ 
/*       *  Added a Frame showing Freight Term, Policy, Recalculate Fr Terms */ 
/*       *  display carton, Wt calculation                                   */
/*       *  Do not place order on hold if total amount < 0                   */
/*       *  Do not perform credit limit check for purposes of placing order  */
/*          on credit hold unless so_cr_init = ""                            */
/*                                                                           */

/******************************************************************************/
/* All patch markers and commented out code have been removed from the source */
/* code below. For all future modifications to this file, any code which is   */
/* no longer required should be deleted and no in-line patch markers should   */
/* be added.  The ECO marker should only be included in the Revision History. */
/******************************************************************************/

/*! N1YL HAS CHANGED THE WAY TAXABLE/NON-TAXABLE AMOUNT IS CALCULATED.
    THE ORDER DISCOUNT IS APPLIED FOR EACH LINE TOTAL AND THEN IT IS
    SUMMED UP TO CALCULATE THE TAXABLE/NON-TAXABLE AMOUNT BASED ON THE
    TAXABLE STATUS OF EACH LINE. PREVIOUSLY, TAXABLE/NON-TAXABLE AMOUNT
    WAS OBTAINED FROM THE GTM TABLES. THIS CAUSED PROBLEMS WHEN
    MULTIPLE TAXABLE BASES ARE USED TO CALCULATE TAX.

    TAXABLE/NON-TAXABLE AMOUNT WILL NOW BE DISPLAYED IN THE TRAILER
    FRAME BASED ON THE VALUE OF THE FLAG "DISPLAY TAXABLE/NON-TAXABLE
    AMOUNT ON TRAILER" IN THE GLOBAL TAX MANAGEMENT CTRL FILE
 */

/*V8:ConvertMode=Maintenance                                                 */
{mfdeclre.i}
{cxcustom.i "SOSOTRLE.P"}
{gplabel.i} /* EXTERNAL LABEL INCLUDE */
{pxpgmmgr.i} /* Project X persistent procedure functions */

{sotxidef.i}

/* ********** Begin Translatable Strings Definitions ********* */

&SCOPED-DEFINE sosotrle_p_4 "Total"
/* MaxLen: Comment: */

/* ********** End Translatable Strings Definitions ********* */

/* NEW SHARED VARIABLES, BUFFERS AND FRAMES */
define new shared variable undo_txdetrp     like mfc_logical.
define new shared variable tax_recno        as recid.

/* l_txchg IS SET TO TRUE IN TXEDIT.P WHEN TAXES ARE BEING EDITED  */
/* AND NOT JUST VIEWED IN DR/CR MEMO MAINTENANCE                   */
define new shared variable l_txchg       like mfc_logical initial no.

/* SHARED VARIABLES, BUFFERS AND FRAMES */
define shared variable rndmthd          like rnd_rnd_mthd.
define shared variable display_trail    like mfc_logical.
define shared variable so_recno         as recid.
define shared variable maint            like mfc_logical.
define shared variable taxable_amt      as decimal
   format "->>>>,>>>,>>9.99"
   label "Taxable".
define shared variable line_taxable_amt like taxable_amt.
define shared variable nontaxable_amt   like taxable_amt label "Non-Taxable".
define shared variable line_total       as decimal
   format "-zzzz,zzz,zz9.99"
   label "Line Total".
define shared variable disc_amt         like line_total
   label "Discount"
   format "(zzzz,zzz,zz9.99)".
define shared variable tax_amt          like line_total label "Total Tax".
define shared variable ord_amt          like line_total label "Total".
define shared variable user_desc        like trl_desc extent 3.
define shared variable total_pst        like line_total.
define shared variable tax_date         like so_tax_date.
define shared variable new_order        like mfc_logical.
define shared variable tax_edit         like mfc_logical.
define shared variable tax_edit_lbl     like mfc_char format "x(28)".
define shared variable invcrdt          as character format "x(15)".
define shared variable undo_trl2        like mfc_logical.
define shared  variable container_charge_total as decimal
   format "->>>>>>>>9.99"
   label "Containers" no-undo.
define  shared variable line_charge_total as decimal
  format "->>>>>>>>9.99"
  label "Line Charges" no-undo.

define shared variable l_nontaxable_lbl as character format "x(12)" no-undo.
define shared variable l_taxable_lbl    as character format "x(12)" no-undo.

{&SOSOTRLE-P-TAG1}

define shared frame sotot.
define shared frame d.

/* LOCAL VARIABLES, BUFFERS AND FRAMES */
define variable ext_actual      like sod_price.
define variable tax_tr_type     like tx2d_tr_type initial "11".
define variable tax_nbr         like tx2d_nbr     initial "".
define variable tax_lines       like tx2d_line    initial 0.
define variable disc_pct        like so_disc_pct.
define variable page_break      as   integer      initial 10.
define variable col-80          as   logical      initial true.
define variable recalc          like mfc_logical  initial true.
define variable credit_hold     like mfc_logical                no-undo.
define variable base_amt        like ar_amt.
define variable tmp_amt         as   decimal.
define variable retval          as   integer.
define variable balance_fmt     as   character.
define variable limit_fmt       as   character.
define variable l_tax_in        like tax_amt                    no-undo.
define variable ext_line_actual like sod_price                  no-undo.
define variable l_yn            like mfc_logical                no-undo.
define variable l_qtytoinv      like mfc_logical initial no     no-undo.
define variable l_tax_amt1      like tax_amt                    no-undo.
define variable l_tax_amt2      like tax_amt                    no-undo.
define variable l_trl_tax1      like tax_amt                    no-undo.
define variable l_trl_tax2      like tax_amt                    no-undo.
define variable msg-arg         as   character format "x(20)"   no-undo.
define variable l_tax_line      like tx2d_line initial 99999999 no-undo.
define variable ccOrder         as   logical                    no-undo.
define variable l_nontax_amt    like tx2d_nontax_amt            no-undo.
/* l_ext_actual IS THE EXTENDED AMOUNT EXCLUDING DISCOUNT. IT WILL */
/* BE USED FOR THE CALCULATION OF taxable_amt AND nontaxable_amt   */
define variable l_ext_actual    like sod_price                  no-undo.

DEF VAR curr_amt AS DECIMAL NO-UNDO. 
DEF VAR vx_msg AS CHARACTER NO-UNDO. 
DEFINE VARIABLE v_Message     AS CHARACTER FORMAT "X(40)" NO-UNDO.
define variable old_fr_terms  like so_fr_terms.

{gprunpdf.i "mcpl" "p"}

{fsconst.i} /* FIELD SERVICE CONSTANTS */
{txcalvar.i}
{etdcrvar.i}
{etvar.i}
{etrpvar.i}

{gpfilev.i} /* VARIABLE DEFINITIONS FOR gpfile.i */
{cclc.i}   /* DETERMINE IF CONTAINER AND LINE CHARGES ARE ENABLED */

for first gl_ctrl
      fields( gl_domain gl_rnd_mthd)
       where gl_ctrl.gl_domain = global_domain no-lock:
end. /* FOR FIRST GL_CTRL */

for first soc_ctrl
      fields(soc_domain soc_cr_hold)
       where soc_ctrl.soc_domain = global_domain no-lock:
end. /* FOR FIRST SOC_CTRL */

/* SET LIMIT_FMT ACCORDING TO BASE CURR ROUND METHOD*/
limit_fmt = "->>>>,>>>,>>9.99".
{gprun.i ""gpcurfmt.p"" "(input-output limit_fmt,
                          input gl_rnd_mthd)"}

/* SET BALANCE_FMT ACCORDING TO BASE CURR ROUND METHOD*/
balance_fmt = "->>>>,>>>,>>9.99".
{gprun.i ""gpcurfmt.p"" "(input-output balance_fmt,
                          input gl_rnd_mthd)"}

find so_mstr where recid(so_mstr) = so_recno exclusive-lock.
FIND FIRST so_mstr_a WHERE so_nbr = sls_ord . 

tax_nbr = so_quote.

if so_fsm_type = 'RMA' then
   assign tax_tr_type = '36'.

/* USE TRANSACTION TYPE 38 FOR CALL INVOICE RECORDING (SSM) */
/* AND SET THE TAX_NBR TO THE CALL'S QUOTE (IF ANY) */
if so_fsm_type = fsmro_c then do:

   for first ca_mstr
         fields( ca_domain ca_category ca_nbr ca_quote_nbr)
          where ca_mstr.ca_domain = global_domain
           and  ca_category       = '0'
           and   ca_nbr           = so_nbr no-lock:
   end. /* FOR FIRST CA_MSTR */
   if available ca_mstr then
      tax_nbr = ca_quote_nbr.
   tax_tr_type = "38".
end.

/**** FORMS ****/
form
   so_nbr
   so_cust
   so_bill
   so_ship
with frame a side-labels width 80 attr-space.

/* SET EXTERNAL LABELS */
setFrameLabels(frame a:handle).

/*ALDN* Shared Variables that were added to the frame sotot*/
{sosovarx.i}
{sosovary.i}
define variable v-amt as decimal no-undo.

{sosomt01.i}  /* Define shared frame d */
{socurvar.i}
{txcurvar.i}
{sototfrm.i}
/*ALDN** This is needed to display Aladdin custom fields */ 
{sototfrmx.i} 

tax_nbr = so_quote.

taxloop:
do on endkey undo, leave:

   l_nontax_amt = 0.

   if not so_sched
   then do:

      for first tx2d_det
         fields(tx2d_domain  tx2d_by_line        tx2d_cur_nontax_amt
                tx2d_edited  tx2d_line           tx2d_nbr     tx2d_nontax_amt
                tx2d_ref     tx2d_taxc           tx2d_tax_env    tx2d_tax_usage
                tx2d_tottax  tx2d_trl            tx2d_tr_type)
          where tx2d_det.tx2d_domain = global_domain
           and tx2d_ref       = so_nbr
           and tx2d_nbr        = so_quote
           and tx2d_tr_type    = tax_tr_type
           and tx2d_nontax_amt <> 0
      no-lock:
         l_nontax_amt = tx2d_nontax_amt.
      end. /* FOR FIRST tx2d_det */

      run getSOTotalsBeforeTax
         (buffer so_mstr,
          input  maint,
          input  rndmthd,
          output line_total,
          output line_taxable_amt,
          output disc_pct,
          output disc_amt,
          output taxable_amt,
          output nontaxable_amt,
          output container_charge_total,
          output line_charge_total,
          output user_desc[1],
          output user_desc[2],
          output user_desc[3]).

   end. /* IF NOT so_sched */

   /* CHECK PREVIOUS DETAIL FOR EDITED VALUES */

   for first tx2d_det
      fields(tx2d_domain tx2d_by_line tx2d_cur_nontax_amt tx2d_edited
             tx2d_line    tx2d_nbr     tx2d_nontax_amt     tx2d_ref
             tx2d_taxc    tx2d_tax_env tx2d_tax_usage      tx2d_tottax
             tx2d_trl     tx2d_tr_type)
       where  tx2d_det.tx2d_domain = global_domain
        and   tx2d_ref             = so_nbr
        and   tx2d_nbr             = so_quote
        and   tx2d_tr_type         = tax_tr_type
        and   tx2d_edited no-lock:
   end. /* FOR FIRST TX2D_DET */

   if available(tx2d_det) then do:
      /* Previous tax values edited. Recalculate? */
      {pxmsg.i &MSGNUM=917 &ERRORLEVEL=2 &CONFIRM=recalc}
   end.

   /* CALULATE THE TAX AMOUNT BEFORE TXCALC.P CALCULATES THE NEW */
   /* TAXES SO AS TO COMPARE IF THE TAX AMOUNT HAS BEEN CHANGED  */

   /* CALCULATE TOTALS */
   {gprun.i ""txtotal.p"" "(input  tax_tr_type,
                            input  so_nbr,
                            input  tax_nbr,
                            input  tax_lines,   /* ALL LINES */
                            output l_tax_amt1)"}

   /* OBTAINING TOTAL INCLUDED TAX FOR THE TRANSACTION */
   {gprun.i ""txtotal1.p"" "(input  tax_tr_type,
                             input  so_nbr,
                             input  tax_nbr,
                             input  tax_lines,  /* ALL LINES */
                             output l_tax_amt2)"}

   l_tax_amt1 = l_tax_amt1 + l_tax_amt2.

   if can-find (first sod_det
                 where sod_det.sod_domain = global_domain
                  and  sod_nbr            = so_nbr
                  and sod_qty_inv <> 0)
   then
      l_qtytoinv = yes.

   if can-find (first tx2d_det
                   where tx2d_det.tx2d_domain = global_domain
                    and  tx2d_ref      = so_nbr
                    and   tx2d_nbr     = so_quote
                    and   tx2d_tr_type = tax_tr_type
                    and   tx2d_by_line = no no-lock)
   then
      l_tax_line = 0.

   if recalc
   then do:

      if not new so_mstr
         and so_fsm_type = ""
         and l_qtytoinv
      then do:
         /* CALCULATE TRAILER TAX BEFORE RE-CALCULATION OF TAXES */
         /* REPLACED FOURTH INPUT PARAMETER 99999 BY l_tax_line  */
         {gprun.i ""txtotal.p"" "(input  tax_tr_type,
                                  input  so_nbr,
                                  input  tax_nbr,
                                  input  l_tax_line,   /* ALL LINES */
                                  output l_trl_tax1)"}
      end. /* IF NOT NEW so_mstr AND l_qtytoinv */

      /* CALCULATE TAXES */
      /* NOTE nbr FIELD BLANK FOR SALES ORDERS */

      /* ADDED TWO PARAMETERS TO TXCALC.P, INPUT PARAMETER VQ-POST
       *  AND OUTPUT PARAMETER RESULT-STATUS. THE POST FLAG IS SET
       *  TO 'NO' BECAUSE WE ARE NOT CREATING QUANTUM REGISTER
       *  RECORDS FROM THIS CALL TO TXCALC.P */

      {&SOSOTRLE-P-TAG2}

      if not so_sched
      then do:

         {gprun.i ""txcalc.p""  "(input  tax_tr_type,
                                  input  so_nbr,
                                  input  tax_nbr,
                                  input  tax_lines /*ALL LINES*/,
                                  input  no,
                                  output result-status)"}

      end. /* IF NOT so_sched */

      {&SOSOTRLE-P-TAG3}

      if not new so_mstr
         and so_fsm_type = ""
         and l_qtytoinv
      then do:
         /* CALCULATE TRAILER TAX AFTER RE-CALCULATION OF TAXES */
         /* REPLACED FOURTH INPUT PARAMETER 99999 BY l_tax_line */
         {gprun.i ""txtotal.p"" "(input  tax_tr_type,
                                  input  so_nbr,
                                  input  tax_nbr,
                                  input  l_tax_line,   /* ALL LINES */
                                  output l_trl_tax2)"}
      end. /* IF NOT NEW so_mstr AND l_qtytoinv */

      /* DISPLAY WARNING MESSAGE WHEN TAXABLE TRAILER AMOUNT IS */
      /* CHANGED FOR A SHIPPED BUT NOT INVOICED SO              */

      if so_fsm_type = ""
         and not new so_mstr
         and l_qtytoinv
         and l_trl_tax1 <> l_trl_tax2
      then
         run p-sotrlmsg.

   end. /* if recalc */

   if not so_sched
   then do:

      /* CHANGED FOURTH PARAMETER disc_amt FROM INPUT TO INPUT-OUTPUT */
      run getSOTotalsAfterTax
         (buffer       so_mstr,
          input        tax_tr_type,
          input        tax_nbr,
          input-output disc_amt,
          input        total_pst,
          input-output line_total,
          input-output line_taxable_amt,
          input-output taxable_amt,
          input-output nontaxable_amt,
          output       tax_amt,
          output       ord_amt).

   end. /* IF NOT so_sched */

   /* CHECK CREDIT AMOUNTS */

   if ord_amt < 0 then invcrdt = "**" + getTermLabel("C_R_E_D_I_T",11) + "**".
   else invcrdt = "".

   /* CHECK CREDIT LIMIT */
   /* If the bill-to customer's outstanding balance is already above   */
   /* His credit limit, then the order will have been put on hold in   */
   /* The header.  We check now because the subtotal of the order may  */
   /* Have put the customer over his credit limit and the user might   */
   /* F4 out of the trailer screen, bypassing the check done after     */
   /* The trailer amounts have been entered.  It hardly seems worth    */
   /* Mentioning that the customer's balance plus this order might be  */
   /* Above his credit limit now, but judicious use of order discounts */
   /* And negative trailer amounts might bring the total back down     */
   /* Below the credit limit.  Better safe than sorry, I always say.   */
   /* Note that we don't bother checking if we're not going to put the */
   /* Order on hold, since this could just produce a lot of messages   */
   /* That the user is probably ignoring anyway.                       */
/*ALDN*/    if so_stat = "" 
      and soc_cr_hold then do:

      for first cm_mstr
         fields( cm_domain cm_addr cm_balance cm_cr_limit cm_disc_pct)
          where cm_mstr.cm_domain = global_domain
           and  cm_addr           = so_bill
          no-lock:
      end. /* FOR FIRST CM_MSTR */

      base_amt = ord_amt.
      if so_curr <> base_curr then
      do:
         /* CONVERT TO BASE CURRENCY */

         {gprunp.i "mcpl" "p" "mc-curr-conv"
            "(input so_curr,
              input base_curr,
              input so_ex_rate,
              input so_ex_rate2,
              input base_amt,
              input true,
              output base_amt,
              output mc-error-number)"}
         if mc-error-number <> 0 then do:
            {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
         end.

      end.

      /*  FIND OUT IF THIS IS A CREDITCARD SO */
      ccOrder = can-find(first qad_wkfl
                            where qad_wkfl.qad_domain = global_domain
                             and  qad_key1 begins string(so_nbr, "x(8)")
                             and qad_key2 = "creditcard").

      /* NOTE: IF THE ORDER IS A CREDITCARD ORDER, DON'T                */
      /*    CHECK CREDIT HISTORY - BECAUSE AS LONG AS THE CREDITCARD    */
      /*    AMOUNT COVERS THE ORDER WE DON'T HAVE TO CONSIDER THE       */
      /*    CUSTOMER'S BALANCE OR CREDIT LIMIT.                         */

      /* NOTE: DO NOT PUT CALL REPAIR ORDERS (FSM-RO) ON HOLD - BECAUSE */
      /*    THESE ORDERS WILL NOT BE SHIPPING ANYTHING, ONLY INVOICING  */
      /*    FOR WORK ALREADY DONE.                                      */

      /* NOTE: ALSO DO NOT PUT RMA ORDERS (RMA) ON HOLD - BECAUSE THESE */
      /*    ORDERS WILL BE CHECKED FOR CREDIT LIMIT AND PUT ON HOLD IN  */
      /*    THE PROGRAM FSRMAMTU.P DEPENDING ON THE SERVICE LEVEL FLAG  */
      /*    (SVC_HOLD_CALL)                                             */

      find current cm_mstr no-lock no-error. 
      FIND FIRST cm_mstr_a WHERE cm_mstr_a.addr = so_cust NO-LOCK. 

      {gprun.i ""sosotot.p"" "(input so_nbr, output v-amt)"}
      
       RUN calculate_soamt (INPUT so_nbr, OUTPUT curr_amt). 

      if available cm_mstr
      then do:

         if cm_cr_limit < (cm_balance + base_amt + v-amt)
            and so_fsm_type <> "FSM-RO"
            and so_fsm_type <> "RMA"
         and not(ccOrder)
         then do:
/*ALDN*/   IF (so_cr_init > ""  AND curr_amt > v_PrevSO_TotalValue) OR 
               so_cr_init = "" THEN DO:
            /* Sales Order placed on credit hold */
            assign
               credit_hold = true
               so_stat     = "HD".

            display so_stat with frame d.

            msg-arg = string((cm_balance + base_amt + v-amt),balance_fmt).
            /* Customer Balance plus this Order */
            {pxmsg.i &MSGNUM=616 &ERRORLEVEL=2 &MSGARG1=msg-arg}
            msg-arg = string(cm_cr_limit,limit_fmt).
            /* Credit Limit */
            {pxmsg.i &MSGNUM=617 &ERRORLEVEL=1 &MSGARG1=msg-arg}
            /* Sales Order placed on credit hold */
            {pxmsg.i &MSGNUM=690 &ERRORLEVEL=1
                     &MSGARG1=getTermLabel(""SALES_ORDER"",20)}
         END. /* ALDN */ 
         end.

      end. /* IF AVAILABLE cm_mstr */

      if ccOrder then do:
         if so_prepaid < base_amt
         then do:
            /* Sales Order placed on credit hold */
            assign
               credit_hold = true
               so_stat     = "HD".

            display so_stat with frame d.

            /* Sales Order placed on credit hold */
            {pxmsg.i &MSGNUM=690 &ERRORLEVEL=1
                  &MSGARG1=getTermLabel(""SALES_ORDER"",20)}
         end.
      end.
   end.

   run so_tot_dsp. /* DISPLAY ALL FIELDS */
   
   trlloop:
   do on error undo, retry
      on endkey undo taxloop, leave:
      {&SOSOTRLE-P-TAG4}
       
       RUN disp_update_sototxyz.    /*ALDN*/ 

      /* STORING THE DEFAULT VOLUME DISCOUNT PERCENTAGE */
      assign disc_pct = so_disc_pct .
      set
         so_disc_pct  v_SO_FreightTerms so_mstr_a.cust_frt_acct 
         so_trl1_cd so_trl1_amt so_trl2_cd
         so_trl2_amt so_trl3_cd so_trl3_amt 
          tax_edit
      with frame sotot
      editing:
         readkey.
         if  keyfunction(lastkey) = "end-error"
         then do:
            hide message no-pause.
            /* TAX DETAIL RECORDS WILL NOT BE SAVED WHEN F4 */
            /* OR ESC IS PRESSED.                           */
            {pxmsg.i &MSGNUM=4773 &ERRORLEVEL=2}
            /* CONTINUE WITHOUT SAVING?                     */
            {pxmsg.i &MSGNUM=4774 &ERRORLEVEL=1 &CONFIRM=l_yn}
            hide message no-pause.
            if l_yn
            then
               undo taxloop, leave.
         end. /* IF KEYFUNCTION(LASTKEY) */
         else
            apply lastkey.
      end. /* EDITING */

      IF v_SO_FreightTerms = "" THEN DO:
         /* "ERROR: FREIGHT TERMS CODE CANNOT BE BLANK.  Please re-enter."*/
         {pxmsg.i &MSGNUM=671 &MSGARG1=v_SO_FreightTerms &ERRORLEVEL=3} 
         UNDO, RETRY trlloop. /*set_fr_block.*/
      END. /*IF v_SO_FreightTerms = "" THEN*/

      ELSE do:
        find ft_mstr where ft_terms = v_SO_FreightTerms no-lock no-error.
        if not available ft_mstr then do:
          /* Invalid Freight Terms */
          {pxmsg.i &MSGNUM=671 &MSGARG1=v_SO_FreightTerms &ERRORLEVEL=3} 
          next-prompt v_SO_FreightTerms with frame sotot. /*sototxyz.*/
          undo trlloop /*set_fr_block*/ , retry.
        end.
      end.


      so_mstr.so_fr_terms = v_SO_FreightTerms.

      {&SOSOTRLE-P-TAG5}

      /* CHECKING WHETHER VOLUME DISCOUNT IS MANUALLY ENTERED ? */

      if so_disc_pct <> disc_pct
      then do:

         so__qadl01 = yes .

         /* ISSUE MESSAGE WHEN SO TRAILER DISC MANUALLY CHANGED */
         /* AND SHIPMENT IS MADE                                */

         if (can-find (first sod_det
                          where sod_det.sod_domain = global_domain
                           and  sod_nbr            = so_nbr
                           and  sod_qty_inv        <> 0))
         then do:

            hide message.
            /* DISCOUNT HAS CHANGED. TAXES WILL NOT BE UPDATED */
            /* FOR QTY-TO-INVOICE                              */
            {pxmsg.i &MSGNUM=4650 &ERRORLEVEL=2}
            /* USE PENDING INVOICE MAINTENANCE TO ADJUST */
            /* THOSE TAXES                               */
            {pxmsg.i &MSGNUM=4651 &ERRORLEVEL=2}
            pause.

         end. /* IF (CAN-FIND (FIRST sod_det WHERE ... */

      end. /* IF so_disc_pct <> disc_pct */

      {txedttrl.i &code  = "so_trl1_cd"
                  &amt   = "so_trl1_amt"
                  &desc  = "user_desc[1]"
                  &frame = "sotot"
                  &loop  = "trlloop"}

      /* VALIDATE TRAILER AMOUNT BASE ON ROUNDING METHOD */
      if (so_trl1_amt <> 0) then do:
         {gprun.i ""gpcurval.p"" "(input so_trl1_amt,
                                   input rndmthd,
                                  output retval)"}
         if (retval <> 0) then do:
            next-prompt so_trl1_amt with frame sotot.
            undo trlloop, retry.
         end.
      end.

      {txedttrl.i &code  = "so_trl2_cd"
                  &amt   = "so_trl2_amt"
                  &desc  = "user_desc[2]"
                  &frame = "sotot"
                  &loop  = "trlloop"}

      /* VALIDATE TRAILER AMOUNT BASE ON ROUNDING METHOD */
      if (so_trl2_amt <> 0) then do:
         {gprun.i ""gpcurval.p"" "(input so_trl2_amt,
                                   input rndmthd,
                                   output retval)"}
         if (retval <> 0) then do:
            next-prompt so_trl2_amt with frame sotot.
            undo trlloop, retry.
         end.
      end.

      {txedttrl.i &code  = "so_trl3_cd"
                  &amt   = "so_trl3_amt"
                  &desc  = "user_desc[3]"
                  &frame = "sotot"
                  &loop  = "trlloop"}

      /* VALIDATE TRAILER AMOUNT BASE ON ROUNDING METHOD */
      if (so_trl3_amt <> 0) then do:
         {gprun.i ""gpcurval.p"" "(input so_trl3_amt,
                                   input rndmthd,
                                   output retval)"}
         if (retval <> 0) then do:
            next-prompt so_trl3_amt with frame sotot.
            undo trlloop, retry.
         end.
      end.
       /* If it is set to cust paid but there is no account then error out */
      IF (so_fr_terms = "3rdparty" OR so_fr_terms = "collect") AND 
           so_mstr_a.cust_frt_acct = "" THEN DO:
          v_message = "" .
          v_message = "Cust acct required when freight terms is customer paid".
          {pxmsg.i &MSGTEXT=v_message &ERRORLEVEL=3}
          NEXT-PROMPT so_mstr_a.cust_frt_acct .
          UNDO trlloop, RETRY .
      END.

      /* If the freight is to be paid by the customer change the ship via to be the one specified for that purpose
         by the customer */
      IF (so_fr_terms = "3rdparty" OR so_fr_terms = "collect") AND 
           so_mstr_a.cust_frt_acct <> "" THEN DO:
          FIND FIRST cm_mstr_a WHERE cm_mstr_a.addr = so_cust NO-LOCK.
          /*If it does not already match then change */
          IF so_shipvia <> cm_mstr_a.cust_pd_shipvia THEN DO .  
              so_shipvia = cm_mstr_a.cust_pd_shipvia .
              DISPLAY so_shipvia WITH FRAME d .
              v_message = "" .
              v_message = "Ship Via changed to customer paid preference from the Customer Master".
              {pxmsg.i &MSGTEXT=v_message &ERRORLEVEL=1}
          END.
      END.
   end. /* TRLLOOP: DO ON ERROR UNDO, RETRY */



   /*** RECALCULATE TOTALS FOR LINES ***/
   assign
      line_total     = 0
      taxable_amt    = 0
      nontaxable_amt = 0
      container_charge_total = 0
      line_charge_total = 0.

   /* ACCUMULATE LINE AMOUNTS */
   for each sod_det
      fields(sod_domain sod_fsm_type sod_line sod_nbr
             sod_price sod_qty_inv sod_qty_ord sod_qty_ship
             sod_taxable sod_tax_in sod_fix_pr )
      where  sod_det.sod_domain = global_domain
       and   sod_nbr            = so_nbr:

      assign
         ext_actual   = (sod_price * (sod_qty_ord - sod_qty_ship))
         l_ext_actual = ((sod_price * (sod_qty_ord - sod_qty_ship))
                         * (1 - so_disc_pct / 100)).


      if using_line_charges then do:

         for each sodlc_det
         fields( sodlc_domain sodlc_order sodlc_ord_line sodlc_ext_price
                sodlc_one_time sodlc_times_charged sodlc_trl_code)
          where sodlc_det.sodlc_domain = global_domain
           and  sodlc_order            = sod_nbr
           and sodlc_ord_line          = sod_line
         no-lock:

            if sodlc_one_time and sodlc_times_charged > 0 then next.

            ext_line_actual = sodlc_ext_price.

            /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
            {gprunp.i "mcpl" "p" "mc-curr-rnd"
               "(input-output ext_line_actual,
                 input rndmthd,
                 output mc-error-number)"}
            if mc-error-number <> 0 then do:
               {pxmsg.i &MSGNUM = mc-error-number &ERRORLEVEL = 2}
            end.

            assign
               line_charge_total = line_charge_total + ext_line_actual
               line_total = line_total + ext_line_actual.

            for first trl_mstr
             fields( trl_domain trl_code trl_taxable trl_desc)
                where trl_mstr.trl_domain = global_domain
                 and  trl_code            = sodlc_trl_code
             no-lock:
            end.

            if available trl_mstr then do:
               if trl_taxable then
                  taxable_amt = taxable_amt + ext_line_actual.
               else
                  nontaxable_amt = nontaxable_amt + ext_line_actual.
            end. /*IF AVAILABLE TRL_MSTR*/

         end. /* FOR EACH SODLC_DET*/
      end. /*IF USING_LINE_CHARGES*/

      /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
      {gprunp.i "mcpl" "p" "mc-curr-rnd"
          "(input-output ext_actual,
            input rndmthd,
            output mc-error-number)"}
      if mc-error-number <> 0 then do:
         {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
      end.

      {gprunp.i "mcpl" "p" "mc-curr-rnd"
         "(input-output l_ext_actual,
           input rndmthd,
           output mc-error-number)"}

      if mc-error-number <> 0
      then do:
         {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
      end. /* IF mc-error-number <> 0 */

      /* CALL THE PROCEDURE TO GET LINE TOTAL ONLY WHEN TAX IS */
      /* INCLUDED                                              */
      if sod_tax_in
      then do:
         {gprunp.i "sopl" "p" "getExtendedAmount"
            "(input        rndmthd,
              input        sod_line,
              input        so_nbr,
              input        so_quote,
              input        tax_tr_type,
              input-output ext_actual)"}
      end. /* IF sod_tax_in ... */

      line_total = line_total + ext_actual.

      /* FOR CALL INVOICES, SFB_TAXABLE (IN 86) OF SFB_DET         */
      /* DETERMINES TAXABILITY AND THERE COULD BE MULTIPLE SFB_DET */
      /* FOR A SOD_DET.                                            */
      if sod_fsm_type = fsmro_c
         and sod_taxable
         and not sod_fix_pr
      then do:
         for each sfb_det no-lock
             where sfb_det.sfb_domain = global_domain
              and  sfb_nbr            = sod_nbr
              and sfb_so_line         = sod_line:
             if sfb_exchange then
                ext_actual   = 0 - (sfb_exg_price * sfb_qty_ret).
             else
                ext_actual   = (sfb_price * sfb_qty_req).

             /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
             {gprunp.i "mcpl" "p" "mc-curr-rnd"
                "(input-output ext_actual,
                  input rndmthd,
                  output mc-error-number)"}
             if mc-error-number <> 0 then do:
                {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
             end.

             if sfb_exchange then
                l_ext_actual = ext_actual * (1 - so_disc_pct / 100).
             else
                assign
                   ext_actual   = ext_actual - sfb_covered_amt
                   l_ext_actual = ext_actual * (1 - so_disc_pct / 100).

            {gprunp.i "mcpl" "p" "mc-curr-rnd"
               "(input-output l_ext_actual,
                 input rndmthd,
                 output mc-error-number)"}
            if mc-error-number <> 0
            then do:
               {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
            end. /* IF mc-error-number <> 0 */

            if sfb_taxable then
               assign
                  taxable_amt      = taxable_amt + l_ext_actual
                  line_taxable_amt = taxable_amt.
            else
               nontaxable_amt = nontaxable_amt + l_ext_actual.
         end. /* FOR EACH SFB_DET */
      end. /* IF SOD_FSM_TYPE = FSMRO_C ... */
      else

         if sod_taxable then
            assign
               taxable_amt = taxable_amt + l_ext_actual
               line_taxable_amt = taxable_amt.
         else
            nontaxable_amt = nontaxable_amt + l_ext_actual.
   end. /* FOR EACH sod_det */

   /* CALCULATE DISCOUNT */
   disc_amt = (- line_total * (so_disc_pct / 100)).
   /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
   {gprunp.i "mcpl" "p" "mc-curr-rnd"
      "(input-output disc_amt,
        input rndmthd,
        output mc-error-number)"}
   if mc-error-number <> 0 then do:
      {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
   end.

   /* ADD TRAILER AMOUNTS */
   {txtrltrl.i so_trl1_cd so_trl1_amt user_desc[1]}
   {txtrltrl.i so_trl2_cd so_trl2_amt user_desc[2]}
   {txtrltrl.i so_trl3_cd so_trl3_amt user_desc[3]}

   /****** CALCULATE TAXES ************/
   if recalc
   then do:

      if not new so_mstr
         and so_fsm_type = ""
         and l_qtytoinv
      then do:
         /* CALCULATE TRAILER TAX BEFORE RE-CALCULATION OF TAXES */
         /* REPLACED FOURTH INPUT PARAMETER 99999 BY l_tax_line  */
         {gprun.i ""txtotal.p"" "(input  tax_tr_type,
                                  input  so_nbr,
                                  input  tax_nbr,
                                  input  l_tax_line,   /* ALL LINES */
                                  output l_trl_tax1)"}

      end. /* IF NOT NEW so_mstr AND l_qtytoinv */

      /* ADDED TWO PARAMETERS TO TXCALC.P, INPUT PARAMETER VQ-POST
       *  AND OUTPUT PARAMETER RESULT-STATUS. THE POST FLAG IS SET
       *  TO 'NO' BECAUSE WE ARE NOT CREATING QUANTUM REGISTER
       *  RECORDS FROM THIS CALL TO TXCALC.P */

      {&SOSOTRLE-P-TAG6}

      if not so_sched
      then do:

         {gprun.i ""txcalc.p""  "(input  tax_tr_type,
                                  input  so_nbr,
                                  input  tax_nbr,
                                  input  tax_lines,  /*ALL LINES*/
                                  input  no,
                                  output result-status)"}

      end. /* IF NOT so_sched */

      {&SOSOTRLE-P-TAG7}

      if not new so_mstr
         and so_fsm_type = ""
         and l_qtytoinv
      then do:
         /* CALCULATE TRAILER TAX AFTER RE-CALCULATION OF TAXES */
         /* REPLACED FOURTH INPUT PARAMETER 99999 BY l_tax_line */
         {gprun.i ""txtotal.p"" "(input  tax_tr_type,
                                  input  so_nbr,
                                  input  tax_nbr,
                                  input  l_tax_line,   /* ALL LINES */
                                  output l_trl_tax2)"}
      end. /* IF NOT NEW so_mstr AND l_qtytoinv */

      /* DISPLAY WARNING MESSAGE WHEN TAXABLE TRAILER AMOUNT IS */
      /* CHANGED FOR A SHIPPED BUT NOT INVOICED SO              */

      if so_fsm_type = ""
         and not new so_mstr
         and l_qtytoinv
         and l_trl_tax1 <> l_trl_tax2
      then
         run p-sotrlmsg.

   end. /* IF recalc */

   /* DO TAX DETAIL DISPLAY / EDIT HERE */
   if tax_edit then do:
      hide frame sotot no-pause.
      hide frame d no-pause.

      if so_tax_date <> ?
      then
         tax_date = so_tax_date.
      else
      if so_due_date <> ?
      then
         tax_date = so_due_date.
      else
         tax_date = so_ord_date.

      /* ADDED so_curr,so_ex_ratetype,so_ex_rate,so_ex_rate2  */
      /* AND tax_date AS SIXTH, SEVENTH, EIGTH, NINTH         */
      /* AND TENTH INPUT PARAMETER RESPECTIVELY.              */

      {gprun.i ""txedit.p""  "(input  tax_tr_type,
                               input  so_nbr,
                               input  tax_nbr,
                               input  tax_lines, /*ALL LINES*/
                               input  so_tax_env,
                               input  so_curr,
                               input  so_ex_ratetype,
                               input  so_ex_rate,
                               input  so_ex_rate2,
                               input  tax_date,
                               output tax_amt)"}
      view frame sotot.
      /*V8-*/
      view frame d.
      /*V8+*/
   end.

   {gprun.i ""txabsrb.p""
      "(input        so_nbr,
        input        so_quote,
        input        tax_tr_type,
        input-output line_total,
        input-output taxable_amt)"}

   /* CALCULATE TOTALS */
   {gprun.i ""txtotal.p"" "(input  tax_tr_type,
                            input  so_nbr,
                            input  tax_nbr,
                            input  tax_lines,   /* ALL LINES */
                            output tax_amt)"}

   /* OBTAINING TOTAL INCLUDED TAX FOR THE TRANSACTION */
   {gprun.i ""txtotal1.p"" "(input  tax_tr_type,
                             input  so_nbr,
                             input  tax_nbr,
                             input  tax_lines,       /* ALL LINES */
                             output l_tax_in)"}

   /* ADJUSTING LINE TOTALS AND TOTAL TAX BY INCLUDED TAX */
   assign
      taxable_amt      = taxable_amt - l_tax_in
      line_taxable_amt = taxable_amt
      tax_amt          = tax_amt + l_tax_in.

   assign
      line_total     = (taxable_amt + nontaxable_amt
                       - (so_trl1_amt + so_trl2_amt + so_trl3_amt))
                       * (100 / (100 - so_disc_pct))
      disc_amt       = ( - line_total * (so_disc_pct / 100)).

      ord_amt        = line_total + disc_amt + so_trl1_amt +
                       so_trl2_amt + so_trl3_amt + tax_amt + total_pst.


   if ord_amt < 0 then
      invcrdt = "**" + getTermLabel("C_R_E_D_I_T",11) + "**".
   else
      invcrdt = "".

   if display_trail then do:
      run so_tot_dsp. /* DISPLAY ALL FIELDS */
   end.

   undo_trl2 = false.

end. /* taxloop*/

/* Warn user now if order had been put on credit hold */
if credit_hold then
   so_stat = "HD".

/* PROCEDURE so_tot_dsp IS INTRODUCED AS PROGRESS GETS       */
/* CONFUSED BETWEEN TWO FRAMES WITH SAME FIELD IN sototdsp.i */
/* AND ALLOWED UNAUTORIZED USER TO UPDATE so_disc_pct FIELD. */
PROCEDURE so_tot_dsp:
   {sototdsp.i}.
END PROCEDURE. /* PROCEDURE so_tot_dsp */

PROCEDURE p-sotrlmsg:

   hide message.
   /* TRAILER TAXES HAS CHANGED, WILL NOT BE CHANGED IN INVOICE        */
   {pxmsg.i &MSGNUM=3979 &ERRORLEVEL=2}

   /* USE PENDING INVOICE MAINTENANCE TO ADJUST THOSE TAXES            */
   {pxmsg.i &MSGNUM=4651 &ERRORLEVEL=2}

END PROCEDURE. /* PROCEDURE p-sotrlmsg */

PROCEDURE getSOTotalsAfterTax:
/*---------------------------------------------------------------------------
Purpose: Calculate and return the SO trailer amounts for a sales order
Parameters:
   buffer so_mstr - sales order master buffer
   tax_tr_type - transaction type used in tx2d_tr_type
   tax_nbr - order number used in tx2d_nbr
   disc_amt - order discount amount
   total_pst -
   line_total - sum of extended line amounts with included taxes
   line_taxable_amt - taxable portion of line_total
   taxable_amt - taxable amount of order total
   nontaxable_amt - non-taxable of order total
   tax_amt - total tax to be charged for the order
   ord_amt - total order amount
Exceptions:
Notes:
---------------------------------------------------------------------------*/

   /* CHANGED FOURTH PARAMETER disc_amt FROM INPUT TO INPUT-OUTPUT */
   define              parameter buffer so_mstr for so_mstr.
   define input        parameter tax_tr_type like tx2d_tr_type no-undo.
   define input        parameter tax_nbr like tx2d_nbr no-undo.
   define input-output parameter disc_amt as decimal no-undo.
   define input        parameter total_pst as decimal no-undo.
   define input-output parameter line_total as decimal no-undo.
   define input-output parameter line_taxable_amt as decimal no-undo.
   define input-output parameter taxable_amt as decimal no-undo.
   define input-output parameter nontaxable_amt as decimal no-undo.
   define output       parameter tax_amt as decimal no-undo.
   define output       parameter ord_amt as decimal no-undo.

   define variable tax_lines as integer initial 0 no-undo.
   define variable l_tax_in as decimal no-undo.
   define variable l_rndmthd    like gl_rnd_mthd  no-undo.

   PROCBLOCK:
   do on error undo PROCBLOCK, return error {&GENERAL-APP-EXCEPT}:

      for first gl_ctrl
         fields (gl_rnd_mthd)
         no-lock:
         l_rndmthd = gl_rnd_mthd.
      end. /* FOR FIRST gl_ctrl */

      {gprun.i ""txabsrb.p"" "(
         input so_nbr,
         input so_quote,
         input tax_tr_type,
         input-output line_total,
         input-output taxable_amt)"}

      /* GET TAX TOTALS */
      {gprun.i ""txtotal.p"" "(
         input  tax_tr_type,
         input  so_nbr,
         input  tax_nbr,
         input  tax_lines,       /* ALL LINES */
         output tax_amt)"}

      /* OBTAINING TOTAL INCLUDED TAX FOR THE TRANSACTION */
      {gprun.i ""txtotal1.p"" "(
         input  tax_tr_type,
         input  so_nbr,
         input  tax_nbr,
         input  tax_lines,       /* ALL LINES */
         output l_tax_in)"}

      /* WHEN TAX DETAIL RECORDS ARE NOT AVAILABLE AND SO IS  */
      /* TAXABLE THEN USE THE PROCEDURE TO CALCULATE ORDER    */
      /* TOTAL AND DISCOUNT                                   */

      /* WHEN TAX INCLUDED IS YES, ORDER DISCOUNT SHOULD BE   */
      /* CALCULATED ON THE LINE TOTAL AFTER REDUCING THE LINE */
      /* TOTAL BY THE INCLUDED TAX                            */

      if        l_tax_in <> 0
         or    (l_ord_contains_tax_in_lines
           and (can-find (first tx2d_det
                          where tx2d_domain      = global_domain
                          and   tx2d_ref         = so_nbr
                          and   tx2d_nbr         = so_quote
                          and   tx2d_cur_tax_amt = 0)))
      then do:
         {pxrun.i &PROC = 'calDiscAmountAfterSubtractingTax'
            &PROGRAM = 'sopl.p'
            &CATCHERROR = true
            &PARAM = "(
            input table  t_store_ext_actual,
            input        l_rndmthd,
            input        so_disc_pct,
            input        so_nbr,
            input        so_quote,
            input        tax_tr_type,
            output       line_total,
            output       disc_amt)"}

      end. /* IF l_tax_in <> 0 ... */

      /* ADJUSTING LINE TOTALS AND TOTAL TAX BY INCLUDED TAX */
      assign
         taxable_amt      = taxable_amt - l_tax_in
         line_taxable_amt = taxable_amt
         tax_amt          = tax_amt     + l_tax_in.

      assign
         line_total     = (taxable_amt + nontaxable_amt
                          - (so_trl1_amt + so_trl2_amt + so_trl3_amt))
                          * (100 / (100 - so_disc_pct))
         disc_amt       = ( - line_total * (so_disc_pct / 100)).

      /* CALCULATE ORDER TOTAL */
      ord_amt = line_total + disc_amt + so_trl1_amt
                + so_trl2_amt + so_trl3_amt + tax_amt + total_pst.

   end. /*PROCBLOCK*/

   return {&SUCCESS-RESULT}.
END PROCEDURE. /*GetSOTotalsAfterTax*/

PROCEDURE getSOTotalsBeforeTax:
/*---------------------------------------------------------------------------
Purpose: Calculate and return the SO trailer amounts for a sales order
Parameters:
   buffer so_mstr - sales order master buffer
   maint - logical flag indicating caller is SO maintenance programs
   rndmthd - round method
   line_total - sum of extended line amounts
   line_taxable_amt - taxable portion of line_total
   disc_pct - order discount percent
   disc_amt - order discount amount
   taxable_amt - taxable amount of order total
   nontaxable_amt - non-taxable of order total
   user_desc1 - description of trailer code 1 for display
   user_desc2 - description of trailer code 2 for display
   user_desc3 - description of trailer code 3 for display
Exceptions:
Notes:
---------------------------------------------------------------------------*/
   define parameter buffer so_mstr for so_mstr.
   define input parameter maint as logical no-undo.
   define input parameter rndmthd like rnd_rnd_mthd no-undo.
   define output parameter line_total as decimal no-undo.
   define output parameter line_taxable_amt as decimal no-undo.
   define output parameter disc_pct as decimal no-undo.
   define output parameter disc_amt as decimal no-undo.
   define output parameter taxable_amt as decimal no-undo.
   define output parameter nontaxable_amt as decimal no-undo.
   define output parameter container_total as decimal no-undo.
   define output parameter line_charge_total as decimal no-undo.
   define output parameter user_desc1 as character no-undo.
   define output parameter user_desc2 as character no-undo.
   define output parameter user_desc3 as character no-undo.

   define variable tax_date        as date                       no-undo.
   define variable ext_actual      as decimal                    no-undo.
   define variable tmp_amt         as decimal                    no-undo.
   define variable mc-error-number as integer                    no-undo.
   define variable fsmro_c         as character initial "FSM-RO" no-undo.
   define variable l_qtytoinv      like mfc_logical initial no   no-undo.
   define variable l_sodiscpct     like so_disc_pct              no-undo.
   define variable ext_line_actual like sod_price                no-undo.
   /* l_ext_actual IS THE EXTENDED AMOUNT EXCLUDING DISCOUNT. IT WILL */
   /* BE USED FOR THE CALCULATION OF taxable_amt AND nontaxable_amt   */
   define variable l_ext_actual    as  decimal                   no-undo.

   PROCBLOCK:
   do on error undo PROCBLOCK, return error {&GENERAL-APP-EXCEPT}:

      /*** GET TOTALS FOR LINES ***/

      empty temp-table t_store_ext_actual no-error.

      if so_tax_date = ? then tax_date = so_due_date.
      else tax_date = so_tax_date.
      if tax_date = ? then tax_date = so_ord_date.

      l_ord_contains_tax_in_lines = can-find (first sod_det
                                                  where sod_domain =                                                       global_domain                                                               and  sod_nbr = so_nbr
                                                   and   sod_taxable
                                                   and   sod_tax_in).

      /* ACCUMULATE LINE AMOUNTS */
      for each sod_det
         fields(sod_domain sod_fsm_type sod_line sod_nbr
             sod_price sod_qty_inv sod_qty_ord sod_qty_ship
             sod_taxable sod_tax_in sod_fix_pr )
         where sod_domain = global_domain
          and  sod_nbr    = so_nbr:

         if sod_qty_inv <> 0
         then
            l_qtytoinv = yes.

         assign
            ext_actual   = (sod_price  * (sod_qty_ord - sod_qty_ship))
            l_ext_actual = ((sod_price * (sod_qty_ord - sod_qty_ship))
                             * (1 - so_disc_pct / 100)).

         if using_line_charges then do:
            for each sodlc_det
               fields(sodlc_order sodlc_ord_line sodlc_one_time
                      sodlc_times_charged sodlc_ext_price sodlc_trl_code)
               where sodlc_domain   = global_domain
                and  sodlc_order    = sod_nbr
                and  sodlc_ord_line = sod_line no-lock:

               if sodlc_one_time and sodlc_times_charged > 0 then next.

               ext_line_actual = sodlc_ext_price.

               {pxrun.i &PROC = 'mc-curr-rnd' &PROGRAM = 'mcpl.p'
                                  &CATCHERROR = true
                                  &PARAM = "(input-output ext_line_actual,
                                              input rndmthd,
                                              output mc-error-number)"}
               if mc-error-number <> 0 then do:
                  {pxmsg.i &MSGNUM = mc-error-number &ERRORLEVEL = 2}
               end.
               assign
                  line_charge_total = line_charge_total + ext_line_actual
                  line_total = line_total + ext_line_actual.

               for first trl_mstr
                  where trl_domain  = global_domain
                   and  trl_code    = sodlc_trl_code no-lock:
               end.

               if available trl_mstr then do:
                  if trl_taxable then
                     taxable_amt = taxable_amt + ext_line_actual.
                  else
                     nontaxable_amt = nontaxable_amt + ext_line_actual.
               end. /*IF AVAILABLE TRL_MSTR*/
            end. /* FOR EACH SODLC_DET*/
         end. /*IF USING_LINE_CHARGES*/

         /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
         {pxrun.i &PROC = 'mc-curr-rnd' &PROGRAM = 'mcpl.p'
            &CATCHERROR = true
            &PARAM = "(
                  input-output ext_actual,
                  input rndmthd,
                  output mc-error-number)"}
         if mc-error-number <> 0 then do:
            {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
         end.

         {pxrun.i &PROC = 'mc-curr-rnd' &PROGRAM = 'mcpl.p'
                  &CATCHERROR = true
                  &PARAM = "(
                  input-output l_ext_actual,
                  input rndmthd,
                  output mc-error-number)"}
         if mc-error-number <> 0
         then do:
            {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
         end. /* IF mc-error-number <> 0 */

         for first t_store_ext_actual
            where t_line = sod_line no-lock:
         end. /* FOR FIRST t_store_ext_actual ... */

         if not available t_store_ext_actual
         then do:
            create t_store_ext_actual.
            assign
               t_line       = sod_line
               t_ext_actual = ext_actual.
         end. /* IF NOT AVAILABLE t_store_ext_actual ... */

         /* USE THE EXISTING LOGIC TO CALCULATE ORDER TOTAL ONLY */
         /* WHEN SALES ORDER DOES NOT HAVE TAX INCLUDED LINES    */
         if l_ord_contains_tax_in_lines = no
         then
            line_total = line_total + ext_actual.

         /* FOR CALL INVOICES, SFB_TAXABLE (IN 86) OF SFB_DET DETERMINES  */
         /* TAXABILITY AND THERE COULD BE MULTIPLE SFB_DET FOR A SOD_DET. */

         if sod_fsm_type = fsmro_c
            and sod_taxable
            and not sod_fix_pr
         then do:
            for each sfb_det no-lock
               where sfb_domain = global_domain
                and  sfb_nbr    = sod_nbr
                and  sfb_so_line = sod_line:
               if sfb_exchange then
                   ext_actual   = 0 - (sfb_exg_price * sfb_qty_ret).
               else
                   ext_actual   = sfb_price * sfb_qty_req.

               /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
               {pxrun.i &PROC = 'mc-curr-rnd' &PROGRAM = 'mcpl.p'
                  &CATCHERROR = true
                  &PARAM = "(
                        input-output ext_actual,
                        input rndmthd,
                        output mc-error-number)"}
               if mc-error-number <> 0 then do:
                  {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
               end.

               if sfb_exchange then
                   l_ext_actual = ext_actual * (1 - so_disc_pct / 100).
               else
                  assign
                     ext_actual   = ext_actual - sfb_covered_amt
                     l_ext_actual = ext_actual * (1 - so_disc_pct / 100).

               {pxrun.i &PROC = 'mc-curr-rnd' &PROGRAM = 'mcpl.p'
                        &CATCHERROR = true
                        &PARAM = "(
                        input-output l_ext_actual,
                        input rndmthd,
                        output mc-error-number)"}
               if mc-error-number <> 0
               then do:
                  {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
               end. /* IF mc-error-number <> 0 */


               if sfb_taxable then
               assign
                  taxable_amt = taxable_amt + l_ext_actual
                  line_taxable_amt = taxable_amt.
               else
                  nontaxable_amt = nontaxable_amt + l_ext_actual.
            end. /* FOR EACH SFB_DET */
         end. /* IF SOD_FSM_TYPE = FSMRO_C ... */
         else if sod_taxable then
            assign
               taxable_amt = taxable_amt + l_ext_actual
               line_taxable_amt = taxable_amt.
         else
            nontaxable_amt = nontaxable_amt + l_ext_actual.
      end.
      {&SOSOTRLF-P-TAG1}
      if maint and not so__qadl01 then do:
         find cm_mstr where cm_domain = global_domain
                        and cm_addr = so_cust no-lock .
         if so_cust <> so_ship and
            can-find (cm_mstr where cm_mstr.cm_domain = global_domain
                                and cm_mstr.cm_addr = so_ship) then
            find cm_mstr where cm_domain = global_domain
                          and  cm_mstr.cm_addr = so_ship no-lock.

         {gprun.i ""sosd.p"" "(
            input so_ord_date,
            input so_ex_rate,
            input so_ex_rate2,
            input so_cust,
            input so_curr,
            input line_total,
            output disc_pct)"}

         l_sodiscpct = so_disc_pct.

         if disc_pct > cm_disc_pct and disc_pct <> 0 then
            so_disc_pct = disc_pct.
         else so_disc_pct = cm_disc_pct .

         /* ISSUE MESSAGE WHEN SO TRAILER DISC GETS CHANGED THROUGH  */
         /* CUSTOMER MAINTENANCE OR VOLUME DISCOUNT MAINTENANCE      */
         /* AND SHIPMENT IS MADE                                     */

         if (not new so_mstr
            and so_disc_pct <> l_sodiscpct)
            and l_qtytoinv
         then do:
            hide message.
            /* DISCOUNT CHANGED. TAXES WILL NOT BE UPDATED FOR QTY-TO-INVOICE */
            {pxmsg.i &MSGNUM=4650 &ERRORLEVEL=2}
            /* USE PENDING INVOICE MAINTENANCE TO ADJUST THOSE TAXES */
            {pxmsg.i &MSGNUM=4651 &ERRORLEVEL=2}
         end.  /* IF (NOT NEW so_mstr AND so_disc_pct <> l_sodiscpct) AND.. */

      end. /* IF MAINT AND NOT SO__QADL01 */

      /* Capture final discount percent for output */
      disc_pct = so_disc_pct.

      /* CALCULATE DISCOUNT AMOUNT */
      /* USE THE EXISTING LOGIC TO CALCULATE DISCOUNT ONLY WHEN */
      /* SALES ORDER DOES NOT HAVE TAX INCLUDED LINES           */
      if l_ord_contains_tax_in_lines = no
      then
         disc_amt = (- line_total * (so_disc_pct / 100)).

      /* ROUND PER DOCUMENT CURRENCY ROUND METHOD */
      {pxrun.i &PROC = 'mc-curr-rnd' &PROGRAM = 'mcpl.p'
         &CATCHERROR = true
         &PARAM = "(
               input-output disc_amt,
               input rndmthd,
               output mc-error-number)"}
      if mc-error-number <> 0 then do:
         {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
      end.

      /* ADD TRAILER AMOUNTS */
      {txtrltrl.i so_trl1_cd so_trl1_amt user_desc1}
      {txtrltrl.i so_trl2_cd so_trl2_amt user_desc2}
      {txtrltrl.i so_trl3_cd so_trl3_amt user_desc3}

   end. /*PROCBLOCK*/

   return {&SUCCESS-RESULT}.
END PROCEDURE. /*GetSOTotalsBeforeTax*/


/*ALDN */
PROCEDURE disp_update_sototxyz. 

         DEFINE VARIABLE v_TotalCube   AS DECIMAL                  NO-UNDO.
         DEFINE VARIABLE v_TotalWeight AS DECIMAL                  NO-UNDO.
         define variable v_totalcarton as integer                  no-undo.
         define variable v_cartons     as integer                  no-undo.
         DEFINE VARIABLE v_qty_order   AS DECIMAL                  NO-UNDO. 

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

         IF new_order THEN so_mstr_a.cust_frt_acct = cm_mstr_a.cust_frt_acct.

         IF AVAILABLE so_mstr THEN DO:
           ASSIGN
             v_SO_FreightTerms = so_fr_terms
             old_fr_terms      = so_fr_terms
             v_fr_policy       = so_user1.
           DISPLAY
             v_SO_FreightTerms
             v_fr_policy
             so_mstr_a.cust_frt_acct
           WITH FRAME sotot. /*sototxyz.*/
         END. /*IF AVAILABLE so_mstr THEN*/ 
  
END. /*PROCEDURE disp_update_sototxyz:*/

PROCEDURE calculate_soamt. 
 
  DEF INPUT  PARAMETER v_nbr LIKE so_nbr. 
  DEF OUTPUT PARAMETER v_amt AS DECIMAL NO-UNDO. 
 
  DEF BUFFER xsod FOR sod_det. 
  DEF BUFFER xso FOR so_mstr. 

  FIND FIRST xso NO-LOCK 
   WHERE  xso.so_domain = global_domain 
     AND  xso.so_nbr    = v_nbr NO-ERROR. 
  FOR EACH xsod NO-LOCK 
       WHERE  xsod.sod_domain = global_domain 
         AND  xsod.sod_nbr    = v_nbr :
    ASSIGN v_amt  =  v_amt + (xsod.sod_price * xsod.sod_qty_ord).
  END. /*FOR EACH b_sod_det WHERE... NO-LOCK:*/
 
  ASSIGN 
    v_amt = v_amt + 
      so_mstr.so_trl1_amt + so_mstr.so_trl2_amt + so_mstr.so_trl3_amt.
END. /* procedure calculate_soamt */
