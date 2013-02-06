FOR EACH cpr_mstr WHERE cpr_status <> "closed" NO-LOCK .
    FOR EACH cprpd_det WHERE cprpd_nbr = cpr_nbr .
        ASSIGN
        cprpd_prime_rsn = cpr_prime_rsn
            cprpd_sec_rsn = cpr_sec_rsn
            cprpd_rinse_temp = cpr_rinse_temp
            cprpd_rinse_add = cpr_rinse_add
            cprpd_detergent  = cpr_detergent  
            .
    END.
END.
