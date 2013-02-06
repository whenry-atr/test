form "@(#) fcs_load.p 1.4 98/05/28 " with frame sccs-id.
/*****************************************************************************/
/*  Program Name:  fcs_load.p                                                */
/*  Descripton:    Loads the forecast summary table from flat files          */
/*                 where site = "L" for lamp and "=" for all others          */
/*                 in character position 6 through 20 of input file          */
/*                 The above site determination was changed to use the       */
/*                 site code in the part master.                             */
/*                                                                           */
/*  Parameters:    Input                                                     */
/*                                                                           */
/*                 Output                                                    */
/*                                                                           */
/*  Input Files:   fcstlamp.txt - for lamp                                   */
/*                 fcstalad.txt - all others                                 */
/*                 NOTE:  some parts may be in both files so beware          */
/*                                                                           */
/*  Ouput Files:   fcstlamp.bck.yymmdd.hhmm  before image of forecast record */
/*                 fcstalad.bck.yymmdd.hhmm                                  */
/*                 fcstlamp.log.yymmdd.hhmm  significate information         */
/*                 fcstalad.log.yymmdd.hhmm                                  */
/*                 fcstlamp.fcs.yymmdd.hhmm  renamed forecast file           */
/*                 fcstalad.fcs.yymmdd.hhmm                                  */
/*****************************************************************************/
/* MODIFICATIONS:                                                            */
/* Rev #  Name              Date        Description                          */
/*****************************************************************************/
/*                                                                           */
/* 1.1    R. O. Francis     01/22/98    Changed site determination           */
/* 1.0    R. O. Francis     01/20/98    Created                              */
/*****************************************************************************/

{mfdeclre.i new }

def var v_inbuff as char format "x(80)"   no-undo.
def var v_i      as integer               no-undo.

def var v_site   like fcs_site            no-undo.
def var v_year   like fcs_year            no-undo.
def var v_part   like fcs_part            no-undo.
def var v_qty    like fcs_fcst_qty extent 0 no-undo.
def var v_date     as  date                no-undo.
def var v_str      as  char                no-undo.
def var v_wk       as  integer             no-undo.
def var v_curr_wk  as  integer             no-undo.
def var v_curr_yr  as  integer             no-undo.

def var v_infile1  as  char                no-undo.
def var v_datetime as  char                no-undo.
def var v_time     as  char                no-undo.
def var v_outfile1 as  char                no-undo.
def var v_outfile2 as  char                no-undo.
def var v_outfile3 as  char                no-undo.
def var v_cmd      as  char format "x(255)" no-undo.

def stream in1.
def stream out1.
def stream out2.

put skip "Forecast Load Started at: "
         string(today,"99/99/99") " " string(time, "HH:MM").

v_infile1   = session:parameter.

if index(v_infile1, ".") = 0
then do:
  put unformatted skip "Invalid input file name: " v_infile1. 
  leave.
end.

v_time = string(time,"HH:MM").
v_datetime = "." + substring(string(year(today), "9999"), 3, 2)
           + string(month(today), "99") + string(day(today), "99")
           + "." + substring(v_time,1,2) + substring(v_time,4,2).
           
v_outfile1  = entry(1,v_infile1, ".") + ".bck".
v_outfile2  = entry(1,v_infile1, ".") + ".fcs".
v_outfile3  = entry(1,v_infile1, ".") + ".log".

/* clean up old forecast records */
v_curr_yr = year(today).

{fcsdate2.i today v_curr_wk}
 
for each fcs_sum exclusive-lock use-index fcs_yearpart
                 where fcs_year = v_curr_yr:
  do v_i = 1 to  v_curr_wk:
    fcs_fcst_qty[v_i] = 0.
    fcs_sold_qty[v_i] = 0.
    fcs_abnormal[v_i] = 0.
    fcs_pr_fcst[v_i]  = 0.
  end.
end.

if (v_curr_wk - 1) <= 0 then do:
  for each fcs_sum exclusive-lock use-index fcs_yearpart
                   where fcs_year = (v_curr_yr - 1):
    do v_i = 1 to  52:
      fcs_fcst_qty[v_i] = 0.
      fcs_sold_qty[v_i] = 0.
      fcs_abnormal[v_i] = 0.
      fcs_pr_fcst[v_i]  = 0.
    end.
  end.
end.

input stream in1 from value(v_infile1).
output stream out1 to value(v_outfile2).
output stream out2 to value(v_outfile3).

repeat:
  import stream in1 delimiter "^" v_inbuff.
  v_part = substring(v_inbuff,1,5).
  v_str  = substring(v_inbuff,6,14).
  v_qty  = decimal(substring(v_inbuff,21,8)).
  v_date = date(integer(substring(v_inbuff,30,2)),
                integer(substring(v_inbuff,32,2)),
                (if (integer(substring(v_inbuff,34,2)) > 50)
                 then (integer(substring(v_inbuff,34,2)) + 1900)
                 else (integer(substring(v_inbuff,34,2)) + 2000))
               ).

 if ( v_date < today ) then next.  /* ignore records with a monday date */
                                   /* older than the current date       */
                                 
 /* v_site = if (index(v_str, "L") <> 0) then  "01" else "02". */

  v_year = year(v_date).

  find first pt_mstr where pt_part = v_part
                       exclusive-lock no-error.
  if available(pt_mstr) then do:
    {fcsdate2.i v_date v_wk}
    v_site = pt_site.
    find first fcs_sum where fcs_site = v_site
                         and fcs_year = v_year
                         and fcs_part = v_part
                         exclusive-lock no-error.
    if not available(fcs_sum) then
    do:
      create fcs_sum.
      assign fcs_site = v_site
             fcs_year = v_year
             fcs_part = v_part.
      put stream out2 unformatted
          skip "Created new forecast record for part: "
          v_part " Site: " v_site " year: " v_year.
    end.
    export stream out1 skip v_site v_year v_part v_wk fcs_fcst_qty[v_wk].
    assign fcs_fcst_qty[v_wk] = v_qty.
    pt_mrp = yes.
  end.
  else do:
    put stream out2 unformatted
        skip "No such part in the pt_mstr " v_site " " v_part.
  end.
end.
input stream in1 close.
output stream out1 close.
output stream out2 close.
unix silent mv value(v_infile1) value(v_outfile1 + v_datetime).
unix silent mv value(v_outfile2) value(v_outfile2 + v_datetime).
unix silent mv value(v_outfile3) value(v_outfile3 + v_datetime).
unix silent chmod 666 value(entry(1,v_infile1,".") + ".*" ).
v_cmd = "find /all/mfgpro/gpdir -name '"
      + v_outfile1 + ".*' -mtime +30 -exec rm {} ~\;".
unix silent value(v_cmd).
v_cmd = "find /all/mfgpro/gpdir -name '"
      + v_outfile2 + ".*' -mtime +30 -exec rm {} ~\;".
unix silent value(v_cmd).
v_cmd = "find /all/mfgpro/gpdir -name '"
      + v_outfile3 + ".*' -mtime +30 -exec rm {} ~\;".
unix silent value(v_cmd).
put skip "Forecast Load Completed Successfully at: "
         string(today,"99/99/99") " " string(time, "HH:MM").
