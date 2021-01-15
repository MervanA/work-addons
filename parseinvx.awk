# simple invx vswr value parser
# all values above 1.4 will be saved in highvswr.csv file
# all values will be saved in sector_vswr.csv

BEGIN{
    OFS = ";";
    shorterdate=strftime("%y%m%d-%H",systime());
    longdate=strftime("%y%m%d-%H%M%S",systime());
    high_file = "/home/fstick/highvswr-"shorterdate".csv";
    all_file = "/home/fstick/sector_vswr-"shorterdate".csv";
}

/VSWR/{
    vlen = index($0, "VSWR")
}

/Sector\//{ 
    slen = index($0, "Sector/")
}

/VSWR/,/--+/{
    vval = substr($0, vlen, 4);
    if ( length(NN) > 5 && match(NN, "L$") != 0 ){
        sval = substr($0, slen, 7)
    }
    else{
        sval = substr($0, slen, 4)
    }
    if (vval ~ "[0-9]" ){
        print NN, sval, vval, longdate >> all_file
    }
    if (vval > 1.4 && vval ~ "[0-9]" ){
        print NN, sval, vval, longdate >> high_file
    }
}
