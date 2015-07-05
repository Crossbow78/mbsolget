#
# MBSolget P1 Telegram Catch
# DSMR 2 ( en 3 .... ?)
# 

version = "v1.00"
import sys
import os
import stat
import serial
import datetime
import locale

###############################################################################################################
# Main program
###############################################################################################################
#Initialize
p1_telegram  = False
p1_timestamp = ""
p1_linecount = 0
p1_log       = True
p1_logfile   = os.getenv('WORKDIR', "/home/pi/tmp") + "/p1_temp.log"

#Set COM port config
ser          = serial.Serial()
ser.baudrate = 9600
ser.bytesize = serial.SEVENBITS
ser.parity   = serial.PARITY_EVEN
#ser.stopbits = serial.STOPBITS_ONE
ser.xonxoff  = 1
ser.rtscts   = 0
ser.timeout  = 20
ser.port     = os.getenv('P1PORT', "/dev/ttyUSB0")

#Show startup arguments 
print ("MBSolget P1 Telegram Catch %s" % version)
print ("Control-C om af te breken")
print ("Poort: (%s)" % (ser.name) )

#Open COM port
try:
    ser.open()
except:
    sys.exit ("Fout bij het openen van poort %s. "  % ser.name)      

while p1_log and p1_linecount < 25:
    p1_line = ''
    try:
        p1_raw = ser.readline()
    except:
        ser.close()
        sys.exit ("Fout bij het lezen van poort %s. " % ser.name )

    #p1_str  = p1_raw
    p1_str  = str(p1_raw)
    p1_line = p1_str.strip()
    print (p1_line)

    if p1_line[0:1] == "/":
        p1_telegram = True
        f=open(p1_logfile, "w")
    if p1_telegram:
        p1_linecount = p1_linecount + 1
        f.write (p1_line)
        f.write ('\r\n')
        if p1_line[0:1] == '!':
            p1_linecount   = 0
            p1_telegram = False 
            p1_log      = False	
            f.close()
            os.chmod(p1_logfile, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IWGRP | stat.S_IROTH | stat.S_IWOTH )

#Close port and show status
try:
    ser.flush()
    ser.close()
except:
    sys.exit ("Fout bij het sluiten van %s. Programma afgebroken." % ser.name )      
