#!/bin/bash

# UPDATE THIS PATH
JSON_FILE="$(dirname $0)/wearehunted.json"
EMERGING_URL='http://wearehunted.com/emerging/'
USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.75 Safari/535.'
HASHSIGNAL_HEADER='X-Hashsignal: Hashsignal'
XREQUESTED_HEADER='X-Requested-With: XMLHttpRequest'

/usr/bin/curl -s $EMERGING_URL -H $HASHSIGNAL_HEADER -H $XREQUESTED_HEADER -A $USER_AGENT | egrep -o 'HUNTED.chart.entities = \[\{.*' | sed -e 's/HUNTED.chart.entities = //;s/;$//' > $JSON_FILE

