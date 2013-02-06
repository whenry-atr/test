/* dspkall.p - INTERSITE DEMAND HARD ALLOCATIONS                        */
/* Copyright 1986-2007 QAD Inc., Carpinteria, CA, USA.                  */
/* All rights reserved worldwide.  This is an unpublished work.         */


/* REVISION: 7.0      LAST MODIFIED: 05/14/92   BY: emb *F611*/
/* REVISION: 7.0      LAST MODIFIED: 09/02/92   BY: emb *F868*/
/* REVISION: 8.6      LAST MODIFIED: 05/20/98   BY: *K1Q4* Alfred Tan   */
/* REVISION: 9.1      LAST MODIFIED: 08/14/00   BY: *N0KW* Jacolyn Neder */
/* Old ECO marker removed, but no ECO header exists *F0PN*               */
/* Revision: 1.5.1.4  BY: Russ Witt DATE: 06/01/01 ECO: *P00J* */
/* Revision: 1.5.1.6  BY: Paul Donnelly (SB) DATE: 06/26/03   ECO: *Q00B* */
/* $Revision: 1.5.1.6.1.1 $  BY: Ruma Bibra         DATE: 04/11/07   ECO: *P5NG* */
/*-Revision end---------------------------------------------------------------*/


/*V8:ConvertMode=Maintenance                                            */

/******************************************************************************/
/* All patch markers and commented out code have been removed from the source */
/* code below. For all future modifications to this file, any code which is   */
/* no longer required should be deleted and no in-line patch markers should   */
/* be added.  The ECO marker should only be included in the Revision History. */
/******************************************************************************/

{mfdeclre.i}

define input parameter p_update_yn like mfc_logical no-undo.

define shared variable ds_recno as recid.
define shared variable qty_to_all like ds_qty_all.

define variable all_this_loc like ds_qty_all.
define buffer lddet for ld_det.
define variable this_lot like ld_lot.
define variable totallqty like lad_qty_all.
define variable totpkqty like lad_qty_pick.

find first icc_ctrl  where icc_ctrl.icc_domain = global_domain no-lock.
find ds_det
   where recid(ds_det) = ds_recno
no-lock no-error.

this_lot = ?.

if qty_to_all > 0 then do:

   find pt_mstr  where pt_mstr.pt_domain = global_domain and  pt_part = ds_part
   no-lock no-error.
   if pt_sngl_lot then do:
      find first lad_det no-lock  where lad_det.lad_domain = global_domain and
      (  lad_dataset = "ds_det"
      and lad_nbr = ds_req_nbr
      and lad_line = ds_site and lad_part = ds_part
      and (lad_qty_all > 0 or lad_qty_pick > 0) ) no-error.
      if available lad_det then this_lot = lad_lot.
   end.

   if icc_ascend then do:
      if icc_pk_ord <= 2 then do:
     {dspkall.i &sort1 = "(if icc_pk_ord = 1 then ld_loc else ld_lot)" }
      end.
      else do:
     {dspkall.i &sort1 = "(if icc_pk_ord = 3 then ld_date else ld_expire)" }
      end.
   end.
else do:
   if icc_pk_ord <= 2 then do:
      {dspkall.i &sort1 = "(if icc_pk_ord = 1 then ld_loc else ld_lot)"
         &sort2 = "descending"}
   end.
   else do:
      {dspkall.i &sort1 = "(if icc_pk_ord = 3 then ld_date else ld_expire)"
         &sort2 = "descending"}
   end.
end.

totallqty = 0.
totpkqty = 0.
for each lad_det
      no-lock
       where lad_det.lad_domain = global_domain and  lad_dataset = "ds_det"
      and lad_nbr = ds_req_nbr
      and lad_line = ds_site
      and lad_part = ds_part
      and lad_site = ds_shipsite:
   totallqty = totallqty + lad_qty_all.
   totpkqty = totpkqty + lad_qty_pick.
end.

find in_mstr exclusive-lock  where in_mstr.in_domain = global_domain and
in_part = ds_part
   and in_site = ds_shipsite no-error.

if available in_mstr then
assign in_qty_all = in_qty_all - ds_qty_all - ds_qty_pick
   + totallqty + totpkqty.

   if p_update_yn = yes
   then do:
      find ds_det
         where recid(ds_det) = ds_recno
      exclusive-lock no-error.
      if available ds_det
      then
         assign
            ds_qty_all  = totallqty
            ds_qty_pick = totpkqty.
   end. /* IF update_yn = YES */
end.
