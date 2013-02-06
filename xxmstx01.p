/* PROGRAM: xxmstx01.p UTILITY to create missing invoices from Vertex */
/* Description: Identifies missing invoices in vertex and if user     */
/*              accepts, those records are created                      */
/*              This does not update tx2d_det                           */
/*              This does not allow deletion to RegPreGn.dbf            */
/*              Does not allow modification to RegPreGn.dbf             */
/*              Expects users to supply RegDump file containing text    */
/*              Output of RegPreGn.dbf and RegPstGn.dbf.                */
/*              Adds records only to RegPreGn.dbf.                      */
/*              No APIs are provided by Quantum for reading Registers   */

/* REVISION:          CREATED: 09/24/02   BY: rsh *VQMisTax             */
/* REVISION:          CREATED: 06/28/10   BY: RSH rshvq01               */
/* Identify if wrong invoices found in the dump file 10/03/02 rsh        */
 

DEFINE VARIABLE vtx_invno as char format "x(10)" Label "RegInv#" no-undo. 
DEFINE VARIABLE vtx_slno as integer Label "SrlNo." no-undo.
DEFINE VARIABLE vtx_trnitmno as int format ">>9" no-undo. /*line#*/
DEFINE VARIABLE vtx_trndate as char no-undo.   /*invdate*/
DEFINE VARIABLE vtx_invdate as char no-undo.   /*taxeffdate*/
DEFINE VARIABLE vtx_trnusarea as char no-undo. /*trailer code*/
DEFINE VARIABLE inv_start as int label "Invoice Start Position" format ">>9" no-undo.
DEFINE VARIABLE inv_length as int label "Length of Invoice Number" format ">9" no-undo.
 
DEFINE VARIABLE invdate like tx2d_effdate initial today  no-undo.
DEFINE VARIABLE invdate1 like tx2d_effdate initial today no-undo.
DEFINE VARIABLE in_debug as logical label "Debug" initial yes no-undo.
{mfdtitle.i " b+ "}
{wndvar2.i}
{txcalvar.i}
{gpapi.i} /* just to get api-status */
DEFINE VARIABLE text_string AS CHARACTER FORMAT "x(820)" no-undo.
DEFINE VARIABLE record_length as integer format ">>>9" no-undo.
DEFINE VAR Dump_file as char format "x(35)" label "RegDump" no-undo.
DEFINE VAR loopi as int no-undo.
DEFINE STREAM S1.
DEFINE NEW SHARED VARIABLE log_file as char format "x(50)" no-undo.
DEFINE NEW SHARED VARIABLE log_ident as char format "x(20)" no-undo.
DEFINE VARIABLE vqapi_ini_file as char format "x(50)" label "vqapi.ini" no-undo.
DEFINE VARIABLE vqmis_ini_file as char format "x(50)" label "vqmis.ini" no-undo.
DEFINE VARIABLE reg_source as char format "x(45)" label "Register Source" 
no-undo.
DEFINE VARIABLE InvNotInMfgPro as int no-undo.
DEFINE VARIABLE InvNotInRange  as int no-undo.
DEFINE VARIABLE first_time as logical initial yes no-undo.
DEFINE VARIABLE msg1 as char no-undo.
DEFINE VARIABLE extime as char no-undo.
 
/* CUSTOMIZED SECTION FOR VERTEX BEGIN */
define variable l_vtx_message   like mfc_logical initial no no-undo.
define variable l_cont          like mfc_logical initial no no-undo.
define variable l_api_handle      as handle                 no-undo.
define variable l_vq_reg_db_open  as logical     initial no no-undo.
define variable result-status-r   as integer                no-undo. 
define stream outstream.
define variable vq_days_overlap   as char                   no-undo.
define variable vq_domain         as char                   no-undo.
define variable vq_duptest        as char                   no-undo.
define variable is_domain         as logical                no-undo.
define variable vq_output         as char                   no-undo. 

  
/* CUSTOMIZED SECTION FOR VERTEX END */

/*batchrun = true.  /* remove this after testing rshvq01*/*/
Assign extime = string(time)
       log_file = "VQMis" + extime + ".log".
               
output stream outstream to value(log_file) append.
        

/* get vqapi.ini file name and store full path to vqapi_file*/

assign vqapi_ini_file = search("vqapi.ini")
       vqmis_ini_file = search("vqmis.ini").

{xxvqdomain.i new}
/* get log file name from ini file works on Unix */
{gprun.i ""gpgetini.p"" "(vqapi_ini_file,
                         ""vqapi"",
                         ""quantum_logfile"",                                                          output log_file)"}                                                        
{gprun.i ""gpgetini.p"" "(vqmis_ini_file,
                         ""vqmis"",
                         ""vq_output"",
                         output vq_output)"} 
                       
{gprun.i ""gpgetini.p"" "(vqmis_ini_file,
                         ""vqmis"",
                         ""vq_days_overlap"",
                         output vq_days_overlap)"}
/* This is replaced by xxdomain.i */
/* Is this a domain database */
/*
assign is_domain = can-find(_file where _file-name = "dom_mstr").

{gprun.i ""gpgetini.p"" "(vqmis_ini_file,
                          ""vqmis"",
                          ""vq_domain"",
                          output vq_domain)"}
  */                        
{gprun.i ""gpgetini.p"" "(vqmis_ini_file,
                         ""vqmis"",                                                                      ""vq_duptest"",
                          output vq_duptest)"}
                          
 assign vq_output = "vqmis" + string(extime) + ".out".
 put stream outstream  "duptest " vq_duptest skip
        "output " vq_output skip
        "domain " vq_domain skip
        "days_overlap " vq_days_overlap skip .
        
        

if log_file = ? then do:
   {mfmsg.i 1950 4 }                           
   if not batchrun and c-application-mode <> 'WEB'  then pause.                     return.
end.
/*batchrun = true.*/
if batchrun then do:
  if vq_days_overlap = ? then do:
    put stream outstream " vq_days_overlap definition missing in vqmis.ini"         skip "     Assuming 365 days"  skip(1).
    vq_days_overlap = "365".
  end.
  if vq_output = ? then do:
    assign vq_output = "vqmis" + string(extime) + ".out".    
    put stream outstream " vq_output output destination definition missing in vqmis.ini"
        skip "     Assuming  " vq_output 
        skip(1).
      
  end.
  if vq_domain = ? then do:
    if can-find(_file where _file-name = "dom_mstr") then do:
      put stream outstream " vq_domain definition missing in vqmis.ini."
             skip " Program aborted."  skip.
      quit.
    end.    
  end.
end.

input close.

ASSIGN inv_start = 115
       inv_length = 10
       invdate = today - int(vq_days_overlap) /* rshvq001 */
       
       dump_file = (if opsys = "Unix" then ".\/" else ".\\") + "RegDump"  +
                string(month(today),"99") + string(day(today),"99")
       log_ident = "VQMisTax-" + extime + " ".
       
       log_file = "VQMisTax" + extime + ".log".

/*output stream outstream to value(log_file) append.*/


DO with side-label title "VQMisTax" centered row 5:
  if not batchrun then do:
    
    DISP skip(1) dump_file log_file.
    if not batchrun then do:
  
      UPDATE Dump_file 
         validate(search(Dump_file) <> ?, "Invalid filename" )
           help "File where RegPreGn & RegPstGn are extracted into. "
           skip(1)
         inv_start colon 25 validate(inv_start > 100, "should be greater")
           help "Start location of Invoice# in RegDump file."
         inv_length help "Maximum length of the Invoice number field. "
           colon 45 label "length" skip
         invdate help "Start Date for Invoices. " colon 25 
       invdate1 help "End Date. "colon 45 label "To" skip(1)
       in_debug.
      file-info:file-name = Dump_file.
      if in_debug then disp file-info:file-type.
    end.
  end.
    
  if index(file-info:file-type,"w") = 0 
  or index(file-info:file-type,"w") = 0 then    
  do:
    if not batchrun then message Dump_file " Cannot be written to " view-as alert-box error.
    else put stream outstream unformatted "File " dump_file " Cannot be written" skip(1).
  end.
END.       
DEFINE new shared TEMP-TABLE ttbl_vtx no-undo
  field ttbl_star as char format "x" label "Status"
  field ttbl_ref like tx2d_ref Label "Vtx-Ref"
  field ttbl_nbr like tx2d_nbr Label "Mfg-Nbr".

/* Perform dup-invoice test */
/*  table ttbl_vtx is used temporarily to store vertex records and then it will be dropped before accumulating the ih_hist tax records */
DEFINE new shared TEMP-TABLE ttbl2_vtx no-undo
  field ttbl2_slno as int Label "erial"
  field ttbl2_ref like tx2d_ref Label "Vtx-Ref"
  field ttbl2_cnt as int Label "vqCount".
/* rshvq01 */
 
assign msg1 = "Loading MFG/PRO Invoices for the period " + string(invdate) 
              + " to " + string(invdate1).
  
IF not batchrun then do:
  message msg1.
  pause 1.
end.
else put stream outstream unformatted msg1 skip(1).

/* rshvq01 end */


/*for each ih_hist where {&AR_DOMAIN} and ih_inv_date >= invdate
                   and ih_inv_date <= invdate1 no-lock,*/
for each ih_hist where {&IH_DOMAIN} and ih_inv_date >= invdate
                   and ih_inv_date <= invdate1 no-lock,
                   
  each tx2d_det where {&TX2D_DOMAIN} and  tx2d_ref = ih_inv_nbr
                    and tx2d_tr_type = "16"
        /*            and tx2d_tax_amt ne 0      */
                    and can-do("vq-00,vq-10,vq-20,vq-30,vq-40",tx2d_tax_type)
                    group by tx2d_ref with frame tx2d title "Invoices":
  if not first-of(tx2d_ref) then next.
  if can-find(ttbl_vtx where ttbl_ref = tx2d_ref) then next.
  create ttbl_vtx.
  assign ttbl_ref = tx2d_ref
         ttbl_nbr = tx2d_nbr.

end.

/* rshvq01 */
msg1 = "Please wait while " + dump_file + " is parsed for Invoices.".
if not batchrun then do:
  message msg1.
  pause 1.
end.
else put stream outstream unformatted msg1 skip(1).

INPUT FROM VALUE(Dump_file).

/*IMPORT UNFORMATTED text_string.  /* skip the header */*/
/*DO WHILE TRUE with frame imp title "import" on error undo, leave:*/   

                 
put stream outstream unformatted skip log_ident " Begin." skip
                "Invoices are read from the " + Dump_file + " file." skip
                "Check for date range " invdate " " invdate1 skip
                "(Status F=OK; E=External; Blank=Missing in Vertex)" skip. 
                
REPEAT ON ERROR UNDO, LEAVE:
  IMPORT UNFORMATTED text_string.   
  ASSIGN vtx_invno = trim(substring(text_string,inv_start,inv_length))
         vtx_slno = int(trim(substring(text_string,4,7))).
  
  if substring(text_string,1) = "p" then next.
  /* rshvq01 */
  
  if first_time and substring(text_string,1,5) = "99999" then do:
    first_time = no.
            
    msg1 = Dump_file + " File already used for creating Vertex records." 
         + chr(10) + "Please use regutil to unload records again and restart." 
         + chr(10) + "You can view the log file VQ" + substring(text_string,6,5) + ".log" + " for details." + chr(10). 
              
    if not batchrun then do:
      message msg1
             VIEW-AS alert-box.
    end.
    else do:
      /* need to add logic to message to output to warn that the dump is already updated need a new dump file */
      put unformatted msg1 skip  .
      /* rsh */
    end.
  end.
  /* accumulate duptest records */
  find first ttbl2_vtx where ttbl2_ref = vtx_invno no-error.

  if not avail ttbl2_vtx then do:
    create ttbl2_vtx.
    assign ttbl2_ref = vtx_invno
         ttbl2_slno = vtx_slno
         ttbl2_cnt = ttbl2_cnt + 1.
         
  end.
  else do:
    if ttbl2_slno <> vtx_slno then assign ttbl2_cnt = ttbl2_cnt + 1.
  end.  
  /* end duptest count */

  if record_length = 0 then record_length = length(text_string).
  find first ttbl_vtx where ttbl_ref = vtx_invno no-error.
  if available ttbl_vtx then do:
    /* Set it to Found and check next */
    assign ttbl_star = "F".
    /*message "found 240 " ttbl_ref. pause.*/
    next.
  end.
  
    
  find first tx2d_det where tx2d_ref = vtx_invno no-lock no-error.
  
  if available tx2d_det and tx2d_tr_type <>  "16" then next.
  if not avail tx2d_det 
  then do:
    create ttbl_vtx.
    assign ttbl_ref = vtx_invno
             ttbl_nbr = "No-tx2d"
             ttbl_star = "E"
             InvNotInMfgPro = InvNotInMfgPro + 1.
  end.
  else do:
    /* Do not worry about vertex out-of-date records */
    if ih_inv_date < invdate or ih_inv_date > invdate1 then next.
  end.
  if in_debug and not batchrun then /*rshvq01*/
  disp ttbl_star label "Status"  when avail ttbl_vtx
       vtx_invno  
       ttbl_nbr  when avail ttbl_vtx 
       ttbl_ref  when avail ttbl_vtx.
END.

put unformatted "status D=Dup; F=Found; E=External; Blank=Missing in Vertex" skip
    "End of Invoices read from the " + Dump_file + " file." skip.
 
input close.

put stream outstream unformatted skip(2) "Duplicate Invoices in Vertex Registers" skip(1).
for each ttbl2_vtx where ttbl2_cnt > 1:
  put stream outstream unformatted ttbl2_slno " " ttbl2_ref  skip.
end.
put stream outstream unformatted " End of Duplicate Invoices report. " skip(3)
  
    "Invoices missing in Vertex Registers" skip(1)
    "    InvNum OrderNum" skip
    "    ------ --------" skip.

for each ttbl_vtx:

  if ttbl_star = ""
  then do: 
    if in_debug and not batchrun then disp ttbl_vtx.
     if batchrun then put stream outstream ttbl_star " " ttbl_nbr " " 
                          ttbl_ref skip.
    next.
  end.
  else delete ttbl_vtx.
end.

put stream outstream unformatted "    ------ --------" skip
    " from the " + Dump_file + " file." skip(1).

output stream outstream close.
INPUT CLOSE.
clear all.

if batchrun then leave. /* rsh  rshvq01 */

if InvNotInMfgPro > 0 then do:
  message "There are " InvNotInMfgPro " invoices in " dump_file skip
          "  for which there are no equivalent mfg/pro records " 
           " Please verify the log "
          Skip " Press F4 to abort."  view-as alert-box warning.
end.  

/*kzd*/  /*  INSERT LOGIC TO OPEN REGISTER DB   */

/* CUSTOMIZED SECTION FOR VERTEX BEGIN */
/* RUN vqregopn.p TO SEE IF VERTEX SUTI API IS RUNNING, */
/* AND THEN OPEN REGISTER DB                            */

/* TRY AND FIND VERTEX TAX API'S PROCEDURE HANDLE. */
{gpfindph.i vqapi l_api_handle}
/* IF THERE IS NO PROCEDURE HANDLE WE ARE DONE. */
if l_api_handle <> ?
then do:

   {gprun.i ""vqregopn.p"" "(output result-status-r)"}
      if result-status-r = 0
         then
     l_vq_reg_db_open = yes.
   if  result-status-r <> 0
      and not batchrun
         then do:
         
/* INVOICES WILL POST TO MFG/PRO BUT NOT UPDATE THE VERTEX REGISTER */
      {pxmsg.i &MSGNUM=8880 &ERRORLEVEL=1}
      
            /* CONTINUE WITH INVOICE POST? */
                  {pxmsg.i &MSGNUM=8881 &ERRORLEVEL=1 &CONFIRM=l_cont}
                        if  l_cont = no
                              then
               undo, return no-apply.


     end. /* IF  result-status-r<> 0... */
                                          
                if result-status-r <> 0
                   then
                  l_vtx_message = yes.
end. /* IF l_api_handle */
/*kzd*/    /* CUSTOMIZED SECTION FOR VERTEX END  */

/*kzd*/      /* CUSTOMIZED SECTION FOR VERTEX BEGIN */
            if l_vtx_message
                  then do:
                  
             /* DISPLAY A MESSAGE IN THE AUDIT TRAIL */
                           
  /* API FUNCTION FAILURE. VERTEX REGISTER DB DID NOT UPDATE. */
         {pxmsg.i &MSGNUM=8882 &ERRORLEVEL=1}
         
                  /* VERIFY THE DATA IN THE VERTEX REGISTER. */
                    {pxmsg.i &MSGNUM=8883 &ERRORLEVEL=1}
                           
            end. /* IF l_vtx_message */
            /*  CUSTOMIZED SECTION FOR VERTEX ENDS */
/*kzd */    /* CUSTOMIZED SECTION FOR VERTEX ENDS  */


run us/xx/xxmstx02.p.


 /*kzd*/    /*  CUSTOMIZED SECTION FOR VERTEX BEGINS  */
     /*  CUSTOMIZED SECTION FOR VERTEX BEGIN  */
     /*  CHECK IF VERTEX REGISTER DBF WAS OPENED  */
     if l_vq_reg_db_open
     then do:
        {gprun.i ""vqregcls.p""}
    end.    /* IF l_vq_reg_db_open */
    /*   CUSTOMIZED SECTION FOR VERTEX END  */
/*kzd*/   /*  CUSTOMIZED SECTION FOR VERTEX END  */   




output close.
output to value(dump_file) append.

assign text_string = fill(" ",record_length)
       substring(text_string,1,10) = "99999" + substring(log_file,3,5).

/* If the records are moved to Vertex, then update them in Dump file so
   that it does not become eligible for the next run using the same input*/
for each ttbl_vtx where ttbl_star = "*" no-lock:
  substring(text_string,inv_start) = 
           substring(ttbl_ref + fill(" ",12),1,inv_length).
  put unformatted text_string skip.
end.

output close.
input close.

repeat:
  update log_file with frame v title "View log file" .
  if keyfunction(lastkey) = "end-error" then return.
  if opsys = "unix" then unix pg value(log_file).
  else
  if opsys = "msdos" or opsys = "win32" 
  then dos type value(log_file)|more.
  else if opsys = "vms" then vms type/page value(log_file).
end.
/* END Program xxmstx01.p */
