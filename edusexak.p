/* edusexak.p   ASN Export program called from imports                  */
/* Created By:  Wendell Henry   12/1/2009                               */
/* Purpose:     Creates the formatted text file for ASN's               */
/*                                                                      */
/* Task145      ASN Export                                              */
/************************************************************************/

{mfdeclre.i}
{gplabel.i} /* EXTERNAL LABEL INCLUDE */

 define input parameter so_recid          as recid.
/* mode defined as 
    1 = The order was accepted no problem A OK 
    2 = The order accepted with warnings (i.e. price diferences, bad parts
    3 = The order was rejected with errors (i. e. ?? this may never be used)  */
 DEFINE INPUT PARAMETER v_855_mode AS INTEGER.
 DEFINE INPUT PARAMETER f-name AS CHARACTER .


{edpodef.i} 
{eddefcon.i}
{mfivtrla.i "new"}
{edexport.i "new"}
 

define variable linedata        as   character no-undo.
define variable ptdesc          like pt_desc1  no-undo.
DEFINE VARIABLE v_ack_type      AS   CHARACTER NO-UNDO.
DEFINE VARIABLE v_itm_stat      AS CHARACTER NO-UNDO.
define variable ext_price       like sod_price no-undo .


define buffer ad_cust for ad_mstr.
define buffer ad_ship for ad_mstr.
define buffer ad_bill for ad_mstr.
define buffer ad_remit for ad_mstr.
define buffer ad_from for ad_mstr.
define buffer ad_vend for ad_mstr.
    

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

FUNCTION f-upc RETURNS CHAR (p_upc AS char) FORWARD .

function str_date returns char (input p_date as date):
    return ( string(year(p_date), '9999')
         + string(month(p_date), '99')
         + string(day(p_date), '99')).
end function.

OUTPUT stream dataout to value(f-name) append.


/*create the file */
RUN create-855 .
output stream dataout close.


find so_mstr where recid(so_mstr) = so_recid no-lock.

CASE v_855_mode:
    WHEN 1  THEN DO:      
        PUT UNFORMATTED " Order accepted unchanged . So # " STRING(so_mstr.so_nbr) SKIP. 
    END.
    WHEN 2 THEN DO:
        PUT UNFORMATTED " Order accepted with warnings.  "  SKIP. 
    END.
    WHEN 3  THEN      DO:  
        PUT UNFORMATTED " Order rejected.  " SKIP. 
    END.

END CASE. 

PUT     skip(1).


PROCEDURE create-855 .  
    find so_mstr 
        where recid(so_mstr) = so_recid no-lock.
    FIND FIRST so_mstr_a 
        WHERE sls_ord = so_nbr NO-LOCK . 
    find cm_mstr 
        where cm_domain = global_domain 
        and cm_addr = so_cust no-lock.
    find ad_cust 
        where ad_cust.ad_domain = global_domain 
        and ad_cust.ad_addr = so_cust no-lock.
    find ad_ship 
        where ad_ship.ad_domain = global_domain 
        and ad_ship.ad_addr = so_ship no-lock.
    find ad_bill 
        where ad_bill.ad_domain = global_domain 
        and ad_bill.ad_addr = so_bill no-lock.
    find first ad_remit 
        where ad_remit.ad_domain = global_domain
        AND ad_remit.ad_addr = so_site no-lock.
    find first ad_vend
        where ad_vend.ad_domain = global_domain
        AND ad_vend.ad_addr = "~~invoice" no-lock.
    
    find first sod_det 
    WHERE sod_domain = global_domain
      AND sod_det.sod_nbr = so_nbr
       no-lock no-error.
    if available(sod_det) then
    find first ad_from 
      where ad_from.ad_domain = global_domain
        AND ad_from.ad_addr = sod_site
      no-lock no-error.
    else
    find first ad_from 
      where ad_from.ad_domain = global_domain
        AND ad_from.ad_addr = "02"
      no-lock no-error.
    
    /* Calculate the acknowlegement type
      AC for acknowledge with detail and change, AD for acknowledge with detail no change,
      AE for acnowledge with exception detail only, AK for aknowledge no detail or change,
      AP for acknowledge product replenishment, RJ for rejected  */
    CASE v_855_mode :
        WHEN 1  THEN
            v_ack_type = "AD" .
        WHEN 2 THEN
            v_ack_type = "AC" .
        WHEN 3  THEN
            v_ack_type = "RJ" .
    END CASE.
    
    /* RECORD TYPE R10 */
    {edputch.i  1    3 'R10'}
    {edputch.i  4   20 ad_cust.ad_edi_tpid}
    {edputch.i  24   1 'X'}
    {edputch.i  25   6 "fill('0', 6 - length(ad_cust.ad_edi_std))
                       + ad_cust.ad_edi_std"}
    {edputch.i  31   6 "entry(PO_ACKNOWLEDGE_TYPE, ansi_document_types)"}
    {edputch.i  37   1 'P'}
    {edputch.i  38  30 so_po }
    {edputch.i  68   2 "IF v_855_mode = 3  THEN '01' ELSE '00' "}  /*00 for original 01 for cancel */
    {edputch.i  70   8 "str_date(today)"}
    {edputch.i  78   8 "string(time, 'HH:MM:SS')"}
    {edputch.i  86   2 v_ack_type}
    
    {edputln.i}
    
        

    /* RECORD TYPE R20 */
    {edputch.i     1   3 'R20'}
    {edputch.i     4  20 ad_cust.ad_edi_tpid}
    {edputch.i    24  30 so_mstr.so_po} 
    {edputch.i    54   8 "str_date(so_mstr.so_ord_date)"}
    {edputnum.i   62  30 so_mstr.so_rev}     /* Release Num */
    {edputch.i    92   2  so_mstr.so_curr}
    {edputch.i    94  30  "' '" }                /* Department Number */
    {edputch.i   125  30   ad_cust.ad_edi_id}  /*Vendor Number */
    {edputch.i   155  30 "' '" }  /*Contact Name */
    {edputch.i   185  20 "' '" } /* contact phome Number*/
        
    {edputch.i   205  24 ad_bill.ad_edi_id}
    {edputch.i   229  35 ad_bill.ad_name}
    
        

    if ad_bill.ad_line1 = "" then
    do:
        {edputch.i  264  35 ad_bill.ad_line2}
        {edputch.i  299  35 ad_bill.ad_line3}
    end.
    else do:
        {edputch.i  264  35 ad_bill.ad_line1}
        {edputch.i  299  35 ad_bill.ad_line2}
    end.
    {edputch.i    334  35 ad_bill.ad_city}
    {edputch.i    369   3 ad_bill.ad_state}
    {edputch.i    372  10 ad_bill.ad_zip}
    {edputch.i    382   5 ad_bill.ad_ctry}
    
    {edputch.i  387  24 ad_ship.ad_edi_id}
    {edputch.i  411  35 ad_ship.ad_name}
    if ad_ship.ad_line1 = "" THEN do:
      {edputch.i 446  35 ad_ship.ad_line2}
      {edputch.i 481  35 ad_ship.ad_line3}
    end.
    else do:
      {edputch.i 448  35 ad_ship.ad_line1}
      {edputch.i 481  35 ad_ship.ad_line2}
    end.
    {edputch.i 516  35 ad_ship.ad_city}
    {edputch.i 551   3 ad_ship.ad_state}
    {edputch.i 554  10 ad_ship.ad_zip}
    {edputch.i 564   5 ad_ship.ad_ctry}

    {edputch.i 569  24 ad_vend.ad_edi_id}
    {edputch.i 593  35 ad_from.ad_name}
    if ad_from.ad_line1 = "" THEN do:
        {edputch.i 628  35 ad_from.ad_line2}
        {edputch.i 663  35 ad_from.ad_line3}
    end.
    else do:
        {edputch.i 628  35 ad_from.ad_line1}
        {edputch.i 663  35 ad_from.ad_line2}
    end.
    {edputch.i 698  35 ad_from.ad_city}
    {edputch.i 733   3 ad_from.ad_state}
    {edputch.i 736  10 ad_from.ad_zip}
    {edputch.i 746   5 ad_bill.ad_ctry}
    
    find first ct_mstr
    where ct_mstr.ct_domain = global_domain
      and ct_mstr.ct_code = so_mstr.so_cr_terms
    no-lock.
    if available(ct_mstr) THEN do:
        {edputch.i  751   15 ct_mstr.ct_code}
        {edputnum.i 766   15 ct_mstr.ct_disc_pct}
        {edputch.i  781   10 "str_date(so_mstr.so_ord_date
                                      + ct_mstr.ct_disc_days)"}
        {edputnum.i 791   10  ct_mstr.ct_disc_days}
        {edputch.i  801    2  "' '" }    /* ?? Delivery requested date ?? */

        {edputch.i  803    8 "str_date(so_mstr.so_ord_date
                                      + ct_mstr.ct_due_days)"}
        {edputch.i  811     2 "'  '" }  /*?? Transportation method ?? */
    end.

    {edputch.i  819    8 "str_date(so_mstr_a.per_date)"}
   
    {edputln.i}
                   
    /* RECORD TYPE R21 */
    {edputch.i   1   3 'R21'}
    {edputch.i   4  20 ad_cust.ad_edi_tpid}
    {edputch.i  24  30 so_mstr.so_po}
    {edputch.i  54  300 so_mstr.so__chr02}
    {edputln.i}
    
                                        


    /* RECORD TYPE R30 */
    for each sod_det no-lock
            where sod_domain = global_domain
            and sod_nbr = so_nbr :
            find pt_mstr
            where pt_domain = global_domain
            and pt_part = sod_part
            no-lock no-error.
        if available(pt_mstr) then
            ptdesc = pt_desc1 + " " + pt_desc2.
        else
            ptdesc = "" .
        ext_price = sod_qty_ord * sod_price.

        /* Status code indicates the asscpet/reject on the individual item 
            IA for item accepted, IC for item accepted changes made, 
            ID is for Item deleted */
        IF v_855_mode <> 3  THEN  v_itm_stat = "IA" . /* Order accepted */
        ELSE  
         DO:                              /* Order rejected */
             v_itm_stat = "ID" .
             FIND FIRST ed_sod_det WHERE  ed_sod_line = sod_line NO-LOCK NO-ERROR.
        END.
    
        {edputch.i   1   3 'R30'}
        {edputch.i   4  20 ad_cust.ad_edi_tpid}
        {edputch.i  24  30 so_mstr.so_po}
        {edputnum.i 54   6 sod_det.sod_line}  /* so line number */
        {edputnum.i 60   6 sod_det.sod_line}  /* po line number */
        {edputnum.i 66  10 sod_det.sod_qty_ord}
        {edputch.i  76   2 upper(sod_det.sod_um)}
        {edputnum.i 78  17 sod_det.sod_price }
        {edputch.i  95   2 upper(sod_det.sod_um)}
        if sod_det.sod_custpart <> "" then
            {edputch.i  145  48 sod_det.sod_custpart}  /* buyers catalog number */
        else
            {edputch.i  145  48 sod_det.sod_part}  /* Our part number */
    
        {edputch.i  289   48  "(if available(pt_mstr) then f-upc(pt_upc) else '')"}
    
        find first cp_mstr
            where cp_domain = global_domain
            and cp_cust = ""
            and cp_part = sod_det.sod_part
            no-lock no-error.
        if available(cp_mstr) then
             {edputch.i  385  48 cp_mstr.cp_cust_part}  /* vendors catalog number */
        else {edputch.i  385  48 sod_det.sod_part} /* Our part # to avoid ""'s */
    
        {edputch.i  481  80 ptdesc}
    
        {edputln.i}
    
        /* RECORD TYPE R31 */
        {edputch.i   1   3 'R31'}
        {edputch.i   4  20 ad_cust.ad_edi_tpid}
        {edputch.i  24  30 so_mstr.so_po}
        {edputnum.i 54   6 sod_det.sod_line}  /* so line number */
        {edputch.i  60 300 sod_det.sod__chr09}
        {edputln.i}  
        
    
        /* RECORD TYPE R33 */
        {edputch.i   1   3 'R33'}
        {edputch.i   4  30 so_mstr.so_po}
        {edputch.i  34  2  v_itm_stat}
        {edputnum.i 36  10 sod_det.sod_qty_ord}
        {edputch.i  46  1  'I'}
        {edputnum.i 47  10 sod_det.sod_qty_ord}
        {edputnum.i 57  10 "(IF v_itm_stat = 'ID' THEN 0 ELSE sod_det.sod_price ) "}
        {edputch.i  67  30 "(IF v_itm_stat = 'ID' THEN ' ' ELSE sod_det.sod_part ) " }
        {edputch.i  97 2   "(IF v_itm_stat = 'IA' THEN 'I 'ELSE '') }
        {edputln.i}
    
    end. /* for each sod_det */
END PROCEDURE . /*create 855 */

FUNCTION f-upc RETURNS CHAR:
    DEF VAR v_odd_tot AS INTEGER.
    DEF VAR v_even_tot AS INTEGER.
    DEF VAR v_tot AS INTEGER.
    DEF VAR v AS INTEGER. 

    /* Add in the fixed company ID */
    p_upc = "87427700" + p_upc .

    /*Get the total of the odd digits and the even digits */
    DO v = 1 TO 11 .   
        IF v MOD 2 = 0 THEN
            v_even_tot = v_even_tot + INTEGER(SUBSTRING(p_upc,v,1)).
        ELSE
            v_odd_tot = v_odd_tot + INTEGER(SUBSTRING(p_upc,v,1)).  
    END.
    /* multiple the odd total times 3 and add the even*/         
    v_tot = ((v_odd_tot) * 3) + v_even_tot.
    /*Return the number requried to raise the total to the nearest power of ten*/
    RETURN  p_upc + (STRING(10 - (v_tot MOD 10)) ) .

END FUNCTION.
