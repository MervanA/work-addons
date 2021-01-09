BEGIN{
#### NR-ARFCN to Frequency 
    if (OPT ~ /NRref/){
        if (ARFCN > 0 && ARFCN <= 599999){
            printf("%.2f\n", (0.005*ARFCN));
        }
        else if (ARFCN > 599999 && ARFCN <= 2016666){
            printf("%.2f\n", (3000+0.015*(ARFCN-600000)));
        }
        else if (ARFCN > 2016666 && ARFCN <= 3279165){
            printf("%.2f\n", (24250.08+0.06*(ARFCN-2016667)));
        }
    }
#### Frequency to NR-ARFCN
    if (OPT ~ /FQref/){
        if (FREQ > 0 && FREQ <= 3000){
            printf("%i\n", FREQ/0.005);
        }
        else if (FREQ > 3000 && FREQ <= 24250){
            printf("%i\n", (600000+((FREQ-3000)/0.015)));
        }
        else if (FREQ > 24250 && FREQ <= 100000){
            printf("%i\n", (2016667+((FREQ-24250.08)/0.06)));
        }
    }
}