

OUTPUT TO c:\temp\buyer-planner-change.txt .

DISABLE TRIGGERS FOR LOAD OF pt_mstr .
DISABLE TRIGGERS FOR LOAD OF ptp_det . 


RUN p-update("gc","ry") .

RUN p-update("dj","rw") .



PROCEDURE p-update.
    DEF INPUT PARAMETER v_old_buyer AS CHAR.
    DEF INPUT PARAMETER  v_new_buyer  AS CHAR.
    FOR EACH pt_mstr WHERE pt_domain = "qp" 
        AND pt_buyer = v_old_buyer .
        PUT "pt_mstr prev buyer " v_old_buyer " changed to " v_new_buyer 
            " for part " pt_part SKIP.

        pt_buyer = v_new_buyer .

        FOR EACH ptp_det WHERE ptp_domain = "qp" AND ptp_part = pt_part .
            PUT 
                "ptp_det site " ptp_site " changed from " ptp_buyer 
                " to " v_new_buyer SKIP .

            ptp_buyer = v_new_buyer .
        END.
    END.
END PROCEDURE .
