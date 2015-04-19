#!/bin/bash
source $HOME/bin/fritzbox-login.sh
exportpwd=""

# get configuration from FritzBox and write to STDOUT
curl -s \
     -k \
     --form 'sid='${avmsid} \
     --form 'ImportExportPassword='${exportpwd} \
     --form 'ConfigExport=' \
     http://${avmfbip}/cgi-bin/firmwarecfg
