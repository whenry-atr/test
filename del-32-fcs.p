
DEF VAR v_i AS INTEGER .

DISABLE TRIGGERS FOR LOAD OF fcs_sum .

OUTPUT TO c:\temp\fcs_sum.txt .

for each fcs_sum EXCLUSIVE-LOCK use-index fcs_yearpart
                 where fcs_year = 2011 AND fcs_site = "32" :
EXPORT fcs_sum . 
  do v_i = 1 to  52:
    fcs_fcst_qty[v_i] = 0.
    fcs_sold_qty[v_i] = 0.
    fcs_abnormal[v_i] = 0.
    fcs_pr_fcst[v_i]  = 0.
  end.
end.


for each fcs_sum EXCLUSIVE-LOCK use-index fcs_yearpart
                 where fcs_year = 2012 AND fcs_site = "32" :
    EXPORT fcs_sum .
  do v_i = 1 to  52:
    fcs_fcst_qty[v_i] = 0.
    fcs_sold_qty[v_i] = 0.
    fcs_abnormal[v_i] = 0.
    fcs_pr_fcst[v_i]  = 0.
  end.
 end.                   
