/* Copyright 1986-2006 QAD Inc., Carpinteria, CA, USA.                       */
/* All rights reserved worldwide.  This is an unpublished work.              */
/*                                                                           */

{mfdtitle.i}

run pxgblmgr.p persistent set global_gblmgr_handle.

define variable lffrom        like si_site              no-undo.
define variable lffrom1       like si_site              no-undo.

define variable lfvalid as logical initial no.

form
   lffrom         colon 18
   lffrom1        label {t001.i} colon 49
   skip(1)
   lfvalid        label "Update Records" colon 49
   skip(1)
with frame a side-labels width 80 attr-space.

/* SET EXTERNAL LABELS */
setFrameLabels(frame a:handle).

repeat:
   
   if lffrom1    = hi_char        then lffrom1   = "".
   
   display
      lffrom
      lffrom1
      lfvalid
   with frame a.

   set
      lffrom
      lffrom1
      lfvalid
   with frame a.

   bcdparm = "".

   {mfquoter.i lffrom   }
   {mfquoter.i lffrom1  }
   {mfquoter.i lfvalid  }

   if lffrom1 = "" then lffrom1 = hi_char.
   

   /* SELECT PRINTER */
   {mfselbpr.i "printer" 132}
   {mfphead.i}

    for each lad_det where 
       lad_domain = global_domain and
       lad_site >= lffrom and lad_site <= lffrom1:
       find ld_det where 
                 ld_domain = lad_domain and 
                 ld_site = lad_site and 
                 ld_loc = lad_loc and 
                 ld_part = lad_part and 
                 ld_lot = lad_lot and 
                 ld_ref = lad_ref no-lock no-error.
       if available ld_det and ld_qty_oh = 0 then do:
       display lad_det with side-labels with frame lfb.
    
       if lfvalid then
       delete lad_det.
       end.
    end.
    
    for each lad_det where 
    lad_domain = global_domain and
    lad_site >= lffrom and lad_site <= lffrom1:
       find ld_det where 
                 ld_domain = lad_domain and 
                 ld_site = lad_site and 
                 ld_loc = lad_loc and 
                 ld_part = lad_part and 
                 ld_lot = lad_lot and 
                 ld_ref = lad_ref no-lock no-error.
       if not available ld_det then do:
       display lad_det with side-labels with frame lfc.
                
       if lfvalid then
       delete lad_det.
       end.
   
   {mfrpexit.i}
   
   end.

   /* REPORT TRAILER */
   {mfrtrail.i}

end.