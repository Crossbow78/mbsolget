upload_xively() {
    log "Uploading to Xively"

    make_json
    curl --request PUT --data-binary @$JSON --header "$XIVELYAPIKEY" --verbose "$XIVELYFEED"
}


upload_pvoutput() {
    log "Uploading to PVOutput.org"

    V2=$(bc <<< "scale=3; (${store[21]} + ${store[22]}) / -1")
    V4=$(bc <<< "scale=3; ${store[19]} + ${store[20]}")

    PVDATA="d=${PVNOW:0:8}&t=${PVNOW:8:5}&v2=$V2&v4=$V4"
    log "Sending data: $PVDATA"
    PVREPLY=$(curl --silent --max-time 5 --retry 2 --retry-max-time 30 --header "X-Pvoutput-Apikey: $PVOUTPUT_APIKEY" --header "X-Pvoutput-SystemId: $PVOUTPUT_SYSTEMID" --data "$PVDATA" 'http://pvoutput.org/service/r2/addstatus.jsp')
    log "Response: $PVREPLY"
}


upload_mindergas() {
    log "Uploading to MinderGas.nl"

    MGDATA="{\"date\": \"$MG_DATE\", \"reading\": \"${store[16]}\"}"
    log "Sending data: $MGDATA"
    MGREPLY=$(curl --silent --max-time 5 --retry 2 --retry-max-time 30 -k --header "Content-Type:application/json" --data "$MGDATA" http://mindergas.nl/api/gas_meter_readings?auth_token=$MG_TOKEN)
    log "Response: $MGREPLY"
}
