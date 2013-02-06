DEF TEMP-TABLE tools
    FIELD fin_good AS CHAR
    FIELD prod_line AS CHAR
    FIELD child_part AS CHAR
    FIELD tool  AS CHAR FORMAT "x(30)" 
    FIELD part AS CHAR .
DEF STREAM s-out .
DEF STREAM s-in .
INPUT STREAM s-in FROM c:\temp\scheduling-cheat.csv . 
OUTPUT STREAM s-out TO c:\temp\load-tools-results.txt APPEND.

IMPORT STREAM s-in ^ . 

REPEAT :
    CREATE tools .
    IMPORT STREAM s-in DELIMITER ","  tools .
    IF tool = "" THEN UNDO, NEXT .
END.

/*add the children to the line detail for that line */
/* FOR EACH tools WHERE child_part <> fin_good .                       */
/*     IF NOT CAN-FIND(FIRST ln_mstr WHERE ln_line = prod_line AND     */
/*         ln_domain = "qp")  THEN DO:                                 */
/*         MESSAGE "Line " prod_line " does not exist. "               */
/*             VIEW-AS ALERT-BOX .                                     */
/*     END.                                                            */
/*     IF NOT CAN-FIND(FIRST lnd_det WHERE lnd_site = "02" AND         */
/*                     lnd_part = child_part AND lnd_domain = "qp" AND */
/*                     lnd_line = prod_line ) THEN DO:                 */
/*         CREATE lnd_det.                                             */
/*         ASSIGN                                                      */
/*             lnd_domain = "qp"                                       */
/*             lnd_site = "02"                                         */
/*             lnd_part = child_part                                   */
/*             lnd_line = prod_line                                    */
/*             lnd_start = TODAY .                                     */
/*         PUT STREAM s-out                                            */
/*             "lnd_det created,"                                      */
/*             child_part "," prod_line SKIP.                          */
/*     END.                                                            */
/* END.                                                                */


/* Add the tools themselves to code master */
/* DISABLE TRIGGERS FOR LOAD OF CODE_mstr .                                       */
/* FOR EACH tools BREAK BY tool.                                                  */
/*     IF NOT FIRST-OF(tool)  THEN NEXT .                                         */
/*     FIND FIRST CODE_mstr WHERE CODE_domain = "qp" AND CODE_fldname = "tool_no" */
/*           AND CODE_value = tool NO-LOCK NO-ERROR .                             */
/*     IF  AVAILABLE CODE_mstr THEN NEXT .                                        */
/*     /* If not already there add the gen code */                                */
/*     CREATE CODE_mstr .                                                         */
/*     ASSIGN                                                                     */
/*         CODE_domain = "qp"                                                     */
/*         CODE_fldname  = "tool_no"                                              */
/*         CODE_value = tool .                                                    */
/*                                                                                */
/*     PUT STREAM s-out                                                           */
/*         "code_mstr created,"                                                   */
/*         "tool_no," tool SKIP.                                                  */
/* END.                                                                           */

/*Add the tool number to the part master itself */
FOR EACH tools NO-LOCK .
    FIND FIRST pt_mstr_a WHERE pt_mstr_a.part = tools.child_part NO-ERROR.
    IF  AVAILABLE pt_mstr_a THEN DO:
        ASSIGN tool_no = tools.tool .

        PUT STREAM s-out 
            "pt_mstr changed,"
             pt_mstr_a.part "," tools.tool  SKIP.
    END.
END.
