# Initialization
BEGIN { FS="[:()*SW]" }

# Pattern matches to extract the fields we want
/1\.8\.1/   { l1 = $3; }
/1\.8\.2/   { l2 = $3; }
/2\.8\.1/   { t1 = $3; }
/2\.8\.2/   { t2 = $3; }
/96\.14\.0/ { ta = $3; }
/1\.7\.0/   { w1 = $3; }
/2\.7\.0/   { w2 = $3; }
/24\.2\.1/  { dt = $3; g1 = $6; }

# Finally dump the variables into an array.
END { print ta,l1,l2,(l1+l2),t1,t2,(t1+t2),w1,w2,(w1+w2),g1,dt; }
