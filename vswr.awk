"simple ReturnLoss to VSWR awk script, limited to Units with Active RF branch"
BEGIN{
    printf "\033[0;34m%-10s %-10s %s\033[0m\n", "RADIO", "RFPort", "VSWR";
}
$1 ~ /^F/ {
    unit=gensub(/FieldReplaceableUnit=/,"",1,$1);
    radio=gensub(/,.*/,"",1,unit);
    port=gensub(/.*,/,"",1,unit);
    if ($2 ~ /^$/){
        vswr="---";
    }
    else{
        vswr=(1+10^(-$2/20))/(1-10^(-$2/20));
    }
    if ($2 ~ /^$/)
        printf("\033[2;31m%-10s %-10s %s %s\033[0m\n", radio, port, vswr, "verify");
    else if (vswr < "1.39")
        printf("%-10s %-10s \033[1;32m%.2f\033[0m\n", radio, port, vswr);
    else if (vswr > "1.39")
        printf("%-10s %-10s \033[4;31m%.2f %s\033[0m\n", radio, port, vswr, "NOK");
    }
