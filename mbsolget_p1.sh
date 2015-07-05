#!/bin/bash
#
####################################################################
# Written by Marco Bakker, embezon@mbsoft.nl           	           #
# Last modified on may 26, 2013                                    #
#                                                                  #
# Version 3.10                                                     #
####################################################################
# History :                                                        #
# Version 1.20 - Initial release                                   #
# Version 1.50 - 2013-05-05 - HTML-page added with actual data,    #
#                             HTML-page added with proforma nota.  #
#                             Email added.                         #
# Version 1.60 - 2013-05-26 - Error with kWh-W calculation.        #
#                             COSM changed to XIVELY               #
#                             Minor changes                        #
# Version 1.61 - 2014-02-08 - Minor changes                        #
# Version 2.00 - 2014-10-25 - XML for windows app added            #
#                             Added dsmr4 support                  #
#              Thanks to Wouter Bouvy for the info about his dsmr4 #
# Version 2.10 - 2014-11-04 - Added export to mindergas.nl         #
#                             Thanks to Wouter Bouvy               #
# Version 2.20 - 2014-12-14 - Minor Changes                        #
# Version 2.30 - 2015-03-11 - Minor Changes /                      #
#                             Added export to PVOutput             #
# 
# Version 3.00 - 2015-03-25 - Overhaul by Sebastian Groeneveld     #
# Version 3.10 - 2015-06-05 - Split into separate scripts          #
#                                                                  #
####################################################################
#This program is free software and is available under the terms of #
#the GNU General Public License. You can redistribute it and/or    #
#modify it under the terms of the GNU General Public License as    #
#published by the Free Software Foundation.                        #
#                                                                  #
#This program is distributed in the hope that it will be useful,   #
#but WITHOUT ANY WARRANTY; without even the implied warranty of    #
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     #
#GNU General Public License for more details.                      #
####################################################################
#
##User defined Variables Section
VERSION=3.10
NOW=`date +"%Y%m%d-%H%M"`
NOWA=`date +"%Y%m%d"`
NOWDATE=`date +"%Y.%m.%d"`
NOWTIME=`date +"%H:%M"`
YESTERDAY=`date -d "yesterday 13:00 " '+%Y%m%d'`
YEAR=`date +"%Y"`
SYSTEEM=`uname -a`
CURDIR=`dirname "$0"`

. "$CURDIR/config.sh"
. "$CURDIR/rrdtool.sh"
. "$CURDIR/exports.sh"
. "$CURDIR/externals.sh"

#Program Routines
#Help
help(){
  echo ""
  echo "mbsolget_p1 - Reading telegram from Smart-Meter / P1"
  echo "and process the values to CSV - SQL - JSON - XIVELY."
  echo ""
  echo "Version : " $VERSION
  echo ""
}

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') $1"
}

# Main Program
main(){
  log "Started" 

  #set time variables
  MTIME=`date +%M`
  HTIME=`date +%H`

  #set alternative values
  PYSCR=$WORKDIR/python/mbsolget_p1.py
  AWKSCR=$WORKDIR/mbsolget_p1.awk
  FSIZE=455
  if (( ALTER )); then
    PYSCR=$WORKDIR/python/mbsolget_p1_a1.py
    AWKSCR=$WORKDIR/mbsolget_p1_a1.awk
    FSIZE=678
  fi

  #Stored file contains data needed for calculating totals etc
  #Internally an array is used, values are:
  #  ${store_old[0]}    ta - Huidige tarief : hoog / laag
  #  ${store_old[1]}	l1 - Verbruik laag tarief kWh
  #  ${store_old[2]}	l2 - Verbruik hoog tarief kWh
  #  ${store_old[3]}       - Totaal Verbruik kWh            = l1+l2
  #  ${store_old[4]}	t1 - Teruglevering laag tarief kWh
  #  ${store_old[5]}	t2 - Teruglevering hoog tarief kWh
  #  ${store_old[6]}       - Totaal Teruglevering kWh       = t1+t2
  #  ${store_old[7]}	w1 - Huidige verbruik kW
  #  ${store_old[8]}	w2 - Huidige teruglevering kW
  #  ${store_old[9]}       - Totaal Huidig verbruik        = w1+w2
  #  ${store_old[10]}	g1 - Verbruik gas m3
  #  ${store_old[11]}   dt - Tijd van de laatste gasmeting
  #
  #Fill array
  if [ -f $STORE ]; then
    STORELOG=1
    storeold=(`cat $STORE`)
  else
    #create empty bucket
    STORELOG=0
    echo 0 0 0 0 0 0 0 0 0 0 0 0 0 > $STORE
    storeold=(`cat $STORE`)
    storeoldtime=0
  fi

  log "Waiting for P1 telegram"

  #Retrieve P1 telegram from smart meter and store this in $WORKDIR/p1_temp.log
  /usr/bin/python $PYSCR >/dev/null
  filesize=$(stat -c%s "$WORKDIR/p1_temp.log")
  
  if [ $filesize != $FSIZE ]; then
    log "Error while reading serial port, retrying..."
    /usr/bin/python $PYSCR >/dev/null
    filesize=$(stat -c%s "$WORKDIR/p1_temp.log")
  fi

  if (( STORELOG )); then
    storeoldtime=$(stat -c%Z $STORE)
  fi

  #Proces only when filesize is correct ....
  if [ $filesize = $FSIZE ]; then
    log "Received successfully"

    #Process $WORKDIR/p1_temp.log
    MESSAGE=`cat $WORKDIR/p1_temp.log | awk -f $AWKSCR > $STORE`

    storenew=(`cat $STORE`)
    storenewtime=$(stat -c%Z $STORE)
    
    # Calculating ....
    # store[0]  = Tarief Hoog/Laag
    # store[1]  = Huidige stand Import Tarief Laag
    # store[2]  = Verschil stand Import Tarief Laag
    # store[3]  = Huidige stand Import Tarief Hoog
    # store[4]  = Verschil stand Import Tarief Hoog
    # store[5]  = store[1] + store[3]
    # store[6]  = store[2] + store[4]
    #
    # store[7]  = Huidige stand Export Tarief Laag
    # store[8]  = Verschil stand Export Tarief Laag
    # store[9]  = Huidige stand Export Tarief Hoog
    # store[10] = Verschil stand Export Tarief Hoog
    # store[11] = store[7] + store[9]
    # store[12] = store[8] + store[10]
    #
    # store[13] = Huidige Import
    # store[14] = Huidige Export
    # store[15] = store[13] + store[14]
    #
    # store[16] = Huidige stand Verbruik Gas
    # store[17] = Verschil stand Verbruik Gas
    # store[18] = Tijd van de laatste gasmeting
    #
    # store[19] = Import Laag in Watt  store[2] * 12000
    # store[20] = Import Hoog in Watt  store[4] * 12000
    # store[21] = Export Laag in Watt     store[8] * -12000
    # store[22] = Export Hoog in Watt     store[10] * -12000
    # store[23] = Verbruik in dm3        store[17] * 1000
    # store[24] = Verschil tussen meettijden gas
    #
    # store[25] = Electra import -/- export hoog	(3 - 9)
    # store[26] = Electra import -/- export laag	(1 - 7)
    #
    # store[27] = Tijd sinds vorige meting
    # store[28] = Verschil in verbruik (W)
    # store[29] = Verschil in teruglevering (W)

    store[0]="0000"
    if [ ${storenew[0]} = "0001" ]; then
        store[0]=1
    fi
    if [ ${storenew[0]} = "0002" ]; then
        store[0]=2
    fi

    store[27]=$(( $storenewtime - $storeoldtime ))

    store[1]=$(bc <<< "scale=3; ${storenew[1]} * 1.000")
    store[2]=$(bc <<< "scale=3; ${storenew[1]} - ${storeold[1]}")
    store[3]=$(bc <<< "scale=3; ${storenew[2]} * 1.000")
    store[4]=$(bc <<< "scale=3; ${storenew[2]} - ${storeold[2]}")
    store[5]=$(bc <<< "scale=3; ${store[1]} + ${store[3]}")
    store[6]=$(bc <<< "scale=3; ${store[2]} + ${store[4]}")

    store[7]=$(bc <<< "scale=3; ${storenew[4]} * 1.000")
    store[8]=$(bc <<< "scale=3; ${storenew[4]} - ${storeold[4]}")
    store[9]=$(bc <<< "scale=3; ${storenew[5]} * 1.000")
    store[10]=$(bc <<< "scale=3; ${storenew[5]} - ${storeold[5]}")
    store[11]=$(bc <<< "scale=3; ${store[7]} + ${store[9]}")
    store[12]=$(bc <<< "scale=3; ${store[8]} + ${store[10]}")

    store[13]=$(bc <<< "scale=3; ${storenew[7]} * 1.000")
    store[14]=$(bc <<< "scale=3; ${storenew[8]} * 1.000")
    store[15]=$(bc <<< "scale=3; ${store[13]} + ${store[14]}")

    store[16]=$(bc <<< "scale=3; ${storenew[10]} * 1.000")
    store[17]=$(bc <<< "scale=3; ${storenew[10]} - ${storeold[10]}")
    store[18]=${storenew[11]}

    store[19]=$(bc <<< "scale=0; ${store[2]} * 3600000 / ${store[27]}")
    store[20]=$(bc <<< "scale=0; ${store[4]} * 3600000 / ${store[27]}")
    store[21]=$(bc <<< "scale=0; ${store[8]} * -3600000 / ${store[27]}")
    store[22]=$(bc <<< "scale=0; ${store[10]} * -3600000 / ${store[27]}")
    store[23]=$(bc <<< "scale=0; 1000 * ${store[17]} / 1")
    store[24]=$(bc <<< "scale=0; ${storenew[11]} - ${storeold[11]}")

    store[25]=$(bc <<< "scale=0; ${store[3]} - ${store[9]}")
    store[26]=$(bc <<< "scale=0; ${store[1]} - ${store[7]}")

    store[28]=$(bc <<< "scale=0; 1000 * (${storenew[7]} - ${storeold[7]}) / 1")
    store[29]=$(bc <<< "scale=0; 1000 * (${storenew[8]} - ${storeold[8]}) / 1")
  
    echo -e ${store[@]} > $WORKDIR/debug.tmp

    if [[ ${store[17]} > 0 ]]; then
      echo -e ${store[17]} > $STOREGAS
    fi

    if (( STORELOG )); then

      if (( $MTIME % 5 == 0 )); then

        fill_csv

        rrd_update

        #Upload Xively
        if (( USE_XIVELY )); then
          upload_xively
        fi

        #PVoutput routine
        if (( USE_PVOUTPUT )); then
          upload_pvoutput
        fi

        #Upload Mindergas
        if (( USE_MG )); then
          if [[ $HTIME == 00 && $MTIME == 05 ]]; then
            upload_mindergas
          fi
        fi

        fill_sql

        if [[ $HTIME == 23 && $MTIME == 55 ]]; then
          send_sql
        fi
      fi

      if (( USE_LOG )); then
        if (( USE_XIVELY )); then
          cat $JSON >> $WORKDIR/log/xively-$NOW.json
        fi
        cat $WORKDIR/p1_temp.log >> $WORKDIR/log/p1-$NOW.log
      fi

      #Touch
      touch $WORKDIR/mbsolget_p1.last

    fi

    #Make XML
    fill_xml
    
    #Make JSON
    fill_json
    
    #Make graphs
    if (( USE_RRD )); then
      if (( $MTIME % 15 == 0 )); then
        graph
        if [[ $HTIME == 00 && $MTIME == 00 ]]; then
          store_daily_graphs
        fi
      fi
    fi
    
    make_html

    #Everything OK
    ErrorStr="Systeem_OK"
  else
    log "Error while reading serial port"
    ErrorStr="P1_Read_Error"
  fi


  #Remove temp-files
  if (( USE_CLEAR )); then
    if [ -f $JSON ]; then
      rm $JSON
    fi
    if [ -f $WORKDIR/p1_temp.log ]; then
      rm $WORKDIR/p1_temp.log
    fi
  fi

  log "Finished"
  log "---------------------------------"
}


#What to do ?
case $1 in
  "help"   ) help;;
  "create" ) rrd_create;;
  "draw"   ) WORKDIR=/home/pi/mbsolget
             STORE=$WORKDIR/mbsolget_p1_value.tmp
             storenew=(`cat $STORE`)
             graph;;
  "test"   ) store_daily_graphs;;
  *        ) main;;
esac
