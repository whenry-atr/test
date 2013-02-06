/* xxtxcalc.p - CALCULATE TAX FOR A TRANSACTION                            */
/* COPYRIGHT qad.inc. ALL RIGHTS RESERVED. THIS IS AN UNPUBLISHED WORK.    */
/*F0PN*/ /*V8:ConvertMode=Maintenance                                      */
/*J2D9*/ /*V8:WebEnabled=No                                                 */
/***************************************************************************/
/*!
Modification History
-----------------------------------------------------------------------------
PATCH: EZ0364     DATE: 07/30/99    REQUESTOR: glm      PROGRAMMER: jzj
Modif: CA501325   DATE: 10/08/02                        PROGRAMMER: rsh
DESCRIPTION:                                        
New utility to re-post invoice history to Vertex register database.        
Base logic copied from txcalc.p.  Changes indicated with EZ0364.
=============================================================================
!*/
/*!
    txcalc.p    qad Calculate Tax For a Transaction

*/
/*!
        receives the following parameters
    I/O     Name          Like            Description
    -----   -----------   --------------- ------------------------------
    input   tr_type       tx2d_tr_type    Transaction Type Code
    input   ref           tx2d_ref        Document Reference
    input   nbr           tx2d_nbr        Number (Related Document)
    input   line          tx2d_line       Line Number /* 0 = ALL */

    input   vq-post       logical         Register Post flag
    output  result-status integer         Result Status

    Transaction types supported are:
    16  AR Invoice
*/
/***************************************************************************/
/*J2D9* GROUPED MULTIPLE FIELD ASSIGNMENTS INTO ONE AND ADDED no-undo
 WHEREVER MISSING FOR PERFORMANCE AND SMALLER R-CODE */

         {mfdeclre.i}

         define input parameter tr_type   like tx2d_tr_type no-undo.
         define input parameter ref       like tx2d_ref no-undo.
         define input parameter nbr       like tx2d_nbr no-undo.
/*H509*/ define input parameter line      like tx2d_line no-undo.

  /*PLEASE DO NOT INTRODUCE ANYTHING HERE. THIS PROGRAM CALLS THE
       INCLUDE FILE TXCALDEF.I WHICH IN TURN CALLS TXCALCIO.I. THE INPUT
       PARAMETER VQ-POST AND THE OUTPUT PARAMETER RESULT-STATUS ARE
           DEFINED IN TXCALCIO.I.
       IF WE INTRODUCE ANYTHING BETWEEN THESE TWO LINES, THE ORDER IN
       WHICH THE PARAMETERS ARE DEFINED WILL BE LOST.
           ******************************************************************/
/*H138*/ {txcaldef.i "NEW"}

 define variable actual_tr_type like tx2d_tr_type no-undo.


    assign
         actual_tr_type = tr_type
         txc_tr_type    = tr_type
         txc_ref        = ref
         txc_nbr        = nbr
         txc_line       = line.


/* CALCULATION OF THE TAX LINE ITEMS IS HANDLED IN A SUBPROCEDURE FOR THE   */
/* SPECIFIC TR_TYPE.  ALL SUBPROCEDURES UTILIIZE TXCALCA.I FOR DETAIL CALC. */

 /* AR INVOICE (16) TRANSACTION TYPE (USING INVOICE HISTORY) */
 if (tr_type = "16") then do transaction:
    /* CALL PROCEDURE TO LOOP THROUGH LINE ITEMS */
    /* ADDED INPUT PARAM VQ-POST, OUTPUT PARAM RESULT-STATUS */
/*EZ0364*/  {gprun.i ""xxcalc16.p""
        "(input vq-post, output result-status)"}
 end.

/*J0WF*/ /* END CALL INVOICES (38) */
   /****************************************************************
 *         CHECK IF THERE HAS BEEN AN ERROR. IF SO, REPORT TO THE USER
 *         ****************************************************************/
   if result-status <> 0 then
           do:
     if not vq-post then
     do:
       {mfmsg.i 2013 2}
       /* QUANTUM STATUS 160. UNEXPECTED RESULT IN TAX CALCULATIONS*/
     end. /* if not vq-post ... */
   end. /* if result-status <> 0 ... */
