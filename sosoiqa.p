/*****************************************************************************/
/*  Program Name: sosoiqa.p  (copy of sosoiq.p)                              */
/*  Descripton:  Complex SO inquiry.  Uses many different lookup comditions. */
/*               User enters selection criteria, scroll screen is shown with */
/*               all available matches, user picks an order and detailed     */
/*               info is then displayed about the lines.  Invoice history    */
/*               Also needs to be considered.                                */
/*                                                                           */
/*  Parameters:    Input                                                     */
/*                                                                           */
/*                 Output                                                    */
/*                                                                           */
/*  Input Files:   None                                                      */
/*                                                                           */
/*  Ouput Files:   None                                                      */
/*                                                                           */
/*****************************************************************************/
/* MODIFICATIONS:                                                            */
/* Date      Project     Name                    Description                 */
/* 01/14/08  eb2.1       Tomasz M.-BravePoint    Clean-up for eb2.1 upgrade  */
/*                                                                           */
/* 06/14/08  Task 63     Rob Baas                More clean up (ver 010001)  */
/*****************************************************************************/

/* DISPLAY TITLE */
{mfdtitle.i "ATR "}

DEFINE VARIABLE cust     LIKE so_cust  NO-UNDO.
DEFINE VARIABLE nbr      LIKE so_nbr   NO-UNDO.
DEFINE VARIABLE part     LIKE pt_part  NO-UNDO.
DEFINE VARIABLE qty_open LIKE sod_qty_ship LABEL "Qty Open" NO-UNDO.
DEFINE VARIABLE po       LIKE so_po    NO-UNDO.
DEFINE VARIABLE site     LIKE so_site  NO-UNDO.
DEFINE VARIABLE ord_date LIKE so_ord_date NO-UNDO.
DEFINE VARIABLE ship LIKE so_ship NO-UNDO.
DEFINE VARIABLE inv LIKE ih_inv_nbr NO-UNDO.
DEFINE VARIABLE custname LIKE cm_sort NO-UNDO.
DEFINE VARIABLE shipname LIKE cm_sort NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE j AS INTEGER NO-UNDO.
DEFINE VARIABLE create_sohdr LIKE mfc_logical NO-UNDO.
DEFINE VARIABLE create_ihhdr LIKE mfc_logical NO-UNDO.
DEFINE VARIABLE v_flag LIKE mfc_logical NO-UNDO.
DEFINE VARIABLE v_msg AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_msg2 AS CHARACTER   NO-UNDO.

DEFINE TEMP-TABLE hdr
    FIELDS hdr_nbr LIKE so_nbr
    FIELDS hdr_ord_date LIKE so_ord_date
    FIELDS hdr_cust LIKE so_cust
    FIELDS hdr_name LIKE ad_name
    FIELDS hdr_po LIKE so_po
    FIELDS hdr_inv LIKE ih_inv_nbr
    FIELDS hdr_inv_date LIKE ih_inv_date
    FIELDS hdr_type AS CHARACTER
    FIELDS hdr_stat AS CHARACTER FORMAT "x" LABEL "S"
    FIELDS hdr_sort_date LIKE so_ord_date
    INDEX hdr_idx IS UNIQUE PRIMARY hdr_nbr hdr_inv
    INDEX hdr_sort_date_nbr
    hdr_sort_date DESCENDING
    hdr_nbr DESCENDING.

FORMAT
    site COLON 13
    nbr
    ord_date
    cust COLON 13
    custname NO-LABELS
    ship COLON 13
    shipname NO-LABELS
    part COLON 13
    po
    inv COLON 13 SKIP
    WITH FRAME a SIDE-LABELS  WIDTH-CHARS 80 ATTR-SPACE.

{wbrp01.i}

REPEAT:

  IF c-application-mode <> 'web' THEN
  PROMPT-FOR site nbr ord_date cust ship part po inv
      WITH FRAME a
      EDITING:

    IF FRAME-FIELD = "site" THEN
    DO:
      /* FIND NEXT/PREVIOUS RECORD */
      {mfnp.i si_mstr site  " si_mstr.si_domain = global_domain and si_site "
          site si_site si_site}

      IF recno <> ? THEN
      DO:
        site = si_site.
        DISPLAY site WITH FRAME a.
        recno = ?.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "nbr" THEN
    DO:
      {mfnp.i so_mstr nbr so_nbr nbr so_nbr so_nbr}
      IF recno <> ? THEN
      DO:
        FIND cm_mstr NO-LOCK
            WHERE cm_domain = GLOBAL_domain
            AND cm_addr = so_cust NO-ERROR.
        custname = IF AVAILABLE cm_mstr THEN
        cm_sort ELSE ""
        .
        FIND ad_mstr NO-LOCK
            WHERE ad_domain = global_domain
            AND ad_addr = so_ship NO-ERROR.
        shipname = IF AVAILABLE ad_mstr THEN
        ad_sort ELSE ""
        .
        DISPLAY so_nbr @ nbr
            so_cust @ cust
            so_ship @ ship
            custname
            shipname
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "cust" THEN
    DO:
      {mfnp.i cm_mstr cust cm_addr cust cm_addr cm_addr}
      IF recno <> ? THEN
      DO:
        DISPLAY cm_addr @ cust
            cm_sort @ custname
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "ship" AND INPUT cust = "" THEN
    DO:
      {mfnp01.i ad_mstr ship ad_addr ad_type ""ship-to"" ad_addr}
      IF recno <> ? THEN
      DO:
        DISPLAY ad_addr @ ship
            ad_sort @ shipname
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "ship" AND INPUT cust <> "" THEN
    DO:
      {mfnp01.i ad_mstr ship ad_addr ad_ref cm_addr ad_ref}
      IF recno <> ? THEN
      DO:
        DISPLAY ad_addr @ ship
            ad_sort @ shipname
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "part" AND INPUT nbr = "" THEN
    DO:
      {mfnp.i pt_mstr part pt_part part pt_part pt_part}
      IF recno <> ? THEN
      DO:
        DISPLAY pt_part @ part
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "part" AND INPUT nbr <> "" THEN
    DO:
      {mfnp06.i sod_det sod_part "sod_nbr = input nbr"
          part sod_part part sod_part}
      IF recno <> ? THEN
      DO:
        DISPLAY sod_part @ part
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "po" THEN
    DO:
      {mfnp01.i so_mstr po so_po "input site" so_site so_po}
      IF recno <> ? THEN
      DO:
        FIND cm_mstr NO-LOCK
            WHERE cm_domain = global_domain
            AND cm_addr = so_cust NO-ERROR.
        custname = IF AVAILABLE cm_mstr THEN
        cm_sort ELSE ""
        .
        FIND ad_mstr NO-LOCK
            WHERE ad_domain = global_domain
            AND ad_addr = so_ship NO-ERROR.
        shipname = IF AVAILABLE ad_mstr THEN
        ad_sort ELSE ""
        .
        DISPLAY so_site @ site
            so_cust @ cust
            so_ship @ ship
            custname
            shipname
            so_po @ po
            WITH FRAME a.
      END.
    END.
    ELSE
    IF FRAME-FIELD = "inv" THEN
    DO:
      {mfnp.i ih_hist inv ih_inv_nbr inv ih_inv_nbr ih_inv_nbr}
      IF recno <> ? THEN
      DO:
        FIND cm_mstr NO-LOCK
            WHERE cm_domain = GLOBAL_domain
            AND cm_addr = ih_cust NO-ERROR.
        custname = IF AVAILABLE cm_mstr THEN
        cm_sort ELSE ""
        .
        FIND ad_mstr NO-LOCK
            WHERE ad_domain = GLOBAL_domain
            AND ad_addr = ih_ship NO-ERROR.
        shipname = IF AVAILABLE ad_mstr THEN
        ad_sort ELSE ""
        .
        DISPLAY ih_inv_nbr @ inv
            ih_cust @ cust
            ih_ship @ ship
            custname
            shipname
            WITH FRAME a.
      END.
    END.
    ELSE
    DO:
      READKEY.
      APPLY LASTKEY.
    END.
    global_site = INPUT site.
    global_addr = INPUT cust.
  END.  /* editing */

  ASSIGN site nbr ord_date cust ship part inv po.

  IF ord_date = ? THEN
  ord_date = low_date.

  {wbrp06.i &command = UPDATE &fields = "  site nbr ord_date cust ship po inv"
      &frm = "a"}

  FOR EACH hdr:
    DELETE hdr.
  END.
  i = 0.

  IF inv <> "" THEN
  DO:
    FOR EACH ih_hist NO-LOCK
          WHERE ih_domain = global_domain
          AND ih_inv_nbr BEGINS inv
          AND ih_site BEGINS site
          AND ih_nbr BEGINS nbr
          AND ih_cust BEGINS cust
          AND ih_ship BEGINS ship
          AND ih_ord_date >= ord_date
          AND ih_po BEGINS po:
      /*CREATE ih hdr RECORD*/
      {sosoiqb.i}
    END.
  END.
  ELSE
  IF nbr <> "" THEN
  DO:
    FOR EACH so_mstr NO-LOCK USE-INDEX so_nbr
          WHERE so_domain = global_domain
          AND so_nbr BEGINS nbr
          AND so_cust BEGINS cust
          AND so_ship BEGINS ship
          AND so_po BEGINS po
          AND so_ord_date >= ord_date
          AND so_site BEGINS site:
      /*CREATE so hdr RECORD*/
      {sosoiqa.i}
    END.
    FOR EACH ih_hist NO-LOCK USE-INDEX ih_nbr
          WHERE ih_domain = global_domain
          AND ih_nbr BEGINS nbr
          AND ih_site BEGINS site
          AND ih_cust BEGINS cust
          AND ih_ship BEGINS ship
          AND ih_ord_date >= ord_date
          AND ih_po BEGINS po:
      /*CREATE ih hdr RECORD*/
      {sosoiqb.i}
    END.
  END.
  ELSE
  IF po <> "" THEN
  DO:
    FOR EACH so_mstr NO-LOCK USE-INDEX so_po_nbr
          WHERE so_domain = global_domain
          AND so_po BEGINS po
          AND so_cust BEGINS cust
          AND so_nbr BEGINS nbr
          AND so_ship BEGINS ship
          AND so_ord_date >= ord_date
          AND so_site BEGINS site:
      /*CREATE so hdr RECORD*/
      {sosoiqa.i}
    END.
    FOR EACH ih_hist NO-LOCK USE-INDEX ih_po
          WHERE ih_domain = global_domain
          AND ih_po BEGINS po
          AND ih_cust BEGINS cust
          AND ih_nbr BEGINS nbr
          AND ih_ship BEGINS ship
          AND ih_ord_date >= ord_date
          AND ih_site BEGINS site:
      /*CREATE ih hdr RECORD*/
      {sosoiqb.i}
    END.
  END.
  ELSE
  IF cust <> "" THEN
  DO:
    FOR EACH so_mstr NO-LOCK USE-INDEX so_cust
          WHERE so_domain = global_domain
          AND so_cust BEGINS cust
          AND so_nbr BEGINS nbr
          AND so_ship BEGINS ship
          AND so_po BEGINS po
          AND so_ord_date >= ord_date
          AND so_site BEGINS site:
      /*CREATE so hdr RECORD*/
      {sosoiqa.i}
    END.
    FOR EACH ih_hist NO-LOCK USE-INDEX ih_cust
          WHERE ih_domain = global_domain
          AND ih_cust BEGINS cust
          AND ih_nbr BEGINS nbr
          AND ih_ship BEGINS ship
          AND ih_po BEGINS po
          AND ih_ord_date >= ord_date
          AND ih_site BEGINS site:
      /*CREATE ih hdr RECORD*/
      {sosoiqb.i}
    END.
  END.
  ELSE
  IF part <> "" THEN
  DO:
    FOR EACH sod_det NO-LOCK USE-INDEX sod_part
          WHERE sod_domain = global_domain
          AND sod_part BEGINS part
          AND sod_nbr BEGINS nbr,
          EACH so_mstr NO-LOCK
          WHERE so_domain = global_domain
          AND so_nbr = sod_nbr
          AND so_cust BEGINS cust
          AND so_ship BEGINS ship
          AND so_po BEGINS po
          AND so_site BEGINS site
          AND so_ord_date >= ord_date
          BREAK BY sod_nbr:
      IF FIRST-OF(sod_nbr) THEN
      DO:
        FIND ad_mstr NO-LOCK
            WHERE ad_domain = global_domain
            AND ad_addr = so_cust NO-ERROR.
        CREATE hdr.
        ASSIGN hdr_nbr = so_nbr
            hdr_ord_date = so_ord_date
            hdr_sort_date = so_ord_date
            hdr_cust = so_cust
            hdr_name = IF AVAILABLE ad_mstr
            THEN ad_sort ELSE ""
            hdr_po = so_po
            hdr_type = "so"
            hdr_stat = "O"
            i = i + 1.
      END.
    END.
    FOR EACH idh_hist NO-LOCK USE-INDEX idh_part
          WHERE idh_domain = global_domain
          AND idh_part BEGINS part
          AND idh_nbr BEGINS nbr,
          EACH ih_hist NO-LOCK
          WHERE ih_domain = global_domain
          AND ih_inv_nbr = idh_inv_nbr
          AND ih_nbr = idh_nbr
          AND ih_cust BEGINS cust
          AND ih_ship BEGINS ship
          AND ih_po BEGINS po
          AND ih_site BEGINS site
          AND ih_ord_date >= ord_date
          BREAK BY idh_inv_nbr BY idh_nbr:
      IF FIRST-OF(idh_inv_nbr) THEN
      DO:
        FIND ad_mstr NO-LOCK
            WHERE ad_domain = global_domain
            AND ad_addr = ih_cust NO-ERROR.
        FIND so_mstr NO-LOCK
            WHERE so_domain = global_domain
            AND so_nbr = ih_nbr NO-ERROR.
        CREATE hdr.
        ASSIGN hdr_nbr = ih_nbr
            hdr_inv = ih_inv_nbr
            hdr_ord_date = ih_ord_date
            hdr_sort_date = ih_inv_date
            hdr_cust = ih_cust
            hdr_name = IF AVAILABLE ad_mstr
            THEN ad_sort ELSE ""
            hdr_po = ih_po
            hdr_inv_date = ih_inv_date
            hdr_type = "ih"
            hdr_stat = IF AVAILABLE so_mstr THEN "O"
            ELSE "C"
            i = i + 1.
      END.
    END.
  END.
  ELSE
  IF (ship <> "" AND ord_date <> ?) THEN
  DO:
    FOR EACH so_mstr NO-LOCK USE-INDEX so_nbr
          WHERE so_domain = global_domain
          AND so_nbr BEGINS nbr
          AND so_cust BEGINS cust
          AND so_ship BEGINS ship
          AND so_po BEGINS po
          AND so_ord_date >= ord_date
          AND so_site BEGINS site:
      /*CREATE so hdr RECORD*/
      {sosoiqa.i}
    END.
    FOR EACH tr_hist NO-LOCK USE-INDEX tr_type
          WHERE tr_domain = global_domain
          AND tr_type = "ORD-SO"
          AND tr_effdate >= ord_date,
          EACH ih_hist NO-LOCK USE-INDEX ih_nbr
          WHERE ih_domain = global_domain
          AND ih_nbr = tr_nbr
          AND ih_site BEGINS site
          AND ih_cust BEGINS cust
          AND ih_ship BEGINS ship
          AND ih_ord_date >= ord_date
          AND ih_po BEGINS po:
      IF NOT CAN-FIND(FIRST hdr WHERE hdr_nbr = ih_nbr
          AND hdr_inv = ih_inv_nbr)
          THEN
      DO:
        /*CREATE ih hdr RECORD*/
        {sosoiqb.i}
      END.
    END.
  END.
  ELSE
  DO:
    v_msg = "ADDITIONAL SEARCH CRITERIA NEEDED".
    {pxmsg.i  &MSGTEXT=v_msg
        &ERRORLEVEL=3}
    NEXT.
  END.

  IF i = 0 THEN
  DO:
    v_msg2 = "ENTERIES RESULT IN NO MATCHING ORDERS".
    {pxmsg.i  &MSGTEXT=v_msg2
        &ERRORLEVEL=3}
    NEXT.
  END.

  /*CHOOSE ROUTINE*/
  FORMAT
      hdr_nbr
      hdr_inv
      hdr_ord_date COLUMN-LABEL "Ord/Inv"
      hdr_cust
      hdr_name
      hdr_po LABEL "PO" FORMAT "x(11)"
      hdr_stat
      WITH FRAME b WIDTH-CHARS 80 16 DOWN NO-ATTR-SPACE.

  CLEAR FRAME b ALL NO-PAUSE.

  i = 0.
  FIND FIRST hdr USE-INDEX hdr_sort_date_nbr NO-ERROR.
  REPEAT WHILE FRAME-LINE(b) <= FRAME-DOWN(b) AND AVAILABLE hdr:
    DISPLAY hdr_nbr hdr_inv hdr_cust
        hdr_name hdr_po hdr_stat WITH FRAME b.
    IF hdr_type = "so" THEN
    DISPLAY hdr_ord_date WITH FRAME b.
    ELSE
    DISPLAY hdr_inv_date @ hdr_ord_date WITH FRAME b.
    DOWN WITH FRAME b.
    i = i + 1.
    FIND NEXT hdr USE-INDEX hdr_sort_date_nbr NO-ERROR.
  END.

  UP MINIMUM(FRAME-DOWN(b),i) WITH FRAME b.

  scroll_rpt:
  REPEAT WITH FRAME b:
    VIEW FRAME b.

    FIND hdr
        WHERE hdr_nbr = INPUT hdr_nbr
        AND hdr_inv = INPUT hdr_inv NO-ERROR.
    IF AVAILABLE hdr AND hdr_po <> "" THEN
    MESSAGE "PO: " hdr_po.
    ELSE
    IF FRAME-DOWN(b) <> FRAME-LINE(b) THEN
    HIDE MESSAGE NO-PAUSE.

    CHOOSE ROW hdr_nbr GO-ON ("cursor-down" "cursor-up"
        "page-down" "page-up")
        NO-ERROR.
    FIND hdr WHERE hdr_nbr = INPUT hdr_nbr
        AND hdr_inv = INPUT hdr_inv NO-ERROR.

    IF KEYFUNCTION(LASTKEY) = "cursor-down" THEN
    DO:
      IF FRAME-DOWN(b) = FRAME-LINE(b) THEN
      DO:
        IF AVAILABLE hdr THEN
        FIND NEXT hdr USE-INDEX hdr_sort_date_nbr
            NO-LOCK NO-ERROR.
        IF AVAILABLE hdr THEN
        DO:
          SCROLL UP.
          DISPLAY hdr_nbr hdr_inv hdr_cust
              hdr_name hdr_po hdr_stat.
          IF hdr_type = "so" THEN
          DISPLAY hdr_ord_date.
          ELSE
          DISPLAY hdr_inv_date @ hdr_ord_date.
        END.
        ELSE
        DO:
          HIDE MESSAGE NO-PAUSE.
          {mfmsg.i 20 2}  /*END OF FILE*/
        END.
      END.
      ELSE
      DO:
        DOWN 1.
      END.
    END.
    ELSE
    IF KEYFUNCTION(LASTKEY) = "cursor-up" THEN
    DO:
      IF FRAME-LINE(b) = 1 THEN
      DO:
        FIND PREV hdr USE-INDEX hdr_sort_date_nbr
            NO-LOCK NO-ERROR.
        IF AVAILABLE hdr THEN
        DO:
          SCROLL DOWN.
          DISPLAY hdr_nbr hdr_inv hdr_cust
              hdr_name hdr_po hdr_stat.
          IF hdr_type = "so" THEN
          DISPLAY hdr_ord_date.
          ELSE
          DISPLAY hdr_inv_date @ hdr_ord_date.
        END.
        ELSE
        DO:
          HIDE MESSAGE NO-PAUSE.
          {mfmsg.i 21 2}  /*BEGINNING OF FILE*/
        END.
      END.
      ELSE
      DO:
        UP 1.
      END.
    END.
    ELSE
    IF KEYFUNCTION(LASTKEY) = "page-down" THEN
    DO:
      v_flag = FALSE.
      DOWN FRAME-DOWN(b) - FRAME-LINE(b).
      FIND hdr WHERE hdr_nbr = INPUT hdr_nbr
          AND hdr_inv = INPUT hdr_inv NO-ERROR.
      IF NOT AVAILABLE hdr THEN
      v_flag = TRUE.
      ELSE
      DO j = 1 TO (FRAME-DOWN(b) - 1):
        IF AVAILABLE hdr THEN
        FIND NEXT hdr USE-INDEX hdr_sort_date_nbr
            NO-LOCK NO-ERROR.
        IF AVAILABLE hdr THEN
        DO:
          SCROLL UP.
          DISPLAY hdr_nbr hdr_inv hdr_cust
              hdr_name hdr_po hdr_stat.
          IF hdr_type = "so" THEN
          DISPLAY hdr_ord_date.
          ELSE
          DISPLAY hdr_inv_date @ hdr_ord_date.
        END.
        ELSE
        DO:
          SCROLL UP.
          v_flag = TRUE.
        END.
      END.
      UP FRAME-LINE(b) - 1.
      IF v_flag THEN
      DO:
        HIDE MESSAGE NO-PAUSE.
        {mfmsg.i 20 2}  /*END OF FILE*/
      END.
    END.
    ELSE
    IF KEYFUNCTION(LASTKEY) = "page-up" THEN
    DO:
      v_flag = FALSE.
      UP FRAME-LINE(b) - 1.
      FIND hdr WHERE hdr_nbr = INPUT hdr_nbr
          AND hdr_inv = INPUT hdr_inv NO-ERROR.
      DO j = 1 TO (FRAME-DOWN(b) - 1):
        FIND PREV hdr USE-INDEX hdr_sort_date_nbr
            NO-LOCK NO-ERROR.
        IF AVAILABLE hdr THEN
        DO:
          SCROLL DOWN.
          DISPLAY hdr_nbr hdr_inv hdr_cust
              hdr_name hdr_po hdr_stat.
          IF hdr_type = "so" THEN
          DISPLAY hdr_ord_date.
          ELSE
          DISPLAY hdr_inv_date @ hdr_ord_date.
        END.
        ELSE
        v_flag = TRUE.
      END.
      IF v_flag THEN
      DO:
        HIDE MESSAGE NO-PAUSE.
        {mfmsg.i 21 2}  /*BEGINNING OF FILE*/
      END.
    END.
    ELSE
    IF KEYFUNCTION(LASTKEY) = "return"
        AND AVAILABLE hdr THEN
    DO:
      HIDE MESSAGE NO-PAUSE.
      {gprun.i ""sosoiq1.p"" "(hdr_nbr, hdr_inv, hdr_type)"}
      PAUSE.
    END.
  END.   /*scroll_rpt*/
  
  HIDE MESSAGE NO-PAUSE.

END.  /* repeat */

{wbrp04.i &frame-spec = a}

