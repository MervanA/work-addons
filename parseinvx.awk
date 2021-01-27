# simple invx vswr/temperature value parser
# all vswr values above 1.4 will be saved in highvswr.csv file
# all temperature values above 70 will be saved in hightemp.csv
# update your path files accordingly
#
# written by MervanA@git

BEGIN	{
    FS=";";
    OFS=";";
    shorterdate=strftime("%y%m%d%H",systime());
    longdate=strftime("%y%m%d-%H%M%S",systime());
    #
    high_file_vswr = "/PATH/shared/TO/vswr_high-"shorterdate"_"ENM".csv";
    all_file_vswr = "/PATH/shared/TO/vswr_all-"shorterdate"_"ENM".csv";
    #
    high_file_temp = "/PATH/shared/TO/temp_high-"shorterdate"_"ENM".csv";
    all_file_temp = "/PATH/shared/TO/temp_all-"shorterdate"_"ENM".csv";
}


###################  TEMPERATURE CONTROL  ###################
# HEADER
# NODENAME;RadioMO;RadioNAME;SERIAL;TEMP;DATE

/TEMP/,/--+/{
    for (i=1;i<=NF;i++) {
        if($i ~/PRODUCTNUMBER/){
            f = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/FRU|MO/){
            fFRU = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/BOARD/){
            fBOARD = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/SERIAL/){
            fSERIAL = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/TEMP/){
            fTEMP = i
        }
    }
    if ($f ~ /KRC|KRD/){
        gsub(/\s.*/, "", $fFRU)
        gsub(/ /, "", $fTEMP)
        gsub(/ /, "", $fBOARD)
        gsub(/ /, "", $fSERIAL)
        # append all (sitename, board name, serial number, temperature values) as is to your log
        print NN, $fFRU, $fBOARD, $fSERIAL, $fTEMP, longdate >> all_file_temp
        # redirect above info to high temp log where all temperatures are above 70
        $intTEMP = int($fTEMP)
        if ($intTEMP > 71.00) {
            print NN, $fFRU, $fBOARD, $fSERIAL, $fTEMP, longdate >> high_file_temp
        }
    }
}


###################  VSWR CONTROL  ###################
# HEADER
# NODENAME;Sector;Cells;RadioMO;RadioNAME;RFPort;VSWR;DATE

/VSWR/,/--+/{
    for (i=1;i<=NF;i++) {
        if($i ~/LNH/){
            f = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/FRU|AuxPiu/){
            fFRU = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/BOARD/){
            fBOARD = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/RF/){
            fRF = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/VSWR/){
            fVSWR = i
        }
    }
    for (i=1;i<=NF;i++) {
        if($i ~/Sector\//){
            fSS = i
        }
    }
    if ($f ~ /0|B|f/) {
        gsub(/ /, "", $fFRU)
        gsub(/ /, "", $fBOARD)
        gsub(/ /, "", $fRF)
        gsub(/\s.*/, "", $fVSWR)
        split($fSS, fSector, " ")
        if (fSector[1] ~ /SR/) {
            vCell = sprintf("%s_%s", fSector[2], fSector[3])
            vSector = fSector[1]
        }
        else if (fSector[2] ~ /NRC/){
            vCell = fSector[2]
            vSector = fSector[1]
        }
        else if (fSector[2] ~ /AG/){
            vCell = fSector[3]
            vSector = fSector[1]
        }
        else if (fSector[1] ~ /^$/){
            vCell = "EMPTY"
            vSector = "EMPTY"
        }
        # append all (sitename, cell, sector, radio, radioname, rfport, vswr values ) as is to your log
        print NN, vCell, vSector, $fFRU, $fBOARD, $fRF, $fVSWR, longdate >> all_file_vswr
        # redirect vswr values above 1.40 to high_file_vswr
        if ($fVSWR ~ "[0-9]" && $fVSWR > 1.41) {
            print NN, vCell, vSector, $fFRU, $fBOARD, $fRF, $fVSWR, longdate >> high_file_vswr
        }
    }

}
