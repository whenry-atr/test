/* xxmxtx02.p - Browser for Invoice records to be posted to RegPreGn.dbf */
/* Copyright 1986-2000 QAD Inc., Carpinteria, CA, USA.                  */
/* All rights reserved worldwide.  This is an unpublished work.         */
/* CREATED :                       : 09/24/02   BY: rsh *VQMisTax       */
{mfdtitle.i " b+ " }
/*H0HM {mfdeclre.i}
{gplabel.i &ClearReg=yes} */ /* EXTERNAL LABEL INCLUDE */

/* ********** Begin Translatable Strings Definitions ********* */

{wndvar2.i}  /* scrolling window variables */

DEFINE SHARED VARIABLE log_file as char format "x(50)" no-undo.
DEFINE SHARED VARIABLE log_ident as char format "x(20)" no-undo.
define variable inv_count as int label "Invoice to post" no-undo.
define variable inv_upd_count as int label "Invoices updated" no-undo.
define variable is_update as character format "x" no-undo.
define variable tax_tr_type like tx2d_tr_type no-undo.


{txcalvar.i}

DEFINE shared TEMP-TABLE ttbl_vtx no-undo
     field ttbl_star as char format "x"
     field ttbl_ref like tx2d_ref
     field ttbl_nbr like tx2d_nbr.

form 
  "The following invoices are missing from the Vertex database" skip
  "Use UpDn arrow keys to navigate and Return key to select/deselect" skip
  "Use Ctrl-F to toggle all" skip
  "Press Go / Ctrl-X once you have selected."

  with frame xxmstx02 title "List of Invoices missing from Vertex"
       centered row 3 page-top.
       
view frame xxmstx02.

assign window_row = 10
       window_down = 10.

loop3:
REPEAT:
  output close.
  {windowx.i
        &file       = ttbl_vtx
        &display    = "ttbl_star no-label ttbl_ref ttbl_nbr"
        &index-fld1 = ttbl_ref
        &index-fld2 = ttbl_ref
        &frametitle = ""Select""
        &framephrase = "width 30"
        &return     = no
        &recid-var  = global_recid
        &tag-var    = ttbl_star
        &tag-val1   = ""*""
        &tag-val2   = """"
        &tag-all    = no
        }

   if lastkey = keycode("ctrl-f") then do:
     for each ttbl_vtx :
       ttbl_star = (if ttbl_star = "*" then " "
                    else if ttbl_star = ""  then "*"
                    else ttbl_star).
                   
     end.
     repaint = yes.
     next loop3.
   end.
   if keyfunction(lastkey) = "GO" or lastkey = keycode("RETURN")
   or keyfunction(lastkey) = "end-error"
   then do:
     output to value(log_file) append.
     put unformatted skip log_ident.
     put unformatted "Missing Invoices Selected for Posting " skip(1).
      
     assign inv_count = 0
            is_update = "Q".
     
     for each ttbl_vtx where ttbl_star = "*":
       assign inv_count = inv_count + 1.
       disp ttbl_vtx.
     end.
     page.
     
     message "Log: " log_file " Ident: " log_ident. 
     message "You have selected " + string(inv_count) + " records" skip
             if inv_count > 0 then "Do you want to update Y'es/N'o" else ""
             "/Q'uit?" update is_update.
     if keyfunction(lastkey) = "END-ERROR" then return.
     assign inv_upd_count = 0
            tax_tr_type = "16"
            vq-post = yes
            result-status = 0.

     for each ttbl_vtx where ttbl_star = "*" no-lock:
       disp ttbl_vtx.

       if is_update = "y" then do:


               
         
         
         
         assign inv_upd_count = inv_upd_count + 1.
         /*run us/xx/xxinvcnv.p(ttbl_ref).*/
         {gprun.i ""xxtxcalc.p""
                "(input  tax_tr_type,                                                              input  ttbl_ref, /*invoice number*/
                  input  ttbl_nbr, /*Sales Order Number*/
                  input  0,                                         
                  input  vq-post,                                                            output result-status)"}

          /* XXCALC.P HAS HAD "XXCALC16" ADDED */
       end.
       else ttbl_star = "". 
     end.

     put unformatted "Update option: " is_update " Records:" inv_upd_count skip
         log_ident + " End." skip.
     output close.
     if is_update = "q" or is_update = "y" then return. else next.
   end.
   


end. /*for each pswkfl*/
