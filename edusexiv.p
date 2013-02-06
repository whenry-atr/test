/* edusexiv.i   LEGACY CUSTOM EDI INVOICE EXPORT PROGRAM                */
/* Created By:  Luis GomezDelCampo - 2008/05/29                         */
/* Purpose:     Required by legacy code for EDI Invoice Export          */
/*              Adapted from legacy version                             */
/* Task104      Custom EDI Invoice Export                               */
/*              Based on code available                                 */
/************************************************************************/
/* edusexiv.p - EDI                                                          */
/* Copyright 1986-2000 QAD Inc., Carpinteria, CA, USA.                       */
/* All rights reserved worldwide.  This is an unpublished work.              */
/*V8:ConvertMode=Maintenance                                                 */
/*V8:RunMode=Character,Windows                                               */
/* REVISION: 9.1      LAST MODIFIED: 08/14/00 BY: *N0KW* Jacolyn Neder       */

         /* USER INTERFACE PROGRAM FOR INVOICE EXPORT */

{mfdeclre.i}
{gplabel.i} /* EXTERNAL LABEL INCLUDE */

 define input parameter ih_recid          as recid.
 define input parameter first_record      as logical.
 define input parameter first_cust_record as logical.

 define new shared variable ih_recno    as   recid.
 define new shared variable base_rpt    as   character.
 define new shared variable tot_trl1    like ih_trl1_amt.
 define new shared variable tot_trl2    like ih_trl2_amt.
 define new shared variable tot_trl3    like ih_trl3_amt.
 define new shared variable tot_disc    like ih_trl1_amt.
 define new shared variable rpt_tot_tax like ih_trl1_amt.
 define new shared variable tot_ord_amt like ih_trl1_amt.
 define new shared variable rndmthd     like rnd_rnd_mthd.

 define variable linedata        as   character no-undo.
 define variable ptdesc          like pt_desc1  no-undo.
 define variable ext_price       like idh_price no-undo
                                 format "->>>>,>>>,>>9.99".
 define variable tmpamt          as   decimal   no-undo.
 define variable using_seq_schedules like mfc_logical initial no no-undo.


 define buffer ad_cust for ad_mstr.
 define buffer ad_ship for ad_mstr.
 define buffer ad_bill for ad_mstr.

function str_date returns char (input p_date as date):
    return ( string(year(p_date), '9999')
         + string(month(p_date), '99')
         + string(day(p_date), '99')).
end function.


define buffer ad_remit for ad_mstr.
define buffer ad_from for ad_mstr.
define buffer ad_vend for ad_mstr.

define var v_units  like idh_qty_ord no-undo.
define var v_weight like pt_net_wt   no-undo.
define var v_volume like pt_size     no-undo.
define var v_vol_um as   char        no-undo.
define var v_wt_um  as   char        no-undo.
define var v_conv   like idh_um_conv no-undo.
define var v_ctns   like idh_qty_ord no-undo.

{edexport.i}
{eddefcon.i}
{soivtot1.i "new"}
{soivtot2.i}
{mfivtrla.i "new"}
{etdcrvar.i new}
{etvar.i &new = new}
{etrpvar.i &new = new}

DEF VAR v-seq AS INT FORMAT ">>>9" extent 4 no-undo.     /*more than one tx2d_*/
DEF VAR v-ovly AS CHAR extent 4 no-undo.                 /*Overlay*/
DEF VAR v-code AS CHAR FORMAT "x(4)" extent 4 no-undo.   /*"TAX "*/
DEF VAR v-desc AS CHAR FORMAT "x(4)" extent 4 no-undo.   /*GST, PST, ETC...*/ 
DEF VAR v-pct AS DECIMAL format "-99999.99999" extent 4 no-undo.  /*Calc %*/
DEF VAR v-tax like invtot_trl1_amt label "TaxAmt" extent 4 no-undo.      
DEF VAR v-chrg like invtot_trl1_amt label "Charge" extent 4 no-undo.
DEF VAR v-amt1 AS DECIMAL extent 4 no-undo.              /*base tax amt*/
DEF VAR v-amt2 AS DECIMAL extent 4 no-undo.              /*base taxable amt*/

/* VARIABLE DEFINITIONS FOR gpfile.i */
{gpfilev.i}


 /* ASSIGN ORIGINAL FORMAT TO _OLD VARIABLES */
 assign
    nontax_old   = nontaxable_amt:format
    nontax_old   = nontaxable_amt:format
    taxable_old  = taxable_amt:format
    line_tot_old = line_total:format
    disc_old     = disc_amt:format
    trl_amt_old  = ih_trl1_amt:format
    tax_amt_old  = tax_amt:format
    ord_amt_old  = ord_amt:format.


 find ih_hist 
   where recid(ih_hist) = ih_recid no-lock.
 find cm_mstr 
   where cm_domain = global_domain 
     and cm_addr = ih_cust no-lock.
 find ad_cust 
   where ad_cust.ad_domain = global_domain 
     and ad_cust.ad_addr = ih_cust no-lock.
 find ad_ship 
   where ad_ship.ad_domain = global_domain 
     and ad_ship.ad_addr = ih_ship no-lock.
 find ad_bill 
   where ad_bill.ad_domain = global_domain 
     and ad_bill.ad_addr = ih_bill no-lock.
 find first ad_remit 
   where ad_remit.ad_domain = global_domain
     AND ad_remit.ad_addr = ih_site no-lock.
 find first ad_vend
   where ad_vend.ad_domain = global_domain
     AND ad_vend.ad_addr = "~~invoice" no-lock.

FIND FIRST ih_hist_a WHERE ih_inv_nbr = invoice_no AND 
                           ih_nbr = sls_ord NO-LOCK NO-ERROR. 

find first idh_hist 
WHERE idh_domain = global_domain
  AND idh_hist.idh_inv_nbr = ih_hist.ih_inv_nbr 
  AND idh_hist.idh_nbr = ih_hist.ih_nbr
no-lock no-error.
if available(idh_hist) then
find first ad_from 
  where ad_from.ad_domain = global_domain
    AND ad_from.ad_addr = idh_hist.idh_site
  no-lock no-error.
else
find first ad_from 
  where ad_from.ad_domain = global_domain
    AND ad_from.ad_addr = "02"
  no-lock no-error.

if ad_cust.ad_edi_tpid = "" then
do:
    put unformatted skip
       "ERROR: No Trading Partner Id Exists for INV:" + ih_inv_nbr + 
       " IH-CUST:" + ih_cust 
       skip.
    return_code = 3.
    return.
end.
  
if ad_ship.ad_edi_id = "" then
do:
    put unformatted skip
       "ERROR: No EDI Ship To Id Exists for INV:" + ih_inv_nbr + 
        " IH-CUST:" + ih_cust + 
        " IH-SHIP:" + ih_ship 
        skip.
    return_code = 3.
return.
end.

if ad_cust.ad_edi_tpid <> ad_ship.ad_edi_tpid then
do:
    put unformatted skip
       "ERROR: Trading Partner Id MisMatch for INV:" + ih_inv_nbr + 
       " IH-CUST:" + ih_cust + 
       " SHIP:" + ad_ship.ad_addr 
       skip.
    return_code = 3.
    return.
end.
  

  
/* GET ROUNDING METHOD FROM CURRENCY MASTER */
{gprunp.i "mcpl" "p" "mc-get-rnd-mthd"
        "(input ih_curr,
          output rndmthd,
          output mc-error-number)" }
if mc-error-number <> 0 then do:
{pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=3}
next.
end.  /* mc-error-number <> 0 */

{soivtot2.i}

/*       DETERMINE CURRENCY DISPLAY AMERICAN OR EUROPEAN                  */
find rnd_mstr 
where rnd_domain = global_domain 
  and rnd_rnd_mthd = rndmthd no-lock no-error.
if not available(rnd_mstr) then do:
{pxmsg.i &MSGNUM=863 &ERRORLEVEL=3}    /* ROUND METHOD RECORD NOT FOUND */
next.
end.

if (rnd_dec_pt = ",")
then SESSION:numeric-format = "European".
else SESSION:numeric-format = "American".

{socurfmt.i} /* SET CURRENCY DEPENDENT FORMATS */

ih_recno = ih_recid.
{gprun.i ""soihtrl3.p""}
{soivtot5.i}


/* RECORD TYPE R10 */
{edputch.i  1    3 'R10'}
{edputch.i  4   20 ad_cust.ad_edi_tpid}
{edputch.i  24   1 'X'}
{edputch.i  25   6 "fill('0', 6 - length(ad_cust.ad_edi_std))
             + ad_cust.ad_edi_std"}
{edputch.i  31   6 "entry(INVOICE_TYPE, ansi_document_types)"}
{edputch.i  37   1 'P'}
{edputch.i  38  30 ih_inv_nbr }
{edputch.i  68   2 '00'}
{edputch.i  70   8 "str_date(today)"}
{edputch.i  78   8 "string(time, 'HH:MM:SS')"}
{edputln.i}

/* RECORD TYPE R20 */
{edputch.i     1   3 'R20'}
{edputch.i     4  20 ad_cust.ad_edi_tpid}
{edputch.i    24  30 ih_hist.ih_inv_nbr}
{edputch.i    54  10 "str_date(ih_hist.ih_inv_date)"}
{edputch.i    64  30 ih_hist.ih_po}
{edputch.i    94   8 "str_date(ih_hist.ih_ord_date)"}
{edputnum.i  102  30 ih_hist.ih_rev}
{edputch.i   132   3 ih_hist.ih_curr}
{edputch.i   135  30 "' '"}
{edputch.i   165  30 ad_cust.ad_edi_id}
{edputch.i   195  30 ih_hist.ih_nbr}
{edputch.i   225  30 "''"}
{edputch.i   255  30 "''"}
{edputch.i   285  30 "''"}   /* contact */
{edputch.i   315  30 "''"}   /* phone */
{edputch.i   335  24 ad_bill.ad_edi_id}
{edputch.i   359  35 ad_bill.ad_name}

if ad_bill.ad_line1 = "" then
do:
    {edputch.i  394  35 ad_bill.ad_line2}
    {edputch.i  429  35 ad_bill.ad_line3}
end.
else do:
    {edputch.i  394  35 ad_bill.ad_line1}
    {edputch.i  429  35 ad_bill.ad_line2}
end.
{edputch.i    464  35 ad_bill.ad_city}
{edputch.i    499   3 ad_bill.ad_state}
{edputch.i    502  10 ad_bill.ad_zip}
{edputch.i    512   5 ad_bill.ad_ctry}

{edputch.i  517  24 ad_ship.ad_edi_id}
{edputch.i  541  35 ad_ship.ad_name}
if ad_ship.ad_line1 = "" THEN do:
  {edputch.i 576  35 ad_ship.ad_line2}
  {edputch.i 611  35 ad_ship.ad_line3}
end.
else do:
  {edputch.i 576  35 ad_ship.ad_line1}
  {edputch.i 611  35 ad_ship.ad_line2}
end.
{edputch.i 646  35 ad_ship.ad_city}
{edputch.i 681   3 ad_ship.ad_state}
{edputch.i 684  10 ad_ship.ad_zip}
{edputch.i 694   5 ad_ship.ad_ctry}
{edputch.i 699  24 ad_vend.ad_edi_id}
{edputch.i 723  35 ad_from.ad_name}

if ad_from.ad_line1 = "" THEN do:
    {edputch.i 758  35 ad_from.ad_line2}
    {edputch.i 793  35 ad_from.ad_line3}
end.
else do:
    {edputch.i 758  35 ad_from.ad_line1}
    {edputch.i 793  35 ad_from.ad_line2}
end.
{edputch.i 828  35 ad_from.ad_city}
{edputch.i 863   3 ad_from.ad_state}
{edputch.i 866  10 ad_from.ad_zip}
{edputch.i    876   5 ad_bill.ad_ctry}

{edputch.i 1063  24 ad_remit.ad_edi_id}  /* corporate info */
{edputch.i 1087  35 ad_remit.ad_name}
if ad_remit.ad_line1 = "" THEN do:
    {edputch.i 1122  35 ad_remit.ad_line2}
    {edputch.i 1157  35 ad_remit.ad_line3}
end.
else do:
    {edputch.i 1122  35 ad_remit.ad_line1}
    {edputch.i 1157  35 ad_remit.ad_line2}
end.
{edputch.i 1192  35 ad_remit.ad_city}
{edputch.i 1227   3 ad_remit.ad_state}
{edputch.i 1230  10 ad_remit.ad_zip}
{edputch.i    1240   5 ad_remit.ad_ctry}

find first ct_mstr 
where ct_mstr.ct_domain = global_domain 
  and ct_mstr.ct_code = ih_hist.ih_cr_terms 
no-lock.
if available(ct_mstr) THEN do:
    {edputch.i  1245   4 ct_mstr.ct_code}
    {edputnum.i 1249   6 ct_mstr.ct_disc_pct}
    {edputch.i  1255   8 "str_date(ih_hist.ih_inv_date
                                  + ct_mstr.ct_disc_days)"}
    {edputnum.i 1263   3 ct_mstr.ct_disc_days}
    {edputch.i  1266   8 "str_date(ih_hist.ih_inv_date
                                  + ct_mstr.ct_due_days)"}
    {edputnum.i 1274   3 ct_mstr.ct_due_days}
    {edputnum.i 1277  10 0}     
    {edputch.i  1287  80 ct_mstr.ct_desc}
end.

{edputch.i 1367   8 "str_date(ih_hist.ih_inv_date)"}  /* ship date */
{edputch.i 1375   8 "str_date(ih_hist.ih_req_date)"}  /* req  date */
{edputch.i 1383   2 '" "'}      
{edputch.i 1385   2 '" "'}      
{edputch.i 1387  30 ih_hist.ih_fr_terms}

find first carr_mstr 
where carr_id = ih_shipvia no-lock no-error.
if available(carr_mstr) THEN do:
    {edputch.i 1417  4  carr_scac_code}     /* scac code */
end.
find first code_mstr 
where code_fldname = "so_shipvia"
  and code_value = ih_hist.ih_shipvia
no-lock no-error.
if available(code_mstr) THEN do:
    {edputch.i 1421  35 code_mstr.code_cmmt}  /* carrier name */
end.

{edputch.i 1456   2 '" "'}      
{edputch.i 1458  15 ih_hist.ih_nbr}  /* bol number */
{edputch.i 1473  15 ih_hist.ih_bol}  /* pro number */

/* GET ROUNDING METHOD FROM CURRENCY MASTER */
{gprunp.i "mcpl" "p" "mc-get-rnd-mthd"
        "(input ih_curr,
          output rndmthd,
          output mc-error-number)" }
if mc-error-number <> 0 then do:
{pxmsg.i &MSGNUM=mc-error-number &ERRORLEVEL=3}
next.
end.  /* mc-error-number <> 0 */

{soivtot2.i}

/*       DETERMINE CURRENCY DISPLAY AMERICAN OR EUROPEAN                  */
find rnd_mstr 
where rnd_domain = global_domain 
  and rnd_rnd_mthd = rndmthd no-lock no-error.
if not available(rnd_mstr) then do:
{pxmsg.i &MSGNUM=863 &ERRORLEVEL=3}    /* ROUND METHOD RECORD NOT FOUND */
next.
end.
/* IF RND_DEC_PT = COMMA FOR DECIMAL POINT */
/* THIS IS THE EUROPEAN CURRENCY FORMAT */
if (rnd_dec_pt = ",")
then SESSION:numeric-format = "European".
else SESSION:numeric-format = "American".

{socurfmt.i} /* SET CURRENCY DEPENDENT FORMATS */

ih_recno = ih_recid.
{gprun.i ""soihtrl3.p""}

{soivtot5.i}

{edputnum.i  1488  15 invtot_ord_amt}      /* total amount */
{edputnum.i  1503  15 invtot_line_total}   /* amount calc discount*/
{edputnum.i  1518  15 "invtot_line_total - invtot_disc_amt"} /*less disc*/
{edputnum.i  1533  15 invtot_disc_amt}     /* discount amount */


assign v_units  = 0
v_ctns   = 0
v_weight = 0.0
v_volume = 0.0
v_vol_um = ""
v_wt_um  = "".
 
for each idh_hist no-lock 
where idh_domain = global_domain
  AND idh_inv_nbr = ih_inv_nbr
  and idh_nbr = ih_nbr:     

    find pt_mstr 
       where pt_domain = global_domain
         AND pt_part = idh_part no-lock no-error.
    if available(pt_mstr) then
    do:
      v_vol_um = upper(pt_size_um).
      v_wt_um  = upper(pt_ship_wt_um).
      v_units = v_units + (idh_qty_inv * idh_um_conv).
      v_weight = v_weight + (pt_ship_wt * (idh_qty_inv * idh_um_conv)).
      v_volume = v_volume + (pt_size * (idh_qty_inv * idh_um_conv)).
    end.
    
    v_conv = 1.
    find first um_mstr 
      where um_part = pt_part 
        and um_um   = pt_um 
        and um_alt_um = idh_um 
      no-lock no-error.
    if available(um_mstr) then
    do:
      v_conv = um_conv.
    end.
    v_ctns = v_ctns + ((idh_qty_inv * idh_um_conv) / v_conv).
end.

{edputnum.i 1548  10 v_units}
{edputnum.i 1558  10 v_weight}
{edputch.i  1568   2 upper(v_wt_um)}
{edputnum.i 1570   8 v_volume}
{edputch.i  1578   2 upper(v_vol_um)}
{edputnum.i 1580  10 v_ctns}         /* total number of cartons */
{edputch.i  1590  1  ih_hist_a.ord_entry_mthd}  /* Code for how order Entered
                                                  "" - online "E" - EDI "W" - Web */
{edputln.i}

/* RECORD TYPE R21 */
{edputch.i   1   3 'R21'}
{edputch.i   4  20 ad_cust.ad_edi_tpid}
{edputch.i  24  30 ih_hist.ih_inv_nbr}
{edputch.i  54  30 ih_hist.ih_po}
{edputch.i  84  300 ih_hist.ih__chr02}
{edputln.i}

/* RECORD TYPE R22 */
/*NEED TO GET THE TAXAMT AND TAX% FOR THE TRAILER CODES*/
RUN GET-R22-TAX.ip.

/* RECORD TYPE R30 */
for each idh_hist no-lock 
where idh_domain = global_domain 
  and idh_inv_nbr = ih_inv_nbr
  and idh_nbr = ih_nbr:

    find pt_mstr 
      where pt_domain = global_domain 
        and pt_part = idh_part 
      no-lock no-error.
    if available(pt_mstr) then
      ptdesc = pt_desc1 + " " + pt_desc2.
    else
      ptdesc = "".
    
    ext_price = idh_qty_inv * idh_price.
    
    {edputch.i   1   3 'R30'}
    {edputch.i   4  20 ad_cust.ad_edi_tpid}
    {edputch.i  24  30 ih_hist.ih_inv_nbr}
    {edputnum.i 54   6 idh_hist.idh_line}  /* so line number */
    {edputnum.i 60   6 idh_hist.idh_line}  /* po line number */
    {edputnum.i 66  10 idh_hist.idh_qty_inv}
    {edputch.i  76   2 upper(idh_hist.idh_um)}
    {edputnum.i 78  17 idh_hist.idh_price}
    {edputch.i  95   2 upper(idh_hist.idh_um)}
    if idh_hist.idh_custpart <> "" then 
      {edputch.i  145  48 idh_hist.idh_custpart}  /* buyers catalog number */
    else
      {edputch.i  145  48 idh_hist.idh_part}  /* Our part number */
    find first um_mstr 
      where um_part = pt_part
        and um_alt_um = "CA"
      no-lock no-error.
    if available(um_mstr) then
    do:
      {edputnum.i  241  48 um_mstr.um_conv}
    end.
    else do:
      {edputnum.i  241  48 "1"}
    end.

    {edputch.i  289   48 "(if available(pt_mstr) then pt_upc else '')"}
    
    find first cp_mstr 
    where cp_domain = global_domain 
    and cp_cust = ""
    and cp_part = idh_part
    no-lock no-error.
    if available(cp_mstr) then
        {edputch.i  385  48 cp_mstr.cp_cust_part}  /* vendors catalog number */
    else {edputch.i  385  48 idh_part} /* Our part # to avoid ""'s */
    if available(pt_mstr) then
    do:
        {edputnum.i  534  20 pt_width}
        {edputnum.i  554  20 pt_height}
        {edputnum.i  574  20 pt_length}
        {edputnum.i  594  20 pt_ship_wt}
        
        find first um_mstr 
        where um_part = pt_part
          and um_alt_um = "CA"
        no-lock no-error.
        if available(um_mstr) then
        do:
            {edputnum.i  694  6 "idh_qty_inv / um_conv"}
            {edputnum.i  700  6 um_conv}
            {edputch.i   707  2 upper(um_alt_um)}
    end.
    else do:
        {edputnum.i  694  6 idh_qty_inv}
        {edputnum.i  700  6 "1"}
        {edputch.i   707  2 'EA'}
    end.
end.

{edputch.i  614  80 ptdesc}

{edputln.i}

/* RECORD TYPE R31 */
{edputch.i   1   3 'R31'}
{edputch.i   4  20 ad_cust.ad_edi_tpid}
{edputch.i  24  30 ih_hist.ih_inv_nbr}
{edputch.i  54  30 ih_hist.ih_po}
{edputnum.i 84   6 idh_hist.idh_line}  /* so line number */
{edputch.i  90 300 idh_hist.idh__chr09}
{edputln.i}
  
/*RECORD TYPE R32 - Line Tax: 1 or Many*/
v-seq = 0.

FOR EACH tx2d_det NO-LOCK
  WHERE tx2d_domain = global_domain 
    AND tx2d_ref = ih_inv_nbr 
    AND tx2d_nbr = ih_nbr 
    AND tx2d_tr_type = "16" 
    AND tx2d_line = idh_hist.idh_line:

  ASSIGN
    /*LACKING BETTER INFO, SEND SEQUENCE AS "TAX DESC"*/
    /*WOULD NEED TO GET FROM ACTUAL VERTEX TABLES TO OBTAIN GST, ST*/
    v-seq[1] = v-seq[1] + 1
    v-code[1] = "TAX "
    v-desc[1] = STRING(v-seq[1],"9999")
    v-tax[1] = 100 * tx2d_cur_tax_amt   /*ACTUAL TAX IN CURRENCY * 100*/
    v-amt1[1] = tx2d_tax_amt            /*BASE TAX*/
    v-amt2[1] = tx2d_taxable_amt        /*BASE TAXABLE*/
    v-pct[1] = IF v-amt2[1] = 0
              THEN 0 
              ELSE (100 * (v-amt1[1] / v-amt2[1]))
    .

  /*RECORD TYPE R32*/
  {edputch.i    1   3 'R32'}
  {edputch.i    4  20 ad_cust.ad_edi_tpid}
  {edputch.i   24  30 ih_hist.ih_inv_nbr}
  {edputch.i   54  30 ih_hist.ih_po}
  {edputnum.i  84   6 idh_hist.idh_line}  /* so line number */
  {edputch.i   90   4 v-code[1]}          /*"TAX "*/
  {edputch.i   94   4 v-desc[1]}          /*size 4 seq for ord lin*/
  {edputnum.i  98  15 v-tax[1]}           /*Tax amt * 100*/
  {edputnum.i 113  15 v-pct[1]}           /*Calc TaxPct, not * 100*/
  {edputln.i}
END. /* for each tx2d_det */
end. /* for each idh_hist */


PROCEDURE GET-R22-TAX.ip.
    DEF VAR p-i AS INT.
    
    if available(ih_hist) then.
    
    /*RESET/INITIALIZE ACCUM VARS*/
    ASSIGN
      v-code = ""
      v-desc = ""
      v-seq = 0                   /*ALL WILL HAVE ONLY ONE RECORD*/
      v-desc = ""
      v-tax = 0
      v-chrg = 0
      v-amt1 = 0
      v-amt2 = 0
      v-pct = 0
      v-ovly = ""
      .
    /*SET FOR THE 3 TRAILERS (1-3)*/ 
    ASSIGN 
      v-code[1] = "FRT " 
      v-desc[1] = ih_trl1_cd 
      v-chrg[1] = ih_trl1_amt  
      v-code[2] = "MISC"
      v-desc[2] = ih_trl2_cd
      v-chrg[2] = ih_trl2_amt 
      v-code[3] = "OTH " 
      v-desc[3] = ih_trl3_cd 
      v-chrg[3] = ih_trl3_amt 
      .
    
    /*PREPARE FOR TAX RECORD (4)*/
    ASSIGN
      v-code[4] = "TAX "
      v-desc[4] = "TOTL"
      v-chrg[4] = invtot_tax_amt
      v-tax[4] = 0
      v-pct[4] = 0
      .
    
    /*DO FOR TRAILERS*/
    DO p-i = 1 TO 3:
  
  /*NOW ACCFOR EVERY POSSIBLE TAX DETAIL RECORD*/
  FOR EACH tx2d_det NO-LOCK
    WHERE tx2d_domain = global_domain 
      AND tx2d_ref = ih_inv_nbr 
      AND tx2d_nbr = ih_nbr 
      AND tx2d_tr_type = "16" 
      AND tx2d_line >= 99999
      AND tx2d_trl = v-desc[p-i]
    :
    ASSIGN
      v-seq[p-i] = 1        /*ALLOWANCES AND TAXES REPORT IN A SINGLE RECORD*/
      v-desc[p-i] = STRING(v-seq[p-i],"9999")
      v-tax[p-i] = tx2d_cur_tax_amt                 /*ACTUAL TAX IN CURRENCY*/
      v-amt1[p-i] = v-amt1[p-i] + tx2d_tax_amt      /*BASE TAX*/
      v-amt2[p-i] = v-amt2[p-i] + tx2d_taxable_amt  /*BASE TAXABLE*/
      v-pct[p-i] = IF v-amt2[p-i] = 0
                  THEN 0 
                  ELSE (100 * (v-amt1[p-i] / v-amt2[p-i])).            
    END.
    END  . 
      
    do p-i = 1 to 4:
      /*SECTION R22, IF NON-ZERO WITH TAX SUMMARIZED IN CASE THERE ARE*/
      /*MORE THAN ONE tx2d_det FOR A GIVEN TRAILER*/
      IF v-chrg[p-i] <> 0 THEN DO:
        assign
          v-chrg[p-i] = 100 * v-chrg[p-i]
          v-tax[p-i] = 100 * v-tax[p-i]
          v-pct[p-i] = v-pct[p-i]
          .
        {edputch.i    1   3 'R22'}
        {edputch.i    4  20 ad_cust.ad_edi_tpid}
        {edputch.i   24  30 ih_hist.ih_inv_nbr}
        {edputch.i   54   4 v-code[p-i]}  /*FRT, MISC, OTH or TAX*/
        {edputnum.i  58  15 v-chrg[p-i]}  /*ALLOW/CHARGE Amt * 100*/
        {edputnum.i  73  15 v-tax[p-i]}   /*TaxAmt for ALL/CHRG * 100*/
        {edputnum.i  88  15 v-pct[p-i]}   /*Pct not multip by 100*/
        {edputch.i   103 15 v-desc[p-i]}  /*The actual trailer code */
        {edputln.i}
      END.
    END.
END PROCEDURE.



