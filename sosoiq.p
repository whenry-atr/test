/* sosoiq.p - SALES ORDER INQUIRY                                       */
/* Copyright 1986-2004 QAD Inc., Carpinteria, CA, USA.                  */
/* All rights reserved worldwide.  This is an unpublished work.         */
/* $Revision: 1.13 $                                                     */
/*V8:ConvertMode=Report                                        */
/* REVISION: 1.0      LAST MODIFIED: 08/14/86   BY: PML - 04   */
/* REVISION: 1.0      LAST MODIFIED: 01/17/86   BY: EMB        */
/* REVISION: 4.0      LAST MODIFIED: 12/23/87   BY: pml        */
/* REVISION: 4.0      LAST EDIT: 12/30/87       BY: WUG *A137* */
/* REVISION: 5.0      LAST MODIFIED: 01/30/89   BY: MLB *B024* */
/* REVISION: 5.0      LAST EDIT: 05/03/89       BY: WUG *B098* */
/* REVISION: 6.0      LAST EDIT: 04/05/90       BY: ftb *D002* */
/* REVISION: 6.0      LAST EDIT: 12/27/90       BY: pml *D272* */
/* REVISION: 6.0      LAST MODIFIED: 02/04/91   BY: afs *D328* */
/* Revision: 7.3      Last edit: 11/19/92       By: jcd *G339* */
/* REVISION: 7.3      LAST MODIFIED: 10/17/94   BY: afs *FS51* */
/* REVISION: 7.4      LAST MODIFIED: 11/18/96   BY: *H0PF* Suresh Nayak       */
/* REVISION: 8.6E     LAST MODIFIED: 02/23/98   BY: *L007* A. Rahane          */
/* REVISION: 8.6E     LAST MODIFIED: 02/25/98   BY: *K1JL* Beena Mol          */
/* REVISION: 8.6E     LAST MODIFIED: 10/04/98   BY: *J314* Alfred Tan         */
/* REVISION: 9.1      LAST MODIFIED: 03/24/00   BY: *N08T* Annasaheb Rahane   */
/* REVISION: 9.1      LAST MODIFIED: 08/12/00   BY: *N0KN* myb                */
/* Revision: 1.11     BY: Paul Donnelly (SB)  DATE: 06/28/03  ECO: *Q00L*     */
/* Old ECO marker removed, but no ECO header exists *F0PN*                    */
/* Revision: 1.12     BY: Katie Hilbert          DATE: 11/14/03  ECO: *Q04M*  */
/* $Revision: 1.13 $    BY: Dayanand Jethwa        DATE: 01/28/04  ECO: *P1LM*  */
/*-Revision end---------------------------------------------------------------*/
/******************************************************************************/
/* All patch markers and commented out code have been removed from the source */
/* code below. For all future modifications to this file, any code which is   */
/* no longer required should be deleted and no in-line patch markers should   */
/* be added.  The ECO marker should only be included in the Revision History. */
/******************************************************************************/

/* DISPLAY TITLE */
{mfdtitle.i "1+ "}

define variable cust     like so_cust  no-undo.
define variable nbr      like so_nbr   no-undo.
define variable part     like pt_part  no-undo.
define variable qty_open like sod_qty_ship label "Qty Open" no-undo.
define variable po       like so_po    no-undo.
define variable site     like so_site  no-undo.

part = global_part.

form
   part  colon 15
   /*V8! view-as fill-in size 20 by 1 */
   nbr   colon 48
   cust  colon 68
   po    colon 15
   site  colon 48
with frame a side-labels  width 80 attr-space.

/* SET EXTERNAL LABELS */
setFrameLabels(frame a:handle).

{wbrp01.i}

repeat:

   if c-application-mode <> 'web' then
      update
         part
         nbr
         cust
         po
         site
      with frame a
   editing:

      if frame-field = "part" then do:
         /* FIND NEXT/PREVIOUS RECORD */
         {mfnp.i sod_det part  " sod_det.sod_domain = global_domain and sod_part "
            part sod_part sod_part}

         if recno <> ? then do:
            part = sod_part.
            display part with frame a.
            recno = ?.
         end.
      end.
      else do:
         status input.
         readkey.
         apply lastkey.
      end.
   end.

   {wbrp06.i &command = update &fields = "  part nbr cust po  site"
      &frm = "a"}

   if (c-application-mode <> 'web') or
      (c-application-mode = 'web' and
      (c-web-request begins 'data'))
   then do:

      hide frame b.
      hide frame c.
      hide frame d.
      hide frame e.
      hide frame f.
      hide frame g.

   end.

   /* OUTPUT DESTINATION SELECTION */
   {gpselout.i &printType = "terminal"
               &printWidth = 80
               &pagedFlag = " "
               &stream = " "
               &appendToFile = " "
               &streamedOutputToTerminal = " "
               &withBatchOption = "no"
               &displayStatementType = 1
               &withCancelMessage = "yes"
               &pageBottomMargin = 6
               &withEmail = "yes"
               &withWinprint = "yes"
               &defineVariables = "yes"}

   if part <> "" then
      for each sod_det
         where sod_domain = global_domain
         and  (sod_part = part
         and  (sod_site = site or site = ""))
      no-lock with frame b width 80 no-attr-space:
         /* SET EXTERNAL LABELS */
         setFrameLabels(frame b:handle).
         {mfrpchk.i}
         find so_mstr
            where so_domain = global_domain
             and  so_nbr = sod_nbr
         no-lock.
         if  (so_nbr = nbr or nbr = "" )
         and (so_cust = cust or cust = "" )
         and (so_po = po or po = "")
         then do:
            qty_open = sod_qty_ord - sod_qty_ship.
            display
               so_nbr
               so_cust
               sod_line
               sod_qty_ord
               qty_open
               sod_um
               sod_due_date
               sod_site.
         end.
      end.

   else
   if nbr <> "" then
      loopc:
      for each so_mstr
         where so_domain = global_domain
         and ( so_nbr = nbr
         and  (so_cust = cust or cust = "" )
         and  (so_po = po or po = ""))
      no-lock with frame c width 80 no-attr-space:
         /* SET EXTERNAL LABELS */
         setFrameLabels(frame c:handle).
         {mfrpchk.i}
         for each sod_det
            where sod_det.sod_domain = global_domain
            and ( sod_nbr = so_nbr
            and  (sod_site = site or site = ""))
         no-lock on endkey undo, leave loopc with frame c:
            {mfrpchk.i}
            qty_open = sod_qty_ord - sod_qty_ship.
            display
               so_cust
               sod_line
               sod_part
               sod_qty_ord
               qty_open
               sod_um
               sod_due_date
               sod_site.
            down 1.
         end.
      end.

   else
   if cust <> "" then
      loopd:
      for each so_mstr
         where so_domain = global_domain
         and ((so_cust = cust)
         and  (so_po = po or po = ""))
      no-lock by so_cust by so_nbr
      with frame d width 80 no-attr-space:
         /* SET EXTERNAL LABELS */
         setFrameLabels(frame d:handle).
         {mfrpchk.i}
         for each sod_det
            where sod_domain = global_domain
            and ( sod_nbr = so_nbr
            and  (sod_site = site or site = ""))
         no-lock by sod_nbr by sod_line
         on endkey undo, leave loopd with frame d:
            {mfrpchk.i}
            qty_open = sod_qty_ord - sod_qty_ship.
            display
               so_nbr
               sod_line
               sod_part
               sod_qty_ord
               qty_open
               sod_um
               sod_due_date
               sod_site.
            down 1.
         end.
      end.

   else
   if po <> "" then
      loope:
      for each so_mstr
         where so_domain = global_domain
         and   so_po = po
      no-lock with frame e width 80 no-attr-space:
         /* SET EXTERNAL LABELS */
         setFrameLabels(frame e:handle).
         {mfrpchk.i}
         for each sod_det
            where sod_domain = global_domain
            and ( sod_nbr = so_nbr
            and  (sod_site = site or site = ""))
         no-lock by sod_nbr by sod_line
         on endkey undo, leave loope with frame e:
            {mfrpchk.i}
            qty_open = sod_qty_ord - sod_qty_ship.
            display
               so_nbr
               sod_line
               sod_part
               sod_qty_ord
               qty_open
               sod_um
               sod_due_date
               sod_site.
            down 1.
         end.
      end.

   else
   if site <> "" then
      loopf:
      for each sod_det
         where sod_domain = global_domain
         and   sod_site = site
      no-lock by sod_nbr by sod_line
      on endkey undo, leave loopf with frame f width 80:
         /* SET EXTERNAL LABELS */
         setFrameLabels(frame f:handle).
         {mfrpchk.i}
         find so_mstr
            where so_domain = global_domain
             and  so_nbr = sod_nbr no-lock no-error.
         qty_open = sod_qty_ord - sod_qty_ship.
         display
            so_nbr
            so_cust
            sod_line
            sod_part
            qty_open
            sod_um
            sod_due_date
            sod_site.
   end.

   else
      for each sod_det no-lock
         where sod_domain = global_domain
         and   sod_nbr >= ""
         and   sod_line >= 0
         by sod_part
      with frame g width 80 no-attr-space:
         /* SET EXTERNAL LABELS */
         setFrameLabels(frame g:handle).
         {mfrpchk.i}
         find so_mstr
            where so_domain = global_domain
            and   so_nbr = sod_nbr no-lock no-error.
         qty_open = sod_qty_ord - sod_qty_ship.
         display
            so_nbr
            so_cust
            sod_line
            sod_part
            qty_open
            sod_um
            sod_due_date
            sod_site.
      end.
   {mfreset.i}
   {pxmsg.i &MSGNUM=8 &ERRORLEVEL=1}
end.
global_part = part.

{wbrp04.i &frame-spec = a}
