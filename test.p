if so_partial = no and include_partial = no and
(
  (
    (
      sod_qty_ord  > 0 and
      sod_qty_all  < sod_qty_ord - sod_qty_pick - sod_qty_ship
    )  or
    (
      sod_qty_ord  < 0 and
      sod_qty_all  > sod_qty_ord - sod_qty_pick - sod_qty_ship
    )
  ) or
  (
      sod_req_date < v_req_date  or
      sod_req_date > v_req_date1 or
      sod_site     < site      or
      sod_site     > site1
  )
)
then
partial_ok = no.