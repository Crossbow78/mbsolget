#
# MBSolget P1 Telegram Catch
# DSMR 4 
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
p1_teller    = 0
p1_log       = True
p1_logfile   = os.getenv('WORKDIR', "/home/pi/tmp") + "/p1_temp.log"

#Set COM port config
ser          = serial.Serial()
ser.baudrate = 115200
ser.bytesize = serial.EIGHTBITS
ser.parity   = serial.PARITY_NONE
ser.stopbits = serial.STOPBITS_ONE
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

while p1_log:
    p1_line = ''
    try:
        p1_raw = ser.readline()
    except:
        ser.close()        
        sys.exit ("Fout bij het lezen van poort %s. " % ser.name )

    p1_str  = p1_raw
    p1_str  = str(p1_raw, "utf-8")
    p1_line = p1_str.strip()
    print (p1_line)

    if p1_line[0:1] == "/":
        p1_telegram = True
        p1_teller   = p1_teller + 1
        f=open(p1_logfile, "w")
    elif p1_line[0:1] == "!":
        if p1_telegram:
            p1_teller   = 0
            p1_telegram = False 
            p1_log      = False	
            f.write (p1_line)
            f.write ('\r\n')
            f.close()	
            os.chmod(p1_logfile, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IWGRP | stat.S_IROTH | stat.S_IWOTH )
    if p1_telegram:
        f.write (p1_line)
        f.write ('\r\n')

#Close port and show status
try:
    ser.close()
except:
    sys.exit ("Fout bij het sluiten van %s. Programma afgebroken." % ser.name )      
