
/*****************************************************************************/
/*  Program Name:  xxsoiq1.p                                                 */
/*  Descripton:  Displays the details of the sales order and lines or the    */
/*               invoice and lines                                           */
/*                                                                           */
/*  Parameters:    nbr - sales ordr number                                   */
/*                 inv - invoice number if invoice                           */
/*                 type - "so" sales order "ih" invoice                      */
/*                                                                           */
/*  Input Files:   None                                                      */
/*                                                                           */
/*  Ouput Files:   None                                                      */
/*                                                                           */
/*****************************************************************************/
/* MODIFICATIONS:                                                            */
/* Date      Project     Name                    Description                 */
/* 01/14/08  eb2.1       Tomasz M.-BravePoint    Clean-up for eb2.1 upgrade  */
/*****************************************************************************/
  
{mfdeclre.i}
{etvar.i &new="new"}
{gplabel.i}
{etrpvar.i &new="new"}
{etdcrvar.i "new"}
{etsotrla.i "NEW"}

DEFINE INPUT PARAMETER nbr LIKE so_nbr.
DEFINE INPUT PARAMETER inv LIKE ih_inv_nbr.
DEFINE INPUT PARAMETER TYPE AS CHARACTER.

DEFINE VARIABLE qty_open LIKE idh_qty_ord LABEL "Qty Open".
DEFINE VARIABLE desc1 LIKE pt_desc1 NO-UNDO.
DEFINE VARIABLE shipv_desc LIKE code_desc NO-UNDO.
DEFINE VARIABLE ext_price LIKE pt_price LABEL "Amount" NO-UNDO.
DEFINE VARIABLE cname LIKE ad_name FORMAT "x(24)" NO-UNDO.
DEFINE VARIABLE bill_name LIKE ad_name FORMAT "x(24)" NO-UNDO.
DEFINE VARIABLE cnsg_name LIKE ad_name FORMAT "x(24)" NO-UNDO.
DEFINE VARIABLE v_chg1_lbl AS CHARACTER FORMAT "x(12)" NO-UNDO.
DEFINE VARIABLE v_chg2_lbl AS CHARACTER FORMAT "x(12)" NO-UNDO.
DEFINE VARIABLE v_chg3_lbl AS CHARACTER FORMAT "x(12)" NO-UNDO.
DEFINE VARIABLE cline1 LIKE ad_line1 NO-UNDO.
DEFINE VARIABLE cline2 LIKE ad_line2 NO-UNDO.
DEFINE VARIABLE ccsz AS CHARACTER FORMAT "x(39)" NO-UNDO.
DEFINE VARIABLE sname LIKE ad_name FORMAT "x(23)" NO-UNDO.
DEFINE VARIABLE sline1 LIKE ad_line1 NO-UNDO.
DEFINE VARIABLE sline2 LIKE ad_line2 NO-UNDO.
DEFINE VARIABLE scsz AS CHARACTER FORMAT "x(30)" NO-UNDO.
DEFINE VARIABLE v_cnsgn_to LIKE ih_hist_a.cnsgn_to.
DEFINE VARIABLE v_cmmts LIKE mfc_logical NO-UNDO INITIAL YES.
DEFINE VARIABLE v_title AS CHARACTER FORMAT "x(30)" NO-UNDO.
DEFINE VARIABLE v_open_lbl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v_ln_title AS CHARACTER FORMAT "x(30)" NO-UNDO.
DEFINE VARIABLE j AS INTEGER NO-UNDO.
DEFINE VARIABLE fr_policy LIKE cm_mstr_a.freight_policy.
DEFINE VARIABLE v_line_flag AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-shiptophone LIKE ad_phone NO-UNDO.

DEFINE NEW SHARED VARIABLE so_recno AS RECID.
DEFINE NEW SHARED VARIABLE ih_recno AS RECID.

DEFINE TEMP-TABLE LINE
    FIELDS line_line LIKE sod_line
    FIELDS line_site LIKE sod_site
    FIELDS line_item LIKE sod_part
    FIELDS line_desc LIKE pt_desc1
    FIELDS line_ord  LIKE sod_qty_ord
    FIELDS line_open LIKE sod_qty_ord
    FIELDS line_price LIKE sod_price
    FIELDS line_um   LIKE sod_um
    FIELDS line_ext  LIKE ext_price
    FIELDS line_indx LIKE sod_cmtindx.

FORMAT
    so_nbr                COLON 12
    so_ord_date           COLON 36
    so_req_date           COLON 59        LABEL "Req Date"
    global_userid         AT 71        NO-LABELS FORMAT "x(8)"
    so_po                 COLON 12        LABEL "PO"
    so_mstr.so_due_date   COLON 59
    so_bill               COLON 12
    bill_name                          NO-LABELS
    so_ship_date          COLON 59
    v_cnsgn_to            COLON 12
    cnsg_name                          NO-LABELS
    so_userid             COLON 59        LABEL "Entered By"
    so_shipvia            COLON 12        FORMAT "xxx"
    shipv_desc                         NO-LABELS
    so_bol                COLON 59
    so_cr_terms           COLON 13
    so_stat               COLON 36        FORMAT "x(4)" LABEL "Hold Status"
    so_rmks               COLON 50        FORMAT "x(25)"
    so_fr_terms           COLON 14       FORMAT "x(10)"
    fr_policy             COLON 40       FORMAT "x(20)"
    so_mstr_a.shiptec     COLON 70
    SKIP
    so_slspsn[1]
    so_slspsn[2]                          LABEL "[2]"
    so_slspsn[3]                          LABEL "[3]"
    so_slspsn[4]                          LABEL "[4]"
    WITH FRAME sohdr SIDE-LABELS WIDTH-CHARS 80 NO-ATTR-SPACE
    TITLE COLOR normal " Sales Order ".

FORMAT
    SPACE(1)
    so_cust
    SKIP(1) SPACE(1)
    ad_name NO-LABELS
    SKIP SPACE(1)
    ad_line1 NO-LABELS
    SKIP SPACE(1)
    ad_line2 NO-LABELS
    SKIP SPACE(1)
    ad_city NO-LABELS
    ad_state NO-LABELS
    ad_zip NO-LABELS
    SKIP SPACE(1)
    ad_country NO-LABELS
    WITH OVERLAY FRAME soldto COLUMNS 1 SIDE-LABELS WIDTH-CHARS 40.

FORMAT
    SPACE(1)
    so_ship
    SKIP(0) SPACE(1)
    v-shiptophone
    SKIP(0) SPACE(1)
    ad_name NO-LABELS
    SKIP SPACE(1)
    ad_line1 NO-LABELS
    SKIP SPACE(1)
    ad_line2 NO-LABELS
    SKIP SPACE(1)
    ad_city NO-LABELS
    ad_state NO-LABELS
    ad_zip NO-LABELS
    SKIP SPACE(1)
    ad_country NO-LABELS
    WITH OVERLAY FRAME shipto COLUMNS 41 SIDE-LABELS WIDTH-CHARS 40.

FORMAT
    sod_line
    sod_site                 FORMAT "x(2)"           COLUMN-LABEL "Si"
    sod_part                 FORMAT "x(10)"          COLUMN-LABEL "Item"
    desc1                    FORMAT "x(15)"
    sod_qty_ord              FORMAT "->>>,>>9"       COLUMN-LABEL "Ord"
    SPACE(0)
    qty_open                 FORMAT "->>>,>>9"       COLUMN-LABEL "Open"
    SPACE(0)
    sod_price                FORMAT "->>>,>>9.99"
    sod_um
    ext_price                FORMAT ">,>>>,>>9.99-" COLUMN-LABEL "Amount "
    WITH DOWN FRAME soddet NO-ATTR-SPACE WIDTH-CHARS 80 NO-UNDERLINE
    TITLE COLOR normal " Line Items ".

FORMAT
    ih_inv_nbr            COLON 12
    ih_inv_date           COLON 36        LABEL "Inv Date"
    ih_ship_date          COLON 59
    global_userid         AT 71           NO-LABELS
    ih_nbr                COLON 12
    ih_ord_date           COLON 36
    ih_po                 COLON 59        LABEL "PO" FORMAT "x(18)"
    ih_bill               COLON 12
    bill_name                             NO-LABELS
    ih_userid             COLON 59        LABEL "Entered By"
    v_cnsgn_to            COLON 12
    cnsg_name                             NO-LABELS
    ih_shipvia            COLON 12        FORMAT "xxx"
    shipv_desc                            NO-LABELS
    ih_bol                COLON 59
    ih_cr_terms           COLON 13
    ih_stat               COLON 36        FORMAT "x(4)" LABEL "Hold Status"
    ih_rmks               COLON 50        FORMAT "x(25)"
    ih_fr_terms           COLON 14
    fr_policy             COLON 43
    SKIP
    ih_slspsn[1]
    ih_slspsn[2]                          LABEL "[2]"
    ih_slspsn[3]                          LABEL "[3]"
    ih_slspsn[4]                          LABEL "[4]" SKIP
    WITH FRAME ihhdr WIDTH-CHARS 80 NO-ATTR-SPACE
    TITLE COLOR normal " Invoice History " SIDE-LABELS.

FORMAT
    idh_line
    idh_site                FORMAT "x(2)"       COLUMN-LABEL "Si"
    idh_part                FORMAT "x(10)"      COLUMN-LABEL "Item"
    desc1                   FORMAT "x(15)"
    idh_qty_ord             FORMAT "->>>,>>9"   COLUMN-LABEL "Ord"
    SPACE(0)
    idh_qty_inv             FORMAT "->>>,>>9"   COLUMN-LABEL "Inv"
    SPACE(0)
    idh_price               FORMAT "->>>,>>9.99"
    idh_um
    ext_price               FORMAT ">,>>>,>>9.99-" COLUMN-LABEL "Amount "
    WITH DOWN FRAME idhdet WIDTH-CHARS 80 NO-ATTR-SPACE NO-UNDERLINE
    TITLE COLOR normal " Line Items ".


FORMAT
    cmt_cmmt
    WITH DOWN FRAME cmtdet NO-LABELS CENTERED
    TITLE v_title OVERLAY ROW 3.

FORMAT
    line_line
    line_site   FORMAT "x(2)"           COLUMN-LABEL "Si"
    line_item   FORMAT "x(10)"          COLUMN-LABEL "Item"
    line_desc   FORMAT "x(15)"
    line_ord    FORMAT "->>>,>>9"       COLUMN-LABEL "Ord"
    SPACE(1)
    line_open   FORMAT "->>>,>>9"       COLUMN-LABEL "Open/Inv"
    SPACE(0)
    line_price  FORMAT "->>>,>>9.99"
    line_um
    line_ext    FORMAT "->>>,>>9.99"
    WITH FRAME c NO-ATTR-SPACE WIDTH-CHARS 80 5 DOWN NO-UNDERLINE
    TITLE "Line Items With Comments".

CLEAR FRAME sohdr.
CLEAR FRAME soddet ALL NO-PAUSE.
CLEAR FRAME ihhdr.
CLEAR FRAME idhdet ALL NO-PAUSE.
CLEAR FRAME sotrl.
CLEAR FRAME cmtdet ALL NO-PAUSE.
CLEAR FRAME c.
CLEAR FRAME shipto ALL NO-PAUSE.
CLEAR FRAME soldto ALL NO-PAUSE.

IF TYPE = "so" THEN
DO TRANSACTION:

  FIND so_mstr NO-LOCK
      WHERE so_domain = global_domain
      AND so_nbr = nbr NO-ERROR.

  IF AVAILABLE so_mstr THEN
  DO:

    FIND so_mstr_a
        WHERE so_mstr_a.sls_ord = so_mstr.so_nbr
        NO-LOCK NO-ERROR.

    IF AVAILABLE(so_mstr_a) THEN
    ASSIGN
        v_cnsgn_to = so_mstr_a.cnsgn_to.
    ELSE
    ASSIGN
        v_cnsgn_to = "".

    FIND ad_mstr NO-LOCK
        WHERE ad_domain = global_domain
        AND ad_addr = so_bill NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    ASSIGN
        bill_name = ad_name.
    ELSE
    ASSIGN
        bill_name = "".

    FIND ad_mstr NO-LOCK
        WHERE ad_domain = global_domain
        AND ad_addr = so_ship NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    ASSIGN v-shiptophone = ad_phone.
    ELSE
    ASSIGN v-shiptophone = "".

    FIND ad_mstr NO-LOCK
        WHERE ad_domain = global_domain
        AND ad_addr = so_mstr_a.cnsgn_to NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    ASSIGN
        cnsg_name = ad_name.
    ELSE
    ASSIGN
        cnsg_name = "".

    FIND code_mstr NO-LOCK
        WHERE CODE_domain = global_domain
        AND code_fldname = "cm_shipvia"
        AND code_value     = so_shipvia NO-ERROR.
    shipv_desc         = IF AVAILABLE code_mstr THEN
    code_cmmt ELSE ""
    .

    IF so_mstr.so_user1 = "" THEN
    DO:
      FIND cm_mstr_a WHERE cm_mstr_a.addr = so_mstr.so_cust
          NO-LOCK NO-ERROR.

      fr_policy = IF AVAILABLE(cm_mstr_a) THEN
      cm_mstr_a.freight_policy ELSE ""
      .

    END.
    ELSE
        fr_policy = so_mstr.so_user1.

    DISPLAY so_nbr
        global_userid
        so_stat
        so_cr_terms
        so_ord_date
        so_req_date
        so_slspsn[1]
        so_slspsn[2]
        so_slspsn[3]
        so_slspsn[4]
        so_mstr.so_due_date
        so_mstr_a.shiptec
        so_po
        v_cnsgn_to
        cnsg_name
        so_bill
        bill_name
        so_shipvia
        shipv_desc
        so_ship_date
        so_ship_date
        so_bol
        fr_policy
        so_fr_terms
        so_userid
        so_rmks
        WITH FRAME sohdr.

    DISPLAY so_cust WITH FRAME soldto.
    FIND ad_mstr
        WHERE ad_domain = global_domain
        AND ad_addr = so_cust
        NO-LOCK NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    DISPLAY
        ad_name ad_line1 ad_line2 ad_city ad_state
        ad_zip ad_country
        WITH FRAME soldto.

    DISPLAY so_ship WITH FRAME shipto.
    FIND ad_mstr
        WHERE ad_domain = global_domain
        AND ad_addr = so_ship
        NO-LOCK NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    DISPLAY
        ad_name ad_line1 ad_line2 ad_city ad_state
        ad_zip ad_country v-shiptophone
        WITH FRAME shipto.

  END.

  RUN comment-proc.

  v_line_flag = NO.

  FOR EACH sod_det NO-LOCK
        WHERE sod_nbr = so_nbr:
    FIND pt_mstr NO-LOCK
        WHERE pt_domain = global_domain
        AND pt_part = sod_part NO-ERROR.
    ASSIGN
        desc1 = IF AVAILABLE pt_mstr THEN pt_desc1 ELSE sod_desc
        qty_open = sod_qty_ord - sod_qty_ship
        ext_price = qty_open * sod_price
        v_line_flag = YES.
    DISPLAY
        sod_line
        sod_site
        sod_part
        desc1
        sod_qty_ord
        qty_open
        sod_price
        sod_um
        ext_price
        WITH FRAME soddet.
    DOWN WITH FRAME soddet.

    IF sod_cmtindx <> ?
        AND CAN-FIND (FIRST cmt_det
        WHERE cmt_domain = global_domain
        AND cmt_indx = sod_cmtindx) THEN
    DO:
      CREATE LINE.
      ASSIGN
          line_line  = sod_line
          line_site  = sod_site
          line_item  = sod_part
          line_desc  = desc1
          line_ord   = sod_qty_ord
          line_open  = qty_open
          line_price = sod_price
          line_um    = sod_um
          line_ext   = ext_price
          line_indx  = sod_cmtindx.
    END.
  END.
  IF v_line_flag THEN
  RUN line-cmmt-proc.
  ELSE
  DO:
    MESSAGE "There are no lines for this order.".
    PAUSE.
  END.
  RUN trailer-proc.
END.
ELSE
DO TRANSACTION:

  FIND ih_hist NO-LOCK
      WHERE ih_domain = global_domain
      AND ih_inv_nbr = inv
      AND ih_nbr = nbr NO-ERROR.

  IF AVAILABLE ih_hist THEN
  DO:

    FIND ih_hist_a
        WHERE ih_hist_a.invoice_no    =   ih_inv_nbr AND
        ih_hist_a.sls_ord       =   ih_nbr
        NO-LOCK NO-ERROR.

    IF AVAILABLE(ih_hist_a)
        THEN
    ASSIGN v_cnsgn_to   =   ih_hist_a.cnsgn_to.
    ELSE
    ASSIGN v_cnsgn_to   =   "".

    FIND ad_mstr NO-LOCK
        WHERE ad_domain = global_domain
        AND ad_addr = ih_bill NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    ASSIGN
        bill_name = ad_name.
    ELSE
    ASSIGN
        bill_name = "".

    FIND ad_mstr NO-LOCK
        WHERE ad_domain = global_domain
        AND ad_addr = ih_ship NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    ASSIGN v-shiptophone = ad_phone.
    ELSE
    v-shiptophone = "".

    FIND ad_mstr NO-LOCK
        WHERE ad_domain = global_domain
        AND ad_addr = ih_hist_a.cnsgn_to NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    ASSIGN
        cnsg_name = ad_name.
    ELSE
    ASSIGN
        cnsg_name = "".

    FIND code_mstr NO-LOCK
        WHERE code_domain = global_domain
        AND code_fldname = "cm_shipvia"
        AND code_value     = ih_shipvia NO-ERROR.
    shipv_desc         = IF AVAILABLE code_mstr THEN
    code_cmmt ELSE ""
    .

    IF ih_hist.ih_user1 = "" THEN
    DO:
      FIND cm_mstr_a WHERE cm_mstr_a.addr = ih_hist.ih_cust
          NO-LOCK NO-ERROR.
      fr_policy = IF AVAILABLE(cm_mstr_a) THEN
      cm_mstr_a.freight_policy ELSE ""
      .
    END.
    ELSE
       fr_policy = ih_hist.ih_user1.
    


    DISPLAY
        ih_inv_date
        ih_ord_date
        ih_inv_nbr
        ih_shipvia
        shipv_desc
        ih_ship_date
        ih_cr_terms
        ih_bol
        ih_userid
        ih_nbr
        fr_policy
        ih_fr_terms
        ih_slspsn[1]
        ih_slspsn[2]
        ih_slspsn[3]
        ih_slspsn[4]
        ih_po
        v_cnsgn_to
        cnsg_name
        ih_bill
        bill_name
        global_userid
        ih_stat
        ih_rmks
        WITH FRAME ihhdr.

    DISPLAY ih_cust @ so_cust WITH FRAME soldto.
    FIND ad_mstr
        WHERE ad_domain = global_domain
        AND ad_addr = ih_cust
        NO-LOCK NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    DISPLAY
        ad_name ad_line1 ad_line2 ad_city ad_state
        ad_zip ad_country
        WITH FRAME soldto.

    DISPLAY ih_ship @ so_ship WITH FRAME shipto.
    FIND ad_mstr
        WHERE ad_domain = global_domain
        AND ad_addr = ih_ship
        NO-LOCK NO-ERROR.
    IF AVAILABLE ad_mstr THEN
    DISPLAY
        ad_name ad_line1 ad_line2 ad_city ad_state
        ad_zip ad_country v-shiptophone
        WITH FRAME shipto.

  END.

  RUN comment-proc.

  v_line_flag = NO.

  FOR EACH idh_hist NO-LOCK
        WHERE idh_domain = global_domain
        AND idh_inv_nbr = ih_inv_nbr
        AND idh_nbr = ih_nbr:
    FIND pt_mstr NO-LOCK
        WHERE pt_domain = global_domain
        AND pt_part = idh_part NO-ERROR.
    ASSIGN
        desc1 = IF AVAILABLE pt_mstr THEN pt_desc1 ELSE ""
        ext_price = idh_price * idh_qty_inv
        v_line_flag = YES.
    DISPLAY
        idh_line
        idh_site
        idh_part
        desc1
        idh_qty_ord
        idh_qty_inv
        idh_price
        idh_um
        ext_price
        WITH FRAME idhdet.
    DOWN WITH FRAME idhdet.

    IF idh_cmtindx <> ?
        AND CAN-FIND (FIRST cmt_det
        WHERE cmt_domain = global_domain
        AND cmt_indx = idh_cmtindx) THEN
    DO:
      CREATE LINE.
      ASSIGN
          line_line  = idh_line
          line_site  = idh_site
          line_item  = idh_part
          line_desc  = desc1
          line_ord   = idh_qty_ord
          line_open  = idh_qty_inv
          line_price = idh_price
          line_um    = idh_um
          line_ext   = ext_price
          line_indx  = idh_cmtindx.
    END.
  END.
  IF v_line_flag THEN
  RUN line-cmmt-proc.
  ELSE
  DO:
    MESSAGE "There are no lines for this order.".
    PAUSE.
  END.
  RUN trailer-proc.
END.


PROCEDURE trailer-proc:

IF TYPE = "so" THEN
DO:
  so_recno = RECID(so_mstr).
  {gprun.i ""sosotrl.p""}
END.
ELSE
DO:
  ih_recno = RECID(ih_hist).
  {gprun.i ""soihtr1.p""}
END.

END PROCEDURE.



PROCEDURE comment-proc:

IF TYPE = "so" THEN
DO:
  FIND FIRST so_mstr
      WHERE so_domain = global_domain
      AND so_nbr = nbr
      NO-LOCK NO-ERROR.
  IF AVAILABLE (so_mstr) THEN
  DO:
    IF so_cmtindx <> ?
        AND CAN-FIND (FIRST cmt_det
        WHERE cmt_domain = global_domain
        AND cmt_indx = so_cmtindx) THEN
    DO:
      MESSAGE "View header comments for this order?" UPDATE v_cmmts.
      IF v_cmmts THEN
      DO:
        HIDE FRAME soldto.
        HIDE FRAME shipto.
        v_title = "Comments for Sales Order " + so_nbr.
        FOR EACH cmt_det
              WHERE cmt_domain = global_domain
              AND cmt_indx = so_cmtindx
              NO-LOCK:
          DISPLAY cmt_cmmt WITH FRAME cmtdet.
          PAUSE.
        END.
      END.
      HIDE FRAME cmtdet.
    END.
    ELSE
    DO:
      MESSAGE "There are no header comments for this order.".
      PAUSE.
    END.
  END.
END.
ELSE
DO:
  FIND FIRST ih_hist
      WHERE ih_domain = global_domain
      AND ih_nbr = nbr AND ih_inv_nbr = inv
      NO-LOCK NO-ERROR.
  IF AVAILABLE (ih_hist) THEN
  DO:
    IF ih_cmtindx <> ?
        AND CAN-FIND (FIRST cmt_det
        WHERE cmt_domain = global_domain
        AND cmt_indx = ih_cmtindx) THEN
    DO:
      MESSAGE "View header comments for this order?" UPDATE v_cmmts.
      IF v_cmmts THEN
      DO:
        HIDE FRAME soldto.
        HIDE FRAME shipto.
        v_title = "Comments for Sales Order " + ih_nbr.
        FOR EACH cmt_det
              WHERE cmt_domain = global_domain
              AND cmt_indx = ih_cmtindx
              NO-LOCK:
          DISPLAY cmt_cmmt WITH FRAME cmtdet.
          PAUSE.
        END.
      END.
      HIDE FRAME cmtdet.
    END.
    ELSE
    DO:
      MESSAGE "There are no header comments for this order.".
      PAUSE.
    END.
  END.
END.

END PROCEDURE. /*comment-proc*/



PROCEDURE line-cmmt-proc:

IF CAN-FIND (FIRST LINE) THEN
DO:
  MESSAGE "View line item comments for this order?" UPDATE v_cmmts.
  IF v_cmmts THEN
  DO:
    j = 0.
    CLEAR FRAME c ALL NO-PAUSE.
    FIND FIRST LINE.
    REPEAT WHILE FRAME-LINE(c) <= FRAME-DOWN(c) AND AVAILABLE LINE:
      DISPLAY line_line line_site line_item line_desc line_ord
          line_open line_price line_um line_ext WITH FRAME c.
      DOWN WITH FRAME c.
      j = j + 1.
      FIND NEXT LINE NO-ERROR.
    END.

    UP MINIMUM(FRAME-DOWN(c), j) WITH FRAME c.
    MESSAGE "Choose line to view comments.  Press F4 to leave.".

    REPEAT WITH FRAME c:
      FIND LINE WHERE line_line = INPUT line_line NO-ERROR.
      CHOOSE ROW line_line GO-ON ("cursor-down" "cursor-up"
          "page-up" "page-down") NO-ERROR.
      FIND LINE WHERE line_line = INPUT line_line NO-ERROR.

      IF KEYFUNCTION(LASTKEY) = "cursor-down" THEN
      DO:
        IF FRAME-DOWN(c) = FRAME-LINE(c) THEN
        DO:
          IF AVAILABLE LINE THEN
          FIND NEXT LINE NO-ERROR.
          IF AVAILABLE LINE THEN
          DO:
            SCROLL UP.
            DISPLAY line_line line_site line_item line_desc line_ord
                line_open line_price line_um line_ext WITH FRAME c.
          END.
        END.
        ELSE
        DOWN 1 WITH FRAME c.
      END.
      ELSE
      IF KEYFUNCTION(LASTKEY) = "cursor-up" THEN
      DO:
        IF FRAME-LINE(c) = 1 THEN
        DO:
          FIND PREV LINE NO-ERROR.
          IF AVAILABLE LINE THEN
          DO:
            SCROLL DOWN.
            DISPLAY line_line line_site line_item line_desc line_ord
                line_open line_price line_um line_ext WITH FRAME c.
          END.
        END.
        ELSE
        UP 1 WITH FRAME c.
      END.
      ELSE
      IF KEYFUNCTION(LASTKEY) = "page-down" THEN
      DO:
        DOWN FRAME-DOWN(c) - FRAME-LINE(c).
        FIND LINE WHERE line_line = INPUT line_line NO-ERROR.
        IF AVAILABLE LINE THEN
        DO j = 1 TO (FRAME-DOWN(c) - 1):
          IF AVAILABLE LINE THEN
          FIND NEXT LINE NO-ERROR.
          IF AVAILABLE LINE THEN
          DO:
            SCROLL UP.
            DISPLAY line_line line_site line_item line_desc line_ord
                line_open line_price line_um line_ext WITH FRAME c.
          END.
          ELSE
          SCROLL UP.
        END.
        UP FRAME-LINE(c) - 1.
      END.
      ELSE
      IF KEYFUNCTION(LASTKEY) = "page-up" THEN
      DO:
        UP FRAME-LINE(c) - 1.
        FIND LINE WHERE line_line = INPUT line_line NO-ERROR.
        DO j = 1 TO (FRAME-DOWN(c) - 1):
          FIND PREV LINE NO-ERROR.
          IF AVAILABLE LINE THEN
          DO:
            SCROLL DOWN.
            DISPLAY line_line line_site line_item line_desc line_ord
                line_open line_price line_um line_ext WITH FRAME c.
          END.
        END.
      END.
      ELSE
      IF KEYFUNCTION(LASTKEY) = "return" THEN
      DO:
        IF AVAILABLE LINE THEN
        DO:
          HIDE MESSAGE NO-PAUSE.
          HIDE FRAME c.
          v_title = "Comments for Line " + STRING(line_line).
          FOR EACH cmt_det
                WHERE cmt_domain = global_domain
                AND cmt_indx = line_indx NO-LOCK:
            DISPLAY cmt_cmmt WITH FRAME cmtdet.
            PAUSE.
          END.
          HIDE FRAME cmtdet.
          VIEW FRAME c.
          MESSAGE "Choose line to view comments.  Press F4 to leave.".
        END.
        ELSE
        DO WHILE (NOT AVAILABLE LINE AND FRAME-LINE(c) > 1):
          UP 1 WITH FRAME c.
          FIND LINE WHERE line_line = INPUT line_line NO-ERROR.
        END.
      END.
    END.
    HIDE MESSAGE NO-PAUSE.
  END.
  ELSE
  FOR EACH LINE:
    DELETE LINE.
  END.
END.
ELSE
DO:
  MESSAGE "There are no comments for these lines.".
  PAUSE.
END.

END PROCEDURE. /* line-cmmt-proc */
