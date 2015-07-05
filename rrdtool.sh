
#Create rrd databases
rrd_create() {
  #Create RRD Databases
  if (( USE_RRD )); then
    mkdir -p $RRDDIR
    rrdtool create $RRDDB1 -s 300 \
        DS:PUL:GAUGE:600:0:10000 \
        DS:PUH:GAUGE:600:0:10000 \
        DS:PTL:GAUGE:600:-10000:0 \
        DS:PTH:GAUGE:600:-10000:0 \
        DS:GU:GAUGE:600:0:10000 \
        DS:PUML:GAUGE:600:0:100000 \
        DS:PUMH:GAUGE:600:0:100000 \
        DS:PTML:GAUGE:600:0:100000 \
        DS:PTMH:GAUGE:600:0:100000 \
        DS:GUM:GAUGE:600:0:100000 \
        RRA:AVERAGE:0.5:1:1600 \
        RRA:AVERAGE:0.5:6:1600 \
        RRA:AVERAGE:0.5:36:1600 \
        RRA:AVERAGE:0.5:144:1600 \
        RRA:AVERAGE:0.5:1008:1600 \
        RRA:AVERAGE:0.5:4320:1600 \
        RRA:AVERAGE:0.5:52560:1600 \
        RRA:MIN:0.5:1:1600 \
        RRA:MIN:0.5:6:1600 \
        RRA:MIN:0.5:36:1600 \
        RRA:MIN:0.5:144:1600 \
        RRA:MIN:0.5:1008:1600 \
        RRA:MIN:0.5:4320:1600 \
        RRA:MIN:0.5:52560:1600 \
        RRA:MAX:0.5:1:1600 \
        RRA:MAX:0.5:6:1600 \
        RRA:MAX:0.5:36:1600 \
        RRA:MAX:0.5:144:1600 \
        RRA:MAX:0.5:1008:1600 \
        RRA:MAX:0.5:4320:1600 \
        RRA:MAX:0.5:52560:1600 \
        RRA:LAST:0.5:1:1600 \
        RRA:LAST:0.5:6:1600 \
        RRA:LAST:0.5:36:1600 \
        RRA:LAST:0.5:144:1600 \
        RRA:LAST:0.5:1008:1600 \
        RRA:LAST:0.5:4320:1600 \
        RRA:LAST:0.5:52560:1600
  fi
}

#Update database
rrd_update() {
  if (( USE_RRD )); then
    if [ ${store[23]} != 0 ] || [ ${store[24]} != 0 ]; then
      rrdtool update $RRDDB1 N:${store[19]}:${store[20]}:${store[21]}:${store[22]}:${store[23]}:${store[1]}:${store[3]}:${store[7]}:${store[9]}:${store[16]}
    else
      rrdtool update $RRDDB1 N:${store[19]}:${store[20]}:${store[21]}:${store[22]}:0:${store[1]}:${store[3]}:${store[7]}:${store[9]}:${store[16]}
    fi
  fi
}


#Variables collection for RRD graph, upload to your site
make_graph() {
  log "Generating graphs"
  draw_graphic_electra_overal_plus 'electra_lh_all.png' "12h" "$p0"
  draw_graphic_electra_overal 'electra_ld_all.png' "1d" "$p1"
  draw_graphic_electra_overal 'electra_lw_all.png' "1w" "$p2"
  draw_graphic_electra_overal 'electra_lm_all.png' "1m" "$p3"
  draw_graphic_electra_overal 'electra_lj_all.png' "1y" "$p4"
  draw_graphic_gas_plus 'gas_ld.png' "1d" "$p1"
  draw_graphic_gas 'gas_lw.png' "1w" "$p2"
  draw_graphic_gas 'gas_lm.png' "1m" "$p3"
  draw_graphic_gas 'gas_lj.png' "1y" "$p4"

  ftp_sendfile $GRAPHDIR/electra*.png $GRAPHDIR/gas*.png
}

store_daily_graphs(){
  init_graph
  TS=`date --date=$YESTERDAY +"%d-%m-%Y"`
  END=$NOWA
  draw_graphic_electra_overal_plus "hist_electra_$YESTERDAY.png" "1d" "Dagoverzicht"
  draw_graphic_gas_plus "hist_gas_$YESTERDAY.png" "1d" "Dagoverzicht"

  ftp_sendfile $GRAPHDIR/hist*$YESTERDAY.png

  rm $GRAPHDIR/hist*$YESTERDAY.png
}

#Call RRD graph for generating graphs
draw_graphic_gas() {
  rrdtool graph $GRAPHDIR/$1 --end $END --start end-$2 -a PNG \
    -t "Gasverbruik - $3 - $TS" \
    -r --units-exponent 0 \
    -v "dm3" \
    -w $swidth \
    -h $sheight \
    --border 0 \
    DEF:GU=$RRDDB1:GU:MAX \
    AREA:GU$Color_Gas:"Gasverbruik in dm3" \
      "VDEF:GU_MIN=GU,MINIMUM" \
      "GPRINT:GU_MIN:Min\: %8.3lf%s" \
      "VDEF:GU_AVERAGE=GU,AVERAGE" \
      "GPRINT:GU_AVERAGE:Avg\: %8.3lf%s" \
      "VDEF:GU_MAX=GU,MAXIMUM" \
      "GPRINT:GU_MAX:Max\: %8.3lf%s" \
      "VDEF:GU_LAST=GU,LAST" \
      "GPRINT:GU_LAST:Last\: %8.3lf%s\n" \
    COMMENT:" \n" >/dev/null
}

draw_graphic_gas_plus() {
  rrdtool graph $GRAPHDIR/$1 --end $END --start end-$2 -a PNG \
    -t "Gasverbruik - $3 - $TS" \
    -r --units-exponent 0 \
    -v "dm3" \
    -w $swidth \
    -h $sheight \
    --border 0 \
    DEF:GU=$RRDDB1:GU:AVERAGE \
    AREA:GU$Color_Gas:"Gasverbruik in dm3" \
      "VDEF:GU_MIN=GU,MINIMUM" \
      "GPRINT:GU_MIN:Min\: %8.3lf%s" \
      "VDEF:GU_AVERAGE=GU,AVERAGE" \
      "GPRINT:GU_AVERAGE:Avg\: %8.3lf%s" \
      "VDEF:GU_MAX=GU,MAXIMUM" \
      "GPRINT:GU_MAX:Max\: %8.3lf%s" \
      "VDEF:GU_LAST=GU,LAST" \
      "GPRINT:GU_LAST:Last\: %8.3lf%s\n" \
    COMMENT:" \n" \
    DEF:GUM=$RRDDB1:GUM:LAST \
      "VDEF:GUM_LAST=GUM,LAST" \
      "GPRINT:GUM_LAST:Laatste meterstand \: %8.3lf%s m3\n" \
    COMMENT:" \n" \
    COMMENT:"Een smartmeter geeft elk uur het totale verbruik in m3 door. \n" \
    COMMENT:"De pieken geven dus het verbruik van het voorgaande uur weer (in m3). \n" \
    COMMENT:" \n" >/dev/null
}

draw_graphic_electra_overal() {
  rrdtool graph $GRAPHDIR/$1 --end $END --start end-$2 -a PNG \
    -t "Electriciteitsverbruik - $3 - $TS" \
    -r --units-exponent 0 \
    -v "Watt" \
    -w $swidth \
    -h $sheight \
    --border 0 \
    DEF:PUL=$RRDDB1:PUL:AVERAGE AREA:PUL$Color_Ver_Lg:"Verbruik laagtarief in Watt" \
      "VDEF:PUL_MIN=PUL,MINIMUM" \
      "GPRINT:PUL_MIN:Min\: %8.2lf%s" \
      "VDEF:PUL_AVERAGE=PUL,AVERAGE" \
      "GPRINT:PUL_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PUL_MAX=PUL,MAXIMUM" \
      "GPRINT:PUL_MAX:Max\: %8.2lf%s" \
      "VDEF:PUL_LAST=PUL,LAST" \
      "GPRINT:PUL_LAST:Last\: %8.2lf%s\n" \
    DEF:PUH=$RRDDB1:PUH:AVERAGE AREA:PUH$Color_Ver_Hg:"Verbruik hoogtarief in Watt" \
      "VDEF:PUH_MIN=PUH,MINIMUM" \
      "GPRINT:PUH_MIN:Min\: %8.2lf%s" \
      "VDEF:PUH_AVERAGE=PUH,AVERAGE" \
      "GPRINT:PUH_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PUH_MAX=PUH,MAXIMUM" \
      "GPRINT:PUH_MAX:Max\: %8.2lf%s" \
      "VDEF:PUH_LAST=PUH,LAST" \
      "GPRINT:PUH_LAST:Last\: %8.2lf%s\n" \
    DEF:PTL=$RRDDB1:PTL:AVERAGE AREA:PTL$Color_Ter_Lg:"Levering laagtarief in Watt" \
      "VDEF:PTL_MIN=PTL,MINIMUM" \
      "GPRINT:PTL_MIN:Min\: %8.2lf%s" \
      "VDEF:PTL_AVERAGE=PTL,AVERAGE" \
      "GPRINT:PTL_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PTL_MAX=PTL,MAXIMUM" \
      "GPRINT:PTL_MAX:Max\: %8.2lf%s" \
      "VDEF:PTL_LAST=PTL,LAST" \
      "GPRINT:PTL_LAST:Last\: %8.2lf%s\n" \
    DEF:PTH=$RRDDB1:PTH:AVERAGE AREA:PTH$Color_Ter_Hg:"Levering hoogtarief in Watt" \
      "VDEF:PTH_MIN=PTH,MINIMUM" \
      "GPRINT:PTH_MIN:Min\: %8.2lf%s" \
      "VDEF:PTH_AVERAGE=PTH,AVERAGE" \
      "GPRINT:PTH_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PTH_MAX=PTH,MAXIMUM" \
      "GPRINT:PTH_MAX:Max\: %8.2lf%s" \
      "VDEF:PTH_LAST=PTH,LAST" \
      "GPRINT:PTH_LAST:Last\: %8.2lf%s\n" \
    COMMENT:" \n" >/dev/null
}

draw_graphic_electra_overal_plus() {
  rrdtool graph $GRAPHDIR/$1 --end $END --start end-$2 -a PNG \
    -t "Electriciteitsverbruik - $3 - $TS" \
    -r --units-exponent 0 \
    -v "Watt" \
    -w $swidth \
    -h $sheight \
    --border 0 \
    DEF:PUL=$RRDDB1:PUL:AVERAGE AREA:PUL$Color_Ver_Lg:"Verbruik laagtarief in Watt" \
      "VDEF:PUL_MIN=PUL,MINIMUM" \
      "GPRINT:PUL_MIN:Min\: %8.2lf%s" \
      "VDEF:PUL_AVERAGE=PUL,AVERAGE" \
      "GPRINT:PUL_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PUL_MAX=PUL,MAXIMUM" \
      "GPRINT:PUL_MAX:Max\: %8.2lf%s" \
      "VDEF:PUL_LAST=PUL,LAST" \
      "GPRINT:PUL_LAST:Last\: %8.2lf%s\n" \
    DEF:PUH=$RRDDB1:PUH:AVERAGE AREA:PUH$Color_Ver_Hg:"Verbruik hoogtarief in Watt" \
      "VDEF:PUH_MIN=PUH,MINIMUM" \
      "GPRINT:PUH_MIN:Min\: %8.2lf%s" \
      "VDEF:PUH_AVERAGE=PUH,AVERAGE" \
      "GPRINT:PUH_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PUH_MAX=PUH,MAXIMUM" \
      "GPRINT:PUH_MAX:Max\: %8.2lf%s" \
      "VDEF:PUH_LAST=PUH,LAST" \
      "GPRINT:PUH_LAST:Last\: %8.2lf%s\n" \
    DEF:PTL=$RRDDB1:PTL:AVERAGE AREA:PTL$Color_Ter_Lg:"Levering laagtarief in Watt" \
      "VDEF:PTL_MIN=PTL,MINIMUM" \
      "GPRINT:PTL_MIN:Min\: %8.2lf%s" \
      "VDEF:PTL_AVERAGE=PTL,AVERAGE" \
      "GPRINT:PTL_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PTL_MAX=PTL,MAXIMUM" \
      "GPRINT:PTL_MAX:Max\: %8.2lf%s" \
      "VDEF:PTL_LAST=PTL,LAST" \
      "GPRINT:PTL_LAST:Last\: %8.2lf%s\n" \
    DEF:PTH=$RRDDB1:PTH:AVERAGE AREA:PTH$Color_Ter_Hg:"Levering hoogtarief in Watt" \
      "VDEF:PTH_MIN=PTH,MINIMUM" \
      "GPRINT:PTH_MIN:Min\: %8.2lf%s" \
      "VDEF:PTH_AVERAGE=PTH,AVERAGE" \
      "GPRINT:PTH_AVERAGE:Avg\: %8.2lf%s" \
      "VDEF:PTH_MAX=PTH,MAXIMUM" \
      "GPRINT:PTH_MAX:Max\: %8.2lf%s" \
      "VDEF:PTH_LAST=PTH,LAST" \
      "GPRINT:PTH_LAST:Last\: %8.2lf%s\n" \
    COMMENT:" \n" \
    DEF:PUML=$RRDDB1:PUML:LAST \
      "VDEF:PUML_LAST=PUML,LAST" \
      "GPRINT:PUML_LAST:Laatste meterstand verbruik laagtarief\: %8.3lf%s kWh\n" \
    DEF:PUMH=$RRDDB1:PUMH:LAST \
      "VDEF:PUMH_LAST=PUMH,LAST" \
      "GPRINT:PUMH_LAST:Laatste meterstand verbruik hoogtarief\: %8.3lf%s kWh\n" \
    DEF:PTML=$RRDDB1:PTML:LAST \
      "VDEF:PTML_LAST=PTML,LAST" \
      "GPRINT:PTML_LAST:Laatste meterstand levering laagtarief\: %8.3lf%s kWh\n" \
    DEF:PTMH=$RRDDB1:PTMH:LAST \
      "VDEF:PTMH_LAST=PTMH,LAST" \
      "GPRINT:PTMH_LAST:Laatste meterstand levering hoogtarief\: %8.3lf%s kWh\n" \
    COMMENT:" \n" >/dev/null
}

graph() {
  if (( USE_RRD )); then
    init_graph
    make_graph
  fi
}

init_graph() {
    NOW=`date +%s`
    #TimeStamp
    TS=`date +"Laatste update op %d.%m.%Y - %H:%M"`
    END=now
    #Period
    p0="laatste 12 uur"
    p1="laatste 24 uur"
    p2="laatste week"
    p3="laatste maand"
    p4="laatste jaar"
    #Colors
    Color_Ver_Lg=#00a423
    Color_Ver_Hg=#ff8400
    Color_Ter_Lg=#00ff36
    Color_Ter_Hg=#ffc000  
    Color_Gas=#2401FC
    #sizes
    swidth=700
    sheight=175
}
