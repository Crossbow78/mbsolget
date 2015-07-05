# This file contains export routines

#SQL routines
fill_sql() {
  if (( USE_MYSQL )); then
    echo -e "INSERT INTO verbruik (dt1, tarief, kwh_msvtl, kwh_msvtl_v, kwh_msvth, kwh_msvth_v, kwh_msvtot, kwh_vtot, kwh_msttl, kwh_msttl_v, kwh_mstth, kwh_mstth_v, kwh_msttot, kwh_ttot, kw_hv, kw_ht, kw_tot, m3_msvgas, m3_msvgas_v, dt2, kw_msvtl_v, kw_msvth_v, kw_msttl_v, kw_mstth_v, dm3_msvgas_v, dt3)" >> $SQL
    echo -e "     VALUES ('""$NOWDATE" "$NOWTIME""','"${store[0]}"','"${store[1]}"','"${store[2]}"','"${store[3]}"','"${store[4]}"','"${store[5]}"','"${store[6]}"','"${store[7]}"','"${store[8]}"','"${store[9]}"','"${store[10]}"','"${store[11]}"','"${store[12]}"','"${store[13]}"','"${store[14]}"','"${store[15]}"','"${store[16]}"','"${store[17]}"','"${store[18]}"','"${store[19]}"','"${store[20]}"','"${store[21]}"','"${store[22]}"','"${store[23]}"','"${store[24]}"');\r" >> $SQL
  fi
}


#CSV routines
create_csv() {
  if (( USE_CSV )); then
    echo -e "sep=; \r" >> $CSVFILE
    echo -e " \r" >> $CSVFILE
    echo -e ";Export waarden voor electricteit verbruik \r" >> $CSVFILE
    echo -e ";Bestand aangemaakt met : mbsolget_p1 \r" >> $CSVFILE
    echo -e " \r" >> $CSVFILE
    echo -e ";;Verbruik;;;;;;Teruglevering;;;;;;Huidig;;;Verbruik;;Teruglevering;; \r" >> $CSVFILE
    echo -e "Datum en tijd;Tarief;kWh Laag;kWh Laag;kWh Hoog;kWh Hoog;kWh Totaal;kWh Totaal;kWh Laag;kWh Laag;kWh Hoog;kWh Hoog;kWh Totaal;kWh Totaal;kW Verbruik;kW Terug;kW Totaal;W;W;W;W;Gas meterstand m3;m3;dm3;tijd laatste meting \r" >> $CSVFILE
    echo -e ";0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;19;20;21;22;16;17;23;18;; \r" >> $CSVFILE
  fi
  chmod 777 $CSVFILE 
}

fill_csv() {
  if (( USE_CSV )); then
    if [ ! -f $CSVFILE ]
	then
	  create_csv
	fi
    echo -e $NOWDATE" "$NOWTIME";"${store[0]}";"${store[1]/./,}";"${store[2]/./,}";"${store[3]/./,}";"${store[4]/./,}";"${store[5]/./,}";"${store[6]/./,}";"${store[7]/./,}";"${store[8]/./,}";"${store[9]/./,}";"${store[10]/./,}";"${store[11]/./,}";"${store[12]/./,}";"${store[13]/./,}";"${store[14]/./,}";"${store[15]/./,}";"${store[19]/./,}";"${store[20]/./,}";"${store[21]/./,}";"${store[22]/./,}";"${store[16]/./,}";"${store[17]/./,}";"${store[23]/./,}";"${store[18]}";"$ErrorStr";END;""\r" >> $CSVFILE
  fi
}



#XML routines
fill_xml() {
  if (( USE_XML )); then
    if [ "${store[0]}" -eq 1 ]; then
	  tarif=L
    else
      tarif=H
	fi

    if [ -f $STOREGAS ]; then
      gv=(`cat $STOREGAS`)
    else
      gv=0
    fi

    cat > $XMLFILE << EOL
<?xml version='1.0' encoding='UTF-8'?>
<p1>
    <meter>
        <ky>1</ky>
        <version>$VERSION</version>
        <dt>$NOWDATE</dt>
        <tm>$NOWTIME</tm>
        <ds>${store[27]}</ds>
        <ta>$tarif</ta>
        <p1>${store[1]}</p1>
        <p2>${store[3]}</p2>
        <p3>${store[7]}</p3>
        <p4>${store[9]}</p4>
        <g1>${store[16]}</g1>
        <gv>${gv[0]}</gv>
        <v1>${store[2]}</v1>
        <v2>${store[4]}</v2>
        <v3>${store[8]}</v3>
        <v4>${store[10]}</v4>
        <t1>${store[5]}</t1>
        <t2>${store[11]}</t2>
        <t3>${store[25]}</t3>
        <t4>${store[26]}</t4>
        <s1>${store[13]}</s1>
        <s2>${store[14]}</s2>
        <system>$SYSTEEM</system>
        <message>$ErrorStr</message>
    </meter>
</p1>
EOL
    ftp_sendfile $XMLFILE
  fi
}





#JSON routines
fill_json() {
  if (( USE_JSON )); then
    if [ "${store[0]}" -eq 1 ]; then
      tarif=L
    else
      tarif=H
    fi

    if [ -f $STOREGAS ]; then
      gv=(`cat $STOREGAS`)
    else
      gv=0
    fi

    cat > $JSONFILE << EOL
{ "P1Data": [{
        "ky": "1",
        "version": "$VERSION",
        "dt": "$NOWDATE",
        "tm": "$NOWTIME",
        "ds": "${store[27]}",
        "ta": "$tarif",
        "p1": "${store[1]}",
        "p2": "${store[3]}",
        "p3": "${store[7]}",
        "p4": "${store[9]}",
        "g1": "${store[16]}",
        "gv": "${gv[0]}",
        "t1": "${store[5]}",
        "t2": "${store[11]}",
        "t3": "${store[25]}",
        "t4": "${store[26]}",
        "v1": "${store[2]}",
        "v2": "${store[4]}",
        "v3": "${store[8]}",
        "v4": "${store[10]}",
        "s1": "${store[13]}",
        "s2": "${store[14]}",
        "system": "$SYSTEEM",
        "message": "$ErrorStr"
    }]
}
EOL
    ftp_sendfile $JSONFILE
  fi
}

#JSON for XIVELY, including GAS-meter
make_json() {
    cat > $JSON << EOL
{
    "version": "1.0.0",
    "datastreams": [
        { "id" : "ZT1-VerbruikLaag", "current_value" : "${store[2]}" },
        { "id" : "ZT2-VerbruikHoog", "current_value" : "${store[4]}" },
        { "id" : "ZT3-TerugLaag", "current_value" : "${store[8]}" },
        { "id" : "ZT4-TerugHoog", "current_value" : "${store[10]}" },
        { "id" : "ZG1-GasVerbruik", "current_value" : "${store[17]}" },
        { "id" : "ZJ-Tarief", "current_value" : "${store[0]}" }
    ]
}
EOL
}


#HTML routines
make_html() {
  if (( USE_HTML )); then
    if [ "${store[0]}" -eq 1 ]; then
      tarif=LAAG
      tarmel="#12F310"
    else
      tarif=HOOG
      tarmel="#F40606"
    fi
    if [ $ErrorStr = "Systeem_OK" ]; then
      colmel="#12F310"
    else
      colmel="#F40606"
    fi
    cat > $TMPHTML << EOL
<html>
    <head><title>Energy Use</title></head>
    <body bgcolor='#10477E' text='#FFFFFF' link='#FFFFFF' vlink='#FFFFFF' alink='#FFFFFF' background="$BGIMG">
    <table width=740 border=0 cellpading=1 cellspacing=2 bgcolor='#10477E' BORDERcolor='#10477E' ALIGN='CENTER'>
        <tr><td colspan=8><font size=5 color='#FEC400'><center>Huidige meterstanden</center></font></td><tr>
        <tr><td colspan=8><font size=2><center>Laatste update : $HTMLNOW</center></font></td></tr>
        <tr><td colspan=8>&nbsp;&nbsp;&nbsp;</td></tr>
        <tr><td width=150>Electra verbruik hoog</td><td width=20>[T2]</td><td width=70 align=right>${store[3]}</td><td width=20>&nbsp;kWh&nbsp;&nbsp;&nbsp</td><td width=170>Electra verbruik laag</td><td width=20>[T1]</td><td width=70 align=right>${store[1]}</td><td width=20>&nbsp;kWh</td></tr>
        <tr><td>Electra teruggeleverd hoog</td><td>[T4]</td><td align=right>${store[9]}</td><td>&nbsp;kWh</td><td>Electra teruggeleverd laag</td><td>[T3]</td><td align=right>${store[7]}</td><td>&nbsp;kWh</td></tr>
        <tr><td colspan=8>&nbsp;&nbsp;&nbsp;</td></tr>
        <tr><td>Electra totaal verbruik</td><td></td><td align=right>${store[5]}</td><td>&nbsp;kWh</td><td>Electra verbruik -/- teruggeleverd hoog&nbsp;&nbsp;&nbsp;</td><td></td><td align=right>${store[25]}</td><td>&nbsp;kWh</td></tr>
        <tr><td>Electra totaal teruggeleverd</td><td></td><td align=right>${store[11]}</td><td>&nbsp;kWh</td><td>Electra verbruik -/- teruggeleverd laag&nbsp;&nbsp;&nbsp;</td><td></td><td align=right>${store[26]}</td><td>&nbsp;kWh</td></tr>
        <tr><td colspan=8>&nbsp;&nbsp;&nbsp;</td></tr>
        <tr><td>Huidige electra tarief</td><td align=right><font color=$tarmel>$tarif</font></td><td>&nbsp;</td><td></td><td></td><td></td><td></td></tr>
        <tr><td colspan=8>&nbsp;&nbsp;&nbsp;</td></tr>
        <tr><td>Gas verbruik</td><td></td><td align=right>${store[16]}</td><td>&nbsp;m3</td></tr>
        <tr><td colspan=8>&nbsp;&nbsp;&nbsp;</td></tr>
        <tr><td>Laatste systeemmelding</td><td colspan=7><font color=$colmel>"$ErrorStr"</font></td></tr>
        <tr><td colspan=8><font size=2>$SYSTEEM</font></td></tr>
    </table>
    </body>
</html>
EOL
    mv $TMPHTML $HTMLactual

    ftp_sendfile $HTMLactual
  fi
}


# Tools for sending stuff out


send_sql() {
  if (( USE_MYSQL )); then
    log "Uploading and importing SQL data"
    mysql --host="$SQLhost" --database="$SQLdb" --user="$SQLuser" --password="$SQLpass" < $SQL
    gzip $SQL
  fi
}


ftp_sendfile() {
  if (( USE_FTP)); then
    ftpfiles=()
    for file in $*; do ftpfiles+=("${file##*/}"); done
    log "Uploading files: ${ftpfiles[*]}"
    ncftpput -V -u $FTPuser -p $FTPpass $FTPhost $FTPuploaddir $*
  fi
}

email_send() {
  # $1 = Subject $2 = Body
  log "Sending email: $1"
  if (( EMAverif )); then
    sendEmail -f "$EMAsender" -t "$EMAdest" -s "$EMAsmtp" -o message-content-type=html -xu "$EMAuser" -xp "$EMApass" -u "$1" -m "$2"
  else
    sendEmail -f "$EMAsender" -t "$EMAdest" -s "$EMAsmtp" -o message-content-type=html -u "$1" -m "$2"
  fi
}