#!/bin/bash 

## BEFORE RUNNING THIS SCRIPT, INSTALL PACKAGES:
    # sendEmail
    # enscript
    # ps2pdf (this may be already in there)

./machine-status.sh > out.txt
enscript -p out.txt out.ps 
ps2pdf out.ps machine-update.pdf

rm out.ps out.txt

# send out the file --------------------------------
smtp="smtp.googlemail.com:587"

## use an email that you dont care about
from="ENTER FROM EMAIL HERE"
to="ENTER TO EMAIL HERE"

username="ENTER USERNAME HERE"
password="ENTER PASSWORD HERE"

## do not include hyphens in text body 

subject="Subject: This is a test email from padu pauli"
message="This is a message body testing testing testing"
attachments="machine-update.pdf"

sendEmail -f ${from} -t ${to} \
-u ${subject} \
-m ${message} \
-s ${smtp} \
-xu ${username} \
-xp ${password} -a ${attachments}