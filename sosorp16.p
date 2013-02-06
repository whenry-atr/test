/* sosorp16.p - UNCONFIRMED SALES ORDER REPORT                               */
/* Copyright 1986-2004 QAD Inc., Carpinteria, CA, USA.                       */
/* All rights reserved worldwide.  This is an unpublished work.              */
/* $Revision: 1.10.1.6 $                                                         */
/*V8:ConvertMode=Report                                                      */
/* REVISION: 7.3      LAST MODIFIED: 02/08/96   BY: ais *G0NX*               */
/* REVISION: 7.3      LAST MODIFIED: 12/20/96   BY: rxm *G2JR*               */
/* REVISION: 8.6      LAST MODIFIED: 10/24/97   BY: ays *K161*               */
/* REVISION: 8.6E     LAST MODIFIED: 02/23/98   BY: *L007* A. Rahane         */
/* REVISION: 8.6E     LAST MODIFIED: 07/16/98   BY: *L024* Sami Kureishy     */
/* REVISION: 9.1      LAST MODIFIED: 03/24/00   BY: *N08T* Annasaheb Rahane  */
/* REVISION: 9.1      LAST MODIFIED: 08/14/00   BY: *N0K6* Mudit Mehta       */
/* REVISION: 9.1      LAST MODIFIED: 10/25/00   BY: *N0T7* Jean Miller       */
/* Revision: 1.10.1.4  BY: Hareesh V DATE: 06/21/02 ECO: *N1HY* */
/* $Revision: 1.10.1.6 $ BY: Paul Donnelly (SB) DATE: 06/28/03 ECO: *Q00L* */
/*-Revision end---------------------------------------------------------------*/

/******************************************************************************/
/* All patch markers and commented out code have been removed from the source */
/* code below. For all future modifications to this file, any code which is   */
/* no longer required should be deleted and no in-line patch markers should   */
/* be added.  The ECO marker should only be included in the Revision History. */
/******************************************************************************/

/* DISPLAY TITLE */
{mfdtitle.i "2+ "}

define variable cust                   like so_cust                    no-undo.
define variable cust1                  like so_cust                    no-undo.
define variable nbr                    like so_nbr                     no-undo.
define variable nbr1                   like so_nbr                     no-undo.
define variable ord                    like so_ord_date                no-undo.
define variable ord1                   like so_ord_date                no-undo.
define variable name                   like ad_name                    no-undo.
define variable desc1                  like pt_desc1 format "x(49)"    no-undo.
define variable base_rpt               like so_curr
                                       label "Currency (Blank for All)" no-undo.
define variable mixed_rpt              like mfc_logical initial no
                                       label "Mixed Currencies"        no-undo.
define variable disp_curr              as   character format "x(1)" label "C"
                                                                       no-undo.
define variable po                     like so_po                      no-undo.
define variable po1                    like so_po                      no-undo.
define variable quote                  like so_quote                   no-undo.
define variable quote1                 like so_quote                   no-undo.
define variable incl_unconf_heads      like mfc_logical
                                       label "Include lines with unconfirmed headers"
                                                                       no-undo.
define variable print_customer_header  as   logical                    no-undo.
define variable base_price             like sod_price                  no-undo.
define variable curr_price             like sod_price                  no-undo.
define variable ext_base_price         like sod_price label "Ext Price"
                                       format "->,>>>,>>>,>>9.99"      no-undo.
define variable ext_base_price_unrnd   like sod_price                  no-undo.
define variable ext_curr_price         like sod_price label "Ext Price"
                                       format "->,>>>,>>>,>>9.99"      no-undo.
define variable ext_curr_price_unrnd   like sod_price                  no-undo.
define variable v_disp_line1           as   character format "x(40)"
                                       label "Exch Rate"               no-undo.
define variable v_disp_line2           as   character format "x(40)"   no-undo.
define variable v_cust_po              as   character format "x(31)"   no-undo.
define variable v_cust_po_label        as   character                  no-undo.
define variable mc-error-number        like msg_nbr                    no-undo.
DEF VAR v_ord_entry_mthd               AS CHARACTER FORMAT "X" 
                                       INITIAL "A"   NO-UNDO .

{gpcurrp.i}

form header
   skip(1)
with frame phead1 page-top width 132.

form
   skip
with frame skipline width 132.

form
   nbr                               colon 20
   nbr1               label "To"     colon 49 skip
   cust                              colon 20
   cust1              label "To"     colon 49 skip
   ord                               colon 20
   ord1               label "To"     colon 49 skip
   po                                colon 20
   po1                label "To"     colon 49 skip
   quote                             colon 20
   quote1             label "To"     colon 49 skip(1)
   base_rpt                          colon 45 skip
   mixed_rpt                         colon 45 skip
   incl_unconf_heads                 colon 45
   v_ord_entry_mthd                  COLON 45
       LABEL "Order Entry Method; E=EDI ''=Other A=All" 


with frame a side-labels width 80.

/* SET EXTERNAL LABELS */
setFrameLabels(frame a:handle).

define frame b
   so_nbr
   v_cust_po
   so_ship
   so_ord_date
   so_stat
   so_curr
   so_fr_terms
   freight_policy
   so_mstr_a.ord_entry_mthd
   so_cr_terms
with down width 132 no-box.

/* SET EXTERNAL LABELS */
setFrameLabels(frame b:handle).

assign
   substring(v_cust_po_label, 1) = getTermLabel("SOLD-TO",8)
   substring(v_cust_po_label, 9) = " " + getTermLabel("PURCHASE_ORDER",21)
   v_cust_po:LABEL in frame b    = v_cust_po_label.

form
   space(10)
   sod_line
   sod_part
   sod_um
   sod_qty_ord
   disp_curr
   base_price
   ext_base_price
   sod_due_date
   sod_type
   sod_taxc column-label "Tax"
   sod_site
with frame c down width 132 no-box.

/* SET EXTERNAL LABELS */
setFrameLabels(frame c:handle).

for first gl_ctrl
   fields( gl_domain gl_ex_round)
    where gl_ctrl.gl_domain = global_domain no-lock:
end. /* FOR FIRST gl_ctrl */

{wbrp01.i}

repeat:

   for each order_wkfl
   exclusive-lock:
      delete order_wkfl.
   end. /* FOR EACH order_wkfl */

   if nbr1   = hi_char  then nbr1   = "".
   if cust1  = hi_char  then cust1  = "".
   if ord    = low_date then ord    = ?.
   if ord1   = hi_date  then ord1   = ?.
   if po1    = hi_char  then po1    = "".
   if quote1 = hi_char  then quote1 = "".

   if c-application-mode <> 'web'
   then
      update
         nbr
         nbr1
         cust
         cust1
         ord
         ord1
         po
         po1
         quote
         quote1
         base_rpt
         mixed_rpt
         incl_unconf_heads
         v_ord_entry_mthd
      with frame a.

   {wbrp06.i &command = update &fields = "  nbr nbr1 cust cust1 ord
               ord1 po po1 quote quote1 base_rpt  mixed_rpt incl_unconf_heads"
      &frm = "a"}

   if (c-application-mode     <> 'web')
      or  (c-application-mode  = 'web'
      and (c-web-request begins  'data'))
   then do:

      bcdparm = "".
      {gprun.i ""gpquote.p"" "(input-output bcdparm, 20,
                  nbr, nbr1, cust, cust1, string(ord), string(ord1),
                  po, po1, quote, quote1, base_rpt, string(mixed_rpt),
                  string(incl_unconf_heads), v_ord_entry_mthd, null_char,
                  null_char, null_char, null_char, null_char, null_char)"}

      if nbr1   = "" then nbr1   = hi_char.
      if cust1  = "" then cust1  = hi_char.
      if ord    = ?  then ord    = low_date.
      if ord1   = ?  then ord1   = hi_date.
      if po1    = "" then po1    = hi_char.
      if quote1 = "" then quote1 = hi_char.
   end. /* IF c-application-mode <> 'web' OR ... */

   /* OUTPUT DESTINATION SELECTION */
   {gpselout.i &printType = "printer"
               &printWidth = 132
               &pagedFlag = " "
               &stream = " "
               &appendToFile = " "
               &streamedOutputToTerminal = " "
               &withBatchOption = "yes"
               &displayStatementType = 1
               &withCancelMessage = "yes"
               &pageBottomMargin = 6
               &withEmail = "yes"
               &withWinprint = "yes"
               &defineVariables = "yes"}

   {mfphead.i}

   view frame phead1.

   /* GET SALES ORDER RECORD  */
   for each sod_det
      fields( sod_domain sod_confirm sod_desc    sod_due_date sod_line sod_nbr
      sod_part
             sod_price   sod_qty_ord sod_sched    sod_taxc sod_type sod_um)
       where sod_det.sod_domain = global_domain and (   not sod_sched
         and not sod_confirm
         and sod_nbr >= nbr
         and sod_nbr <= nbr1
         ) no-lock,
      each so_mstr
      fields( so_domain so_conf_date so_cr_terms so_curr     so_cust so_disc_pct
             so_exru_seq  so_ex_rate  so_ex_rate2 so_nbr  so_ord_date
             so_po        so_quote    so_ship     so_stat)
       where so_mstr.so_domain = global_domain and (  so_nbr = sod_nbr
         and (incl_unconf_heads
             or so_conf_date <> ?)
         and (base_rpt   = so_curr
             or base_rpt = "")
         and so_cust     >= cust
         and so_cust     <= cust1
         and so_ord_date >= ord
         and so_ord_date <= ord1
         and so_po       >= po
         and so_po       <= po1
         and so_quote    >= quote
         and so_quote    <= quote1
         ) no-lock
/*        ,                                    */
/*        EACH so_mstr_a                       */
/*             WHERE so_nbr = sls_ord NO-LOCK, */
/*        EACH cm_mstr_a WHERE addr = so_cust  */
/*             NO-LOCK                         */
         break
            by sod_nbr
            by sod_line
      with frame c:

/*       IF v_ord_entry_mthd = "E" AND so_mstr_a.ord_entry_mthd <> "E"  THEN */
/*           NEXT .                                                          */

      if first-of(sod_nbr)
      then do:
         if page-size - line-counter < 2
         then
            view frame skipline.

         name = "".
         for first ad_mstr
            fields( ad_domain ad_addr ad_name)
             where ad_mstr.ad_domain = global_domain and  ad_addr = so_cust
         no-lock:

            name = ad_name.
         end. /* FOR FIRST ad_mstr */

         {gprunp.i "mcui" "p" "mc-ex-rate-output"
            "(input  so_curr,
              input  base_curr,
              input  so_ex_rate,
              input  so_ex_rate2,
              input  so_exru_seq,
              output v_disp_line1,
              output v_disp_line2)"}

         assign
            v_cust_po               = ""
            substring(v_cust_po, 1) = so_cust
            substring(v_cust_po, 9) = " " + so_po.

         display
            so_nbr
            v_cust_po
            so_ship
            so_ord_date
            so_stat
            so_curr
            so_fr_terms
/*             freight_policy           */
/*             so_mstr_a.ord_entry_mthd */
            so_disc_pct
            so_cr_terms
         with frame b.

         if name            <> ""
            or v_disp_line2 <> ""
         then do:

            down with frame b.
            display
               name         @ v_cust_po
               v_disp_line2 @ v_disp_line1
            with frame b.

         end.  /* IF name  <> " " OR ... */

      end. /* IF FIRST-OF(sod_nbr) */

      /* SET CURRENCY CONVERTED FLAG */
      disp_curr = "".
      if base_curr    <> so_curr
         and base_rpt <> so_curr
      then
         disp_curr = getTermLabel("YES",1).

      if base_rpt  = ""
      then
         disp_curr = "".

      /* SET PRICE FOR CURR AND BASE */
      curr_price = sod_price.

      {gprunp.i "mcpl" "p" "mc-curr-conv"
         "(input so_curr,
           input base_curr,
           input so_ex_rate,
           input so_ex_rate2,
           input sod_price,
           input false,
           output base_price,
           output mc-error-number)"}

      if mc-error-number <> 0
      then do:
         {pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=2}
      end. /* IF mc-error-number <> 0 */

      assign

         /* CALCULATE EXTENDED PRICE AND BASE TOTAL */
         ext_curr_price = sod_qty_ord * curr_price
         ext_base_price = sod_qty_ord * base_price

         /* SAVE UNROUNDED RESULTS */
         ext_curr_price_unrnd = ext_curr_price
         ext_base_price_unrnd = ext_base_price

         /* ROUND RESULTS */
         ext_curr_price = round(ext_curr_price, gl_ex_round)
         ext_base_price = round(ext_base_price, gl_ex_round).

      /* ACCUMULATE SUB-TOTALS */
      accumulate ext_curr_price (total by sod_nbr).
      accumulate ext_base_price (total by sod_nbr).
      accumulate ext_curr_price_unrnd (total by sod_nbr).
      accumulate ext_base_price_unrnd (total by sod_nbr).

      desc1 = sod_desc.
      for first pt_mstr
         fields( pt_domain pt_part pt_desc1 pt_desc2)
          where pt_mstr.pt_domain = global_domain and  pt_part = sod_part
      no-lock :

         desc1 = pt_desc1 + " " + pt_desc2.
      end. /* FOR FIRST pt_mstr */

      if page-size - line-counter <= 2
      then
         page.

      /* PRINT DETAIL LINE */
      if base_curr    = so_curr
         or (base_rpt = ""
             and not mixed_rpt)
      then do:
         display
            sod_line
            sod_part
            sod_um
            sod_qty_ord
            disp_curr
            base_price
            ext_base_price
            sod_due_date
            sod_type
            sod_taxc
            sod_site
         with frame c.
         down with frame c.
      end. /* IF base_curr = so_curr OR ... */
      else do:
         display
            sod_line
            sod_part
            sod_um
            sod_qty_ord
            disp_curr
            curr_price @ base_price
            ext_curr_price @ ext_base_price
            sod_due_date
            sod_type
            sod_taxc
            sod_site
         with frame c.
         down with frame c.
      end. /* ELSE DO */

      put desc1 at 16.

      if last-of(sod_nbr)
      then do:

         /* STORE SALES ORDER TOTALS, BY CURRENCY, IN WORKFILE */
         if base_rpt = ""
            and mixed_rpt
         then do:
            find first order_wkfl where so_curr = ordwk_curr
            exclusive-lock no-error.
            if not available order_wkfl
            then do:
               create order_wkfl.
               ordwk_curr = so_curr.
            end. /* IF NOT AVAILABLE order_wkfl */

            /* ACCUMULATE INDIVIDUAL CURRENCY TOTALS IN WORK FILE. */
            assign
               ordwk_for = ordwk_for +
                  (accum total by sod_nbr ext_curr_price_unrnd)
               ordwk_base = ordwk_base +
                  (accum total by sod_nbr ext_base_price_unrnd).
         end. /* IF base_rpt = "" AND ... */

         /*  DISPLAY SALES ORDER TOTAL.      */
         if (accum total by sod_nbr ext_curr_price) <> 0
         then do:

            if page-size - line-counter < 2
            then
               page.

            underline ext_base_price.

            /* DISPLAY CURRENCY TOTAL */
            if not (base_rpt = ""
               and not mixed_rpt)
            then do:
               display
                  so_curr + " "
                     + getTermLabel("ORDER_TOTAL",13) + ":" @ sod_part
                  accum total by sod_nbr ext_curr_price @ ext_base_price
               with frame c.
            end. /* IF NOT (base_rpt = "" AND ... */

            /* DISPLAY BASE TOTAL */
            if (base_rpt = ""
                and not mixed_rpt)
               or (base_rpt = ""
                and mixed_rpt
                and so_curr <> base_curr)
            then do:

               down 1.
               display
                  getTermLabel("BASE_ORDER_TOTAL",17) + ":" @ sod_part
                  accum total by sod_nbr ext_base_price
                  @ ext_base_price
               with frame c.
            end. /* IF NOT (base_rpt = "" AND ... */

            accumulate (accum total by sod_nbr ext_base_price) (total).
            accumulate (accum total by sod_nbr ext_curr_price) (total).
            accumulate (accum total by sod_nbr ext_base_price_unrnd) (total).
            accumulate (accum total by sod_nbr ext_curr_price_unrnd) (total).
            down 2 with frame c.
         end.  /* IF (ACCUM TOTAL BY sod_nbr ext_curr_price) <> 0 */

      end.  /* IF LAST-OF(sod_nbr) */

      /* DISPLAY REPORT TOTAL */
      if last(sod_nbr)
      then do:

         if (page-size - line-counter < 2)
            and not (base_rpt = ""
            and mixed_rpt)
         then
            page.

         underline
            ext_base_price
         with frame c.

         /* DISPLAY CURRENCY TOTAL */
         if base_rpt <> ""
         then do:
            display
               so_curr + " " + getTermLabel("REPORT_TOTAL",13) + ":" @ sod_part
               accum total (accum total by sod_nbr ext_curr_price)
               @ ext_base_price
            with frame c.
         end. /* IF base_rpt <> "" */
         else do: /* DISPLAY BASE TOTAL */

            down 1.
            display
               getTermLabel("BASE_REPORT_TOTAL",17) + ":" @ sod_part
               accum total (accum total by sod_nbr ext_base_price)
               @ ext_base_price
            with frame c.
         end. /* ELSE DO */

         /* IF ALL CURRENCIES, PRINT A SUMMARY REPORT BY CURRENCY.*/
         if base_rpt = ""
            and mixed_rpt
         then do:
            {gprun.i ""gpcurrp.p""}.
         end. /* IF base_rpt = "" AND ... */

         {mfrpchk.i}

      end. /* IF LAST(sod_nbr) */

      {mfrpchk.i}

   end. /* FOR EACH sod_det */

   /* REPORT TRAILER */
   {mfrtrail.i}

end. /* REPEAT */

{wbrp04.i &frame-spec = a}

