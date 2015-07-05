#Alternative ways
#0 = Standard (dsmr2)
#1 = dsmr4
ALTER=0

# Device that is connected to P1 port
P1PORT="/dev/ttyUSB0"

# Location to write temporary files (without ending /)
WORKDIR=/home/pi/tmp

#RRD Graphs location (www location for use on a website) (without ending /)
GRAPHDIR="$WORKDIR/graphs"

#File to store values needed for measurements
STORE="$WORKDIR/p1_value.tmp"
STOREGAS="$WORKDIR/p1_gas.tmp"
STOREYIELD="$WORKDIR/yield.tmp"

#LOG : 0 = No, 1 = Yes
USE_LOG=1
#Remove files : 0 = No, 1 = Yes
USE_CLEAR=1

#CSV : 0 = No, 1 = Yes
USE_CSV=0
CSVFILE="$WORKDIR/data/daily/$YEAR/2497DJ04-$NOWA.csv"

#XIVELY : 0 = No, 1 = Yes - Writes values to Xively : account needed !
USE_XIVELY=0
XIVELYAPIKEY="X-ApiKey: "
XIVELYFEED=https://api.xively.com/v2/feeds/465225492
#JSON : needed for XIVELY
JSON="$WORKDIR/xively.json"

#If RRD is not installed or not wanted : 0 = No, 1 = Yes
USE_RRD=1
#RRD database location (without ending /)
RRDDIR="$WORKDIR"
#RRD Graphs location (www location for use on a website) (without ending /)
#RRD database names
RRDDB1="$RRDDIR/mbsolget_p1.rrd"

#MySQL : 0 = No, 1 = Yes - Writes 'insert into .....' for importing data into MySql
USE_MYSQL=0
#File to store SQL-statements
SQL="$WORKDIR/sql/daily/$YEAR/mbsolget_p1-$NOWA.sql"
SQLhost=""
SQLdb=""
SQLuser=""
SQLpass=""

#File to store XML
USE_XML=1
XMLFILE="$WORKDIR/data/p1.xml"

#File to store JSON
USE_JSON=1
JSONFILE="$WORKDIR/data/p1.json"

#Optional HTML page
USE_HTML=0
HTMLNOW=`date +"%d-%m-%Y  %H:%M"`
#Location to write the html output (without ending /)
TMPHTML="$WORKDIR/index.new"
HTMLDIR="$WORKDIR/graphs"
HTMLactual="$HTMLDIR/actual_eu.html"

#Optional FTP parameters : 0 = No, 1 = Yes
USE_FTP=0
FTPuser=""
FTPpass=""
FTPhost=""
FTPuploaddir="/var/www"

#Optional Email parameters : 0 = No, 1 = Yes
USE_EMAIL=0
EMAsender="Raspberry Pi <pi@raspberrypi>"
EMAdest=""
EMAsmtp="smtp.gmail.com"
EMAverif=1
EMAuser=""
EMApass=""

#Optional export to mindergas.nl : 0 = No, 1 = Yes
USE_MG=0
MG_TOKEN=""
MG_DATE=$(date +"%Y-%m-%d" -d "1 days ago")

#PVOutput.org : 0 = No, 1 = Yes
USE_PVOUTPUT=0
PVOUTPUT_APIKEY=""
PVOUTPUT_SYSTEMID=""
PVNOW=`date +"%Y%m%d%H:%M"`

# Initialize directories
mkdir -p "$WORKDIR/log"
mkdir -p "$WORKDIR/data/daily/$YEAR"
mkdir -p "$WORKDIR/sql/daily/$YEAR"
mkdir -p "$GRAPHDIR"

# We will use these inside the python script
export WORKDIR
export P1PORT