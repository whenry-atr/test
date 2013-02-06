def var sonbr         like so_nbr                                     no-undo.
def var sonbr1        like so_nbr                                     no-undo.
def var v_site        like so_site                                    no-undo.
def var v_site1       like so_site                                    no-undo.
def var v_date        like sod_req_date                               no-undo.
def var v_date1       as   date                                       no-undo.

def var t_site        like so_site                                    no-undo.
def var v_timestamp   as char    label "TimeStamp"  format "x(12)"    no-undo.
def var v_case_no     as integer                                      no-undo.
def var v_i           as integer                                      no-undo.
def var v_j           as integer                                      no-undo.
def var v_k           as integer                                      no-undo.
def var v_down_loc    like sod_loc                                    no-undo.
def var v_down_file   as character                                    no-undo.
def var v_rpt_file    as character                                    no-undo.
def var v_down_dir    as character                                    no-undo.
def var v_down_list   as character                                    no-undo.
def var v_down_lock   as logical                                      no-undo.
DEF VAR vx_desc   AS CHARACTER FORMAT "X(50)" NO-UNDO. 
DEF VAR vx_desc1   AS CHARACTER FORMAT "X(50)" NO-UNDO. 
DEF VAR vx_desc2   AS CHARACTER FORMAT "X(50)" NO-UNDO. 
DEF VAR vx_desc3   AS CHARACTER FORMAT "X(50)" NO-UNDO. 
DEF VAR vx_desc4   AS CHARACTER FORMAT "X(50)" NO-UNDO. 
DEF VAR vx_desc5   AS CHARACTER FORMAT "X(50)" NO-UNDO. 
DEF VAR v_shipv1 LIKE so_shipvia NO-UNDO.  
DEF VAR v_shipv2 LIKE so_shipvia NO-UNDO.  
DEF VAR v_shipv3 LIKE so_shipvia NO-UNDO.  
DEF VAR v_shipv4 LIKE so_shipvia NO-UNDO.  
DEF VAR v_shipv5 LIKE so_shipvia NO-UNDO.  
DEF VAR GLOBAL_domain AS CHAR .

ASSIGN
    sonbr1 = "9999999" 
    GLOBAL_domain = "qp" 
    v_site1 = "hm" 
    v_date = TODAY 
    v_shipv2 = "107" 
    v_shipv3 = "113" .





    for each so_mstr no-lock where so_domain = global_domain 
                             AND so_mstr.so_nbr >= sonbr
                             and so_mstr.so_nbr <= sonbr1
                             and so_mstr.so_stat = ""
                             and (not can-find(first sod_det
                                  where sod_domain = global_domain
                                    AND sod_nbr = so_nbr
                                    and sod_line = 1
                                    and sod_type = "M")
                                 ),
      first so_mstr_a no-lock where so_mstr_a.sls_ord =  so_mstr.so_nbr
                                and so_mstr_a.shiptec = no,
      each sod_det no-lock where sod_domain = global_domain 
                     AND sod_det.sod_nbr = so_mstr.so_nbr
                     and sod_det.sod_confirm = yes
                     and sod_det.sod_type <> "M"   /* 1.55 */

         /* SELECTION CRITERIA FOR SALES ORDERS OTHER THAN SPECIAL MARKETS */

                and (
                          (
                            (v_site1 <> "SM") and (v_site1 <> "04")
                               and (sod_det.sod_req_date <= v_date)
                               

                              and (
                                   ((v_site1 = "01") and (sod_site = "01"))
                                or
                                   (
                                      (
                                         (v_site1 = "HM")
                                        and (
                                              (so_site = "HS") or (so_site = "HM")
                                              or (so_site = "CA")
                                              OR (sod_site = "02")
                                            )
                                       and (sod_site = "02") or (sod_site = "22")
                                      )

                                       and (sod_loc <> "EAGLE")
                                       and (sod_loc <> "ar999")) or  /* 1.50 */
                                      (
                                        (v_site1 = "02") and (sod_site = "02")
                                         and (sod_loc <> "B252")
                                      )
                                   )
                            and (
                                    (sod_det.sod_qty_pick <> 0)
                                       or (
                                           (
                                             (sod_qty_ord
                                              - (sod_qty_pick + sod_qty_ship)
                                             ) > 0
                                            )
                                         and can-find( first sod_det
                                        where sod_domain = global_domain
                                         AND  sod_nbr = so_nbr
                                          and sod_qty_pick <> 0)
                                    )
                                )

                          )

        /* START OF SPECIAL MARKETS (SM) NASHVILLE SELECTION CRITERIA */

                          OR
                          ( (v_site1 = "SM")
                            and ((sod_site = "02") and (sod_loc = "B252"))
                            and (sod_qty_ord <> 0)
                            and (sod_qty_ord  >  sod_qty_ship)
                          )

        /* START OF SPECIAL MARKETS (SM) MEXICO SELECTION CRITERIA */

                          OR
                          ( (v_site1 = "04")
                            and ((sod_site = "04") and (sod_loc = "B252"))
                            and (sod_qty_ord <> 0)
                            and (sod_qty_ord  >  sod_qty_ship)
                          )

        /* START OF MAIL ORDER SELECTION CRITERIA */

                          OR
                          ( (v_site1 = "02")
                            and (sod_det.sod_req_date <= v_date)
                            and (sod_site = "02")
                            and (so_project <> "S14")
                            and (so_channel <> "S14")
                            and ((sod_loc = "M999") OR (sod_loc = "EP999"))
                            and (sod_qty_ord <> 0)
                            and (sod_qty_ord  >  sod_qty_ship)
                          )

                         )

        ,
      first pt_mstr no-lock where pt_domain = global_domain
            AND pt_mstr.pt_part = sod_det.sod_part,
      first pt_mstr_a no-lock where pt_mstr_a.part = pt_mstr.pt_part,
      first cm_mstr no-lock where cm_domain = global_domain
            AND cm_addr = so_mstr.so_cust
      break by sod_nbr by sod_line
        :

      /*if there is at least one ship via selection that is not blank*/
      IF (
          (
          v_shipv1 <> "" OR
          v_shipv2 <> "" OR
          v_shipv3 <> "" OR
          v_shipv4 <> "" OR
          v_shipv5 <> ""
                        )
         AND
          (
              so_shipvia <> v_shipv1 AND
              so_shipvia <> v_shipv2 AND
              so_shipvia <> v_shipv3 AND
              so_shipvia <> v_shipv4 AND
              so_shipvia <> v_shipv5 )
              )
          THEN NEXT .

 DISPLAY sod_nbr sod_line so_shipvia. PAUSE 0 . 
