/* dsdopk01.p - DISTRIBUTION ORDER PICKLIST                                   */
/* Copyright 1986-2003 QAD Inc., Carpinteria, CA, USA.                        */
/* All rights reserved worldwide.  This is an unpublished work.               */
/* $Revision: 1.27.3.1 $                                                          */
/*V8:ConvertMode=Report                                                       */
/* REVISION: 7.0      LAST MODIFIED: 06/08/92   BY: emb *F611*                */
/* REVISION: 7.3      LAST MODIFIED: 03/30/94   BY: pxd *GJ23*                */
/* REVISION: 7.3      LAST MODIFIED: 08/25/94   BY: rxm *GL46*                */
/* Oracle changes (share-locks)      09/11/94   BY: rwl *GM27*                */
/* REVISION: 7.3      LAST MODIFIED: 12/29/94   BY: pxd *F0BF*                */
/* REVISION: 8.5      LAST MODIFIED: 01/03/95   BY: mwd *J034*                */
/* REVISION: 7.3      LAST MODIFIED: 01/05/95   BY: srk *G0B8*                */
/* REVISION: 7.3      LAST MODIFIED: 03/29/95   BY: dzn *F0PN*                */
/* REVISION: 7.3      LAST MODIFIED: 11/20/95   BY: qzl *G1DV*                */
/* REVISION: 8.5      LAST MODIFIED: 06/20/96   BY: taf *J0VG*                */
/* REVISION: 8.5      LAST MODIFIED: 08/07/96   BY: *G2BN* Russ Witt          */
/* REVISION: 7.4      LAST MODIFIED: 02/04/98   BY: *H1JC* Jean Miller        */
/* REVISION: 8.6E     LAST MODIFIED: 02/23/98   BY: *L007* A. Rahane          */
/* REVISION: 8.6E     LAST MODIFIED: 10/04/98   BY: *J314* Alfred Tan         */
/* REVISION: 8.6E     LAST MODIFIED: 10/14/98   BY: *K1XQ* Thomas Fernandes   */
/* REVISION: 9.0      LAST MODIFIED: 02/06/99   BY: *M06R* Doug Norton        */
/* REVISION: 9.0      LAST MODIFIED: 03/13/99   BY: *M0BD* Alfred Tan         */
/* REVISION: 9.1      LAST MODIFIED: 08/26/99   BY: *N039* Poonam Bahl        */
/* REVISION: 9.1      LAST MODIFIED: 03/14/00   BY: *L0TR* Rajesh Kini        */
/* REVISION: 9.1      LAST MODIFIED: 03/24/00   BY: *N08T* Annasaheb Rahane   */
/* REVISION: 9.1      LAST MODIFIED: 07/26/00   BY: *N0GQ* Mudit Mehta        */
/* Revision: 1.22     BY: Robin McCarthy        DATE: 07/31/01 ECO: *P009*    */
/* Revision: 1.23     BY: Robin McCarthy        DATE: 08/21/01 ECO: *P01P*    */
/* Revision: 1.24     BY: Tiziana Giustozzi     DATE: 09/28/01 ECO: *N138*    */
/* Revision: 1.27     BY: Dave Caveney          DATE: 08/30/02 ECO: *P0HB*    */
/* $Revision: 1.27.3.1 $    BY: Geeta Kotian          DATE: 10/29/03 ECO: *P17M*    */

/******************************************************************************/
/* All patch markers and commented out code have been removed from the source */
/* code below. For all future modifications to this file, any code which is   */
/* no longer required should be deleted and no in-line patch markers should   */
/* be added.  The ECO marker should only be included in the Revision History. */
/******************************************************************************/

{mfdtitle.i "2+ "}

define new shared variable ds_recno as recid.
define new shared variable qty_to_all like ds_qty_all.
define new shared variable rec_site like dss_rec_site.
define new shared variable rec_site1 like dss_rec_site.
define new shared variable src_site like dss_shipsite.
define new shared variable src_site1 like dss_shipsite.
define new shared variable nbr like dss_nbr.
define new shared variable nbr1 like dss_nbr.
define new shared variable ord like dss_created.
define new shared variable ord1 like dss_created.
define new shared variable company as character format "x(38)" extent 6.
define new shared variable addr    as character format "x(38)" extent 6.
define new shared variable lang  like dss_lang.
define new shared variable lang1 like dss_lang.
define new shared variable dss_recno as recid.

define buffer ship for ad_mstr.

define variable form_code as character format "x(2)" label "Form Code" no-undo.
define variable comp_addr like soc_company no-undo.
define variable update_yn like mfc_logical initial yes label "Update" no-undo.
define variable weight_um like tm_weight_um no-undo.
define variable cube_um   like tm_cube_um   no-undo.
define variable weight_conv like um_conv no-undo.
define variable cube_conv   like um_conv no-undo.
define variable i as integer no-undo.
define variable cum_weight like pt_ship_wt label "Cum Weight" no-undo.
define variable cum_cube like pt_size label "Cum Cube" no-undo.
define variable item_count as integer label "Item Count" no-undo.
define variable any_open like mfc_logical no-undo.
define variable qty_open like ds_qty_ord format "->>>>>>9.9<<<<<"
   label "Qty Open" no-undo.
define variable desc1 like pt_desc1 no-undo.
define variable pages as integer no-undo.
define variable billto as character format "x(38)" extent 6 no-undo.
define variable shipto as character format "x(38)" extent 6 no-undo.
define variable termsdesc like ct_desc no-undo.
define variable billattn like ad_attn no-undo.
define variable shipattn like ad_attn no-undo.
define variable billphn like ad_phone no-undo.
define variable shipphn like ad_phone no-undo.
define variable first_line like  mfc_logical no-undo.
define variable desc2 like pt_desc2 no-undo.
define variable cont_lbl as character format "x(12)" no-undo.
define variable c-cont as character format "x(35)" no-undo.
define variable disp-do-pklist as character format "x(72)" no-undo.
define variable shipped as character format "x(9)" no-undo.
define variable totpkqty like ds_qty_pick no-undo.
define variable totallqty like ds_qty_all no-undo.
define variable req-nbr like ds_req_nbr no-undo.

assign
   cont_lbl = dynamic-function('getTermLabelFillCentered' in h-label,
              input "CONTINUE", input 12, input '*')
   c-cont = CAPS(dynamic-function('getTermLabelFillCentered' in h-label,
              input "CONTINUED",
              input 35,
              input '*')).

/* FACILITATE UPDATE FLAG AS REPORT INPUT CRITERIA, TO      */
/* ELIMINATE USER INTERACTION AT THE END OF THE REPORT      */
form
   nbr            colon 20
   nbr1           label {t001.i} colon 49 skip
   src_site       colon 20
   src_site1      label {t001.i} colon 49 skip
   rec_site       colon 20
   rec_site1      label {t001.i} colon 49 skip
   ord            colon 20
   ord1           label {t001.i} colon 49 skip
   lang           colon 20
   lang1          label {t001.i} colon 49
   update_yn      colon 20 skip(1)
   comp_addr      colon 20 skip
with frame a side-labels width 80.

/* SET EXTERNAL LABELS */
setFrameLabels(frame a:handle).

assign
   src_site = global_site
   src_site1 = global_site.

mainloop:
repeat:
   if nbr1 = hi_char then nbr1 = "".
   if src_site1 = hi_char then src_site1 = "".
   if rec_site1 = hi_char then rec_site1 = "".
   if lang1 = hi_char then lang1 = "".
   if form_code = "" then form_code = "1".
   assign company = "".

   update
      nbr nbr1
      src_site src_site1
      rec_site rec_site1
      ord ord1
      lang lang1
      update_yn
      comp_addr
   with frame a.

   bcdparm = "".

   {gprun.i ""gpquote.p""
            "(input-output bcdparm,
              input 12,
              input nbr,
              input nbr1,
              input src_site,
              input src_site1,
              input rec_site,
              input rec_site1,
              input string(ord),
              input string(ord1),
              input lang,
              input lang1,
              input string(update_yn),
              input comp_addr,
              input null_char,
              input null_char,
              input null_char,
              input null_char,
              input null_char,
              input null_char,
              input null_char,
              input null_char)"}

   if nbr1 = "" then nbr1 = hi_char.
   if src_site1 = "" then src_site1 = hi_char.
   if rec_site1 = "" then rec_site1 = hi_char.
   if lang1 = "" then lang1 = hi_char.

   /* CHECK SITE SECURITY */
   {gprun.i ""gpsirvr.p""
      "(input src_site, input src_site1, output return_int)"}

   if return_int = 0
   then do:
      if not batchrun
      then do:
         next-prompt src_site with frame a.
         undo mainloop, retry mainloop.
      end.
      else
         undo mainloop, leave mainloop.
   end.

   if comp_addr <> ""
   then do:
      find ad_mstr where ad_addr = comp_addr no-lock no-error.
      if available ad_mstr
      then do:
         find ls_mstr where ls_addr = ad_addr and ls_type = "company"
         no-lock no-error.
         if not available ls_mstr
         then do:
            {pxmsg.i &MSGNUM = 28 &ERRORLEVEL = 3} /* NOT A VALID COMPANY */
            next-prompt comp_addr with frame a.
            undo, retry.
         end.

         assign
            addr[1] = ad_name
            addr[2] = ad_line1
            addr[3] = ad_line2
            addr[4] = ad_line3
            addr[6] = ad_country.

         {mfcsz.i addr[5] ad_city ad_state ad_zip}
         {gprun.i ""gpaddr.p"" }

         assign
            company[1] = addr[1]
            company[2] = addr[2]
            company[3] = addr[3]
            company[4] = addr[4]
            company[5] = addr[5]
            company[6] = addr[6].
      end.

      else do:
         {pxmsg.i &MSGNUM = 28 &ERRORLEVEL = 3} /* NOT A VALID COMPANY */
         next-prompt comp_addr with frame a.
         undo, retry.
      end.

   end. /* if comp_addr <> "" */

   /* OUTPUT DESTINATION SELECTION */
   {gpselout.i &printType = "printer"
               &printWidth = 80
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

   if not update_yn
   then do:
      /* FACILITATING ROLLING BACK OF TRANSACTIONS BEFORE EXECUTING */
      /* THE REPORT AND LOCKING ANY RECORDS                         */
      mainloop:
      do transaction:
         run p_picklist.

         /* UNDOING CHANGES TO THE DATABASE IN SIMULATION MODE */
         undo mainloop, leave mainloop.

      end. /* DO TRANSACTION */

   end. /* IF NOT UPDATE_YN */

   else do:
      /* DISALLOWING ROLLBACK OF RECORDS MODIFIED DURING THE REPORT */
      /* WHEN UPDATE INPUT CRITERIA IS YES                          */
      run p_picklist.

   end. /* UPDATE_YN = YES */

   {mfreset.i}

end.

PROCEDURE p_picklist:

   /* THIS PROCEDURE DOES THE REPORT PRINTING AND DATABASE UPDATION */

   /* DEFINED THE FOLLOWING BUFFERS TO LIMIT THE RECORD SCOPE TO    */
   /* INTERNAL PROCEDURE                                            */
   define buffer lad_det  for lad_det.
   define buffer ds_det   for ds_det.

   form with frame c down width 80 no-attr-space no-box.

   /* SET EXTERNAL LABELS */
   setFrameLabels(frame c:handle).

   pages = 0.

   /* FOR UPDATE = YES, LIMITING THE TRANSACTION SCOPE FOR ONE       */
   /* DSS_MSTR RECORD AT A TIME AND MAINTAIN DATABASE INTEGRITY      */
   for each dss_mstr
      where (dss_nbr >= nbr)
        and (dss_nbr <= nbr1)
        and (dss_shipsite >= src_site)
        and (dss_shipsite <= src_site1)
        and (dss_rec_site >= rec_site)
        and (dss_rec_site <= rec_site1)
        and (dss_created >= ord or ord = ?)
        and (dss_created <= ord1 or ord1 = ?)
        and (dss_lang >= lang and dss_lang <= lang1)
        and can-find (first ds_det where ds_nbr = dss_nbr)
      no-lock by dss_nbr with frame b no-box

      transaction:

      any_open = false.

      for each ds_det
         where ds_nbr = dss_nbr
           and ds_shipsite = dss_shipsite
           and ds_site = dss_rec_site
           and (ds_qty_conf >= 0
           and ds_qty_ship < ds_qty_conf)
         no-lock:

         assign
            totpkqty  = 0
            totallqty = 0.

         for each lad_det no-lock
            where lad_dataset = "ds_det"
              and lad_nbr = ds_req_nbr
              and lad_line = ds_site
              and lad_part = ds_part
              and lad_site = ds_shipsite:

            assign
               totallqty = totallqty + lad_qty_all
               totpkqty = totpkqty + lad_qty_pick.
         end. /* FOR EACH LAD_DET */


         qty_to_all = max(ds_qty_conf - max(ds_qty_ship, 0)
                    - max(totallqty, 0) - max(totpkqty, 0), 0).


/*LF01 - MERGE SALES ALLOCATIONS INTO DRP FUNCTIONS */

         run SO-allmerge(input  ds_part,
                         input  ds_shipsite,
                         input  ds_due_date,
                         input-output qty_to_all).    
         
         if qty_to_all > 0
         then do:
            ds_recno = recid(ds_det).
            {gprun.i ""dspkall.p""}
         end. /* IF QTY_TO_ALL > 0 */

         if ds_qty_all <> 0 then
            any_open = true.

      end. /* FOR EACH DS_DET */

      if not any_open then
         next.

      for each ds_det exclusive-lock
         where ds_nbr = dss_nbr
           and ds_shipsite = dss_shipsite
           and ds_site = dss_rec_site
           and ds_qty_all <> 0
           /* ADDED can-find TO AVOID DISPLAYING HEADS FOR THOSE */
           /* DOs THAT HAVE NOTHING TO PICK.                     */
           and can-find(first lad_det where lad_dataset = "ds_det"
           and lad_nbr = ds_req_nbr
           and lad_line = ds_site
           and lad_part = ds_part
           and lad_site = ds_shipsite)
           use-index ds_nbr
         break by ds_shipdate by ds_trans_id by ds_part with frame c:

         if first-of (ds_shipdate)
         then do:
            assign
               disp-do-pklist = getTermLabel("BANNER_DISTRIBUTION_ORDER",45)
                              + "  " + getTermLabel("BANNER_PICKLIST",25)
               disp-do-pklist = fill(" ", 72 - length(disp-do-pklist))
                              + disp-do-pklist.

            form header
               skip (2)
               disp-do-pklist    to 80
               skip(1)
               company[1]        at 4
               if not update_yn then
                  getTermLabelRt("BANNER_SIMULATION",28)
               else
                  ""                to 80 format "x(28)"
               getTermLabelRtColon("ORDER_NUMBER",14)  to 56 format "x(14)"
               dss_nbr           at 58
               getTermLabel("PAGE_OF_REPORT",4) + ": "
               + string(page-number - pages,">>9") format "x(9)"
                                 to 80
               company[2]        at 4
               getTermLabelRtColon("ORDER_DATE",14)  to 56 format "x(14)"
               dss_created       at 58
               company[3]        at 4
               getTermLabelRtColon("PRINT_DATE",14)  to 56 format "x(14)"
               today             at 58
               company[4]        at 4
               getTermLabelRtColon("SHIP_DATE",14)  to 56 format "x(14)"
               ds_shipdate
               company[5]        at 4
               company[6]        at 4
               getTermLabelRtColon("STATUS",10)  to 56 format "x(10)"
               dss_status        at 58
            with frame phead1 page-top width 90.

            form
               space(7)
               dss_shipsite
               dss_rec_site   colon 53 skip (1)
               billto[1] at 8 no-label shipto[1] at 46 no-label
               billto[2] at 8 no-label shipto[2] at 46 no-label
               billto[3] at 8 no-label shipto[3] at 46 no-label
               billto[4] at 8 no-label shipto[4] at 46 no-label
               billto[5] at 8 no-label shipto[5] at 46 no-label
               billto[6] at 8 no-label shipto[6] at 46 no-label
               skip
            with frame phead2 side-labels page-top width 90.

            /* SET EXTERNAL LABELS */
            setFrameLabels(frame phead2:handle).

            form header
               fill("-",80)   format "x(80)" skip
               space(30)
               c-cont
            with frame continue page-bottom width 80
            no-box no-attr-space.

            form
               billattn     colon 15
               shipattn     colon 53
               billphn      colon 15
               shipphn      colon 53
               skip (1)
               dss_po_nbr   colon 59
               dss_shipvia  colon 59
               termsdesc    colon 15 no-label
               dss_fob      colon 59
               dss_rmks     colon 15
               skip (1)
            with frame phead3 side-labels
            page-top width 90 no-box.

            /* SET EXTERNAL LABELS */
            setFrameLabels(frame phead3:handle).

            if comp_addr = ""
            then do:
               company = "".
               find ad_mstr where ad_addr = dss_shipsite
                  no-lock no-error.
               if available ad_mstr
               then do:
                  assign
                     addr[1] = ad_name
                     addr[2] = ad_line1
                     addr[3] = ad_line2
                     addr[4] = ad_line3
                     addr[6] = ad_country.

                  {mfcsz.i addr[5] ad_city ad_state ad_zip}
                  {gprun.i ""gpaddr.p"" }

                  assign
                     company[1] = addr[1]
                     company[2] = addr[2]
                     company[3] = addr[3]
                     company[4] = addr[4]
                     company[5] = addr[5]
                     company[6] = addr[6].
               end. /* IF AVAILABLE AD_MSTR */

            end. /* IF COMP_ADDR = "" */

            assign
               weight_um = ""
               cube_um = "".

            find tm_mstr where tm_code = dss_shipvia
               no-lock no-error.
            if available tm_mstr then
               assign
                  cube_um = tm_cube_um
                  weight_um = tm_weight_um.

            assign
               first_line = yes
               dss_recno = recid(dss_mstr)
               billto = ""
               shipto = "".

            find ad_mstr where ad_addr = dss_shipsite
               no-lock no-error.
            if available ad_mstr
            then do:
               assign
                  addr[1] = ad_name
                  addr[2] = ad_line1
                  addr[3] = ad_line2
                  addr[4] = ad_line3
                  addr[6] = ad_country.

               {mfcsz.i addr[5] ad_city ad_state ad_zip}
               {gprun.i ""gpaddr.p"" }

               assign
                  billto[1] = addr[1]
                  billto[2] = addr[2]
                  billto[3] = addr[3]
                  billto[4] = addr[4]
                  billto[5] = addr[5]
                  billto[6] = addr[6].

               assign
                  billattn = ad_attn.
                  billphn = ad_phone.
            end. /* IF AVAILABLE AD_MSTR */

            find ad_mstr where ad_addr = dss_rec_site
               no-lock no-error.

            if available ad_mstr
            then do:
               assign
                  addr[1] = ad_name
                  addr[2] = ad_line1
                  addr[3] = ad_line2
                  addr[4] = ad_line3
                  addr[6] = ad_country.

               {mfcsz.i addr[5] ad_city ad_state ad_zip}
               {gprun.i ""gpaddr.p"" }

               assign
                  shipto[1] = addr[1]
                  shipto[2] = addr[2]
                  shipto[3] = addr[3]
                  shipto[4] = addr[4]
                  shipto[5] = addr[5]
                  shipto[6] = addr[6].

               assign
                  shipattn = ad_attn.
                  shipphn = ad_phone.
            end. /* IF AVAILABLE AD_MSTR */

            hide frame phead1.
            view frame phead1.

            pages = page-number - 1.

            hide frame phead2.

            display
               dss_shipsite
               dss_rec_site
               billto
               shipto
            with frame phead2.

            display
               billattn
               shipattn
               billphn
               shipphn
               dss_po
               dss_shipvia
               termsdesc
               dss_fob
               dss_rmks
            with frame phead3.

            hide frame phead2.
            hide frame phead3.

            /* PRINT COMMENTS */
            {gpcmtprt.i
               &type=PA &id=dss_cmtindx &pos=3 &command="down 1".}

            assign
               cum_weight = 0
               cum_cube   = 0
               item_count = 0.

         end. /* IF FIRST-OF (DS_SHIP) */

         assign
            desc1 = ""
            desc2 = ""
            req-nbr = ds_req_nbr.

         find pt_mstr where pt_part = ds_part no-lock no-error.
         if available pt_mstr
         then do:
            assign
               desc1 = pt_desc1
               desc2 = pt_desc2.
         end.

         if ds_qty_ord >= 0 then
            qty_open = max(ds_qty_conf - max(ds_qty_ship, 0), 0).
         else
            qty_open = min(ds_qty_conf - min(ds_qty_ship, 0), 0).

         assign
            weight_conv = 1
            cube_conv = 1.

         if weight_um = "" and ds_fr_wt_um <> "" then
            weight_um = ds_fr_wt_um.

         if cube_um = "" and ds_fr_wt_um <> "" then
            cube_um = ds_fr_wt_um.

         if weight_um = "" or cube_um = ""
         then do:
            find tm_mstr where tm_code = ds_trans_id
               no-lock no-error.
            if available tm_mstr then
               assign
                  cube_um   = if cube_um = "" then tm_cube_um
                              else cube_um
                  weight_um = if weight_um = "" then tm_weight_um
                              else weight_um.
         end. /* IF WEIGHT_UM = "" OR CUBE_UM = "" */

         if pt_ship_wt_um <> weight_um
         then do:
            /* UNIT OF MEASURE CONVERSION */
            {gprun.i ""gpumcnv.p""
                     "(input pt_ship_wt_um,
                       input weight_um,
                       input pt_part,
                       output weight_conv)"}
            if weight_conv = ? then
               weight_conv = 1.
         end. /* IF PT_SHIP_WT_UM <> WEIGHT_UM */

         if pt_size_um <> cube_um
         then do:
            /* UNIT OF MEASURE CONVERSION */
            {gprun.i ""gpumcnv.p""
                     "(input pt_size_um,
                       input cube_um,
                       input pt_part,
                       output cube_conv)"}
            if cube_conv = ? then
               cube_conv = 1.
         end. /* IF PT_SIZE_UM <> CUBE_UM */

         if ds_fr_wt = 0 then
            cum_weight = cum_weight + ds_qty_all * pt_ship_wt * weight_conv.
         else
            cum_weight = cum_weight + ds_qty_all * ds_fr_wt * weight_conv.

         assign
            cum_cube = cum_cube + ds_qty_all * pt_size * cube_conv
            item_count = item_count + 1
            first_line = no.

         if page-size - line-counter < 4
         then do:
            view frame continue.
            page.
            hide frame continue.
            view frame phead1.
            view frame phead2.
            view frame phead3.
         end. /* IF PAGE_SIZE - LINE-COUNT < 3 */

         for each lad_det exclusive-lock
            where lad_dataset = "ds_det"
              and lad_nbr = ds_req_nbr
              and lad_line = ds_site
              and lad_part = ds_part
              and lad_site = ds_shipsite
            break by lad_dataset by lad_nbr by lad_line by lad_part
            with frame d width 80 no-attr-space no-box down:

            /* SET EXTERNAL LABELS */
            setFrameLabels(frame d:handle).

            if page-size - line-counter < 1
            then do:
               view frame continue.
               page.
               hide frame continue.
               view frame phead1.
               view frame phead2.
               view frame phead3.

               display
                  ds_part format "x(27)"
                  cont_lbl @ lad_loc.
               down 1.
            end. /* IF PAGE-SIZE - LINE-COUNT < 1 */

            if first-of (lad_part)
            then do:
               display ds_part format "x(27)".
            end.
            else do:
               if desc1 <> ""
               then do:
                  display "   " + desc1 @ ds_part.
                  desc1 = "".
               end.
               else if desc2 <> ""
               then do:
                     display "   " + desc2 @ ds_part.
                     desc2 = "".
               end.
               else if req-nbr <> ""
               then do:
                  display "   " + getTermLabel("REQUIRED",3) + ": " +
                     req-nbr @ ds_part.
                  req-nbr = "".
               end.

            end. /* ELSE DO */

            shipped = "(       )".

            display
               lad_loc
               lad_lot
               lad_qty_all @ lad_qty_pick
               pt_um
               shipped column-label " Shipped".

            if lad_ref <> ""
            then do with frame d:
               down 1.
               if desc1 <> ""
               then do:
                  display "   " + desc1 @ ds_part.
                  desc1 = "".
               end. /* IF DESC1 <> "" */
               else if desc2 <> ""
               then do:
                  display "   " + desc2 @ ds_part.
                  desc2 = "".
               end.
               else if req-nbr <> ""
               then do:
                  display
                     "   " + getTermLabel("REQUIRED",3) + ": " +
                     req-nbr @ ds_part.

                  req-nbr = "".
               end.

               display getTermLabel("REFERENCE",5) + ": " + lad_ref @ lad_lot.

            end. /* IF LAD_REF <> "" */

            lad_qty_pick = lad_qty_pick + lad_qty_all.
            lad_qty_all = 0.

            if last-of (lad_part)
            then do:
               if desc1 <> ""
               then do:
                  down 1.
                  display "   " + desc1 @ ds_part.
                  desc1 = "".
               end.
               if desc2 <> ""
               then do:
                  down 1.
                  display "   " + desc2 @ ds_part.
                  desc2 = "".
               end.
               if req-nbr <> ""
               then do:
                  down 1.
                  display "   " + getTermLabel("REQUIRED",3) + ": " +
                     req-nbr @ ds_part.
                  req-nbr = "".
               end.

            end. /* IF LAST-OF(LAD_PART) */

            /* PRINT COMMENTS */
            {gpcmtprt.i &type=PA &id=ds_cmtindx &pos=5
               &command="down 1 with frame d".}

            if last (lad_dataset) then down 1.

         end. /* for each lad_det */

         assign
            ds_qty_pick = ds_qty_pick + ds_qty_all
            ds_qty_all = 0.

         if last-of (ds_shipdate)
         then do with frame ptrail:
            hide frame continue.

            /* TRAILER */
            if page-size - line-counter < 4 then
               page.

            do while page-size - line-counter > 5:
               display
                  " "
                  skip(1)
               with frame spaces no-box.
               down 1 with frame spaces.
            end. /* DO WHILE PAGE-SIZE */

            /* SET EXTERNAL LABELS */
            setFrameLabels(frame ptrail:handle).
            display
               fill("-",80)   format "x(80)" skip
               item_count
               space(2)
               string(cum_weight) + " " + weight_um @ cum_weight
               space(6)
               string(cum_cube) + " " + cube_um @ cum_cube
            with frame ptrail width 80 no-attr-space
               no-box side-labels.

            page.
         end. /* IF LAST-OF(DS_SHIPDATE) */

         {mfrpchk.i}

      end. /* FOR EACH DS_DET */
      release ds_det.
   end. /* FOR EACH DSS_MSTR */

END PROCEDURE. /* PROCEDURE P_PICKLIST */
PROCEDURE SO-allmerge:

define input parameter dspart like ds_part.
define input parameter dssite like ds_shipsite.
define input parameter dsdue  like ds_due_date.
define input-output parameter qtytoall like ds_qty_all.
define variable qty_avl like ds_qty_ord.
define variable all_days like soc_all_days.

  find first in_mstr no-lock
             where in_part = dspart and 
                   in_site = dssite no-error.
  if available in_mstr then do:
  
    find first soc_ctrl no-lock. 
    if dsdue <= today + all_days then do:
  
       /* CHECK FOR INVENTORY IN UNRESERVED LOCATIONS */
       {gprun.i ""soqtyavl.p"" "(in_part, in_site, output qty_avl)" }
       
       qtytoall = max(min(qtytoall,qty_avl),0).
    
    end.                                                         
  end.

END PROCEDURE. /* PROCEDURE SO-allmerge */
