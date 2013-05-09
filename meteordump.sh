#!/bin/bash
#                    __                           
#   _____    ____  _/  |_   ____    ____  _______ 
#  /     \ _/ __ \ \   __\_/ __ \  /  _ \ \_  __ \
# |  Y Y  \\  ___/  |  |  \  ___/ (  <_> ) |  | \/
# |__|_|  / \___  > |__|   \___  > \____/  |__|   
#      \/      \/             \/                 
#
#     .___                        
#   __| _/ __ __   _____  ______  
#  / __ | |  |  \ /     \ \____ \ 
# / /_/ | |  |  /|  Y Y  \|  |_> >
# \____ | |____/ |__|_|  /|   __/ 
#      \/              \/ |__|    
#
# The meteor.com Hot Dump 2-step 
# Dump a mongo db from a live meteor app to a local dump dir. 
#
# Splits up the output of:
#    meteor mongo $METEOR_DOMAIN --url 
# and pushes it into 
#    mongodump -u $MONGO_USER -h $MONGO_DOMAIN -d $MONGO_DB -p "${MONGO_PASSWORD}"
# 
# Doing so by hand is tedious as the password in the url is only valid for 60 seconds.
#
# Requires 
# - meteor  (tested on 0.5.9)
# - mongodb (tested in 2.4.0)
#
# Usage
#    ./meteor-dump.sh goto
#
# If all goes well it'll create a dump folder in the current working directory.
#
# By @olizilla
# On 2013-03-20. Using this script after it's sell by date may void your warranty.
#

METEOR_DOMAIN="$1"

if [[ "$METEOR_DOMAIN" == "" ]]
then
	echo "You need to supply your meteor app name"
	echo "e.g. ./meteor-dump.sh app"
	exit 1
fi

# REGEX ALL THE THINGS.
# Chomps the goodness flakes out of urls like "mongodb://client:pass-word@skybreak.member0.mongolayer.com:27017/goto_meteor_com"
MONGO_URL_REGEX="mongodb:\/\/(.*):(.*)@(.*)\/(.*)"

# stupid tmp file as meteor may want to prompt for a password
TMP_FILE="/tmp/meteor-dump.tmp"

# Get the mongo url for your meteor app
meteor mongo $METEOR_DOMAIN --url | tee "${TMP_FILE}"

MONGO_URL=$(sed '/Password:/d' "${TMP_FILE}")

# clean up the temp file
if [[ -f "${TMP_FILE}" ]]
then
	rm "${TMP_FILE}"
fi

if [[ $MONGO_URL =~ $MONGO_URL_REGEX ]] 
then
	MONGO_USER="${BASH_REMATCH[1]}"
	MONGO_PASSWORD="${BASH_REMATCH[2]}"
	MONGO_DOMAIN="${BASH_REMATCH[3]}"
	MONGO_DB="${BASH_REMATCH[4]}"

	#e.g mongodump -u client -h skybreak.member0.mongolayer.com:27017 -d goto_meteor_com -p "guid-style-password"
	mongodump -u $MONGO_USER -h $MONGO_DOMAIN -d $MONGO_DB -p "${MONGO_PASSWORD}"
else
	echo "Sorry, no dump for you. Couldn't extract your details from the url: ${MONGO_URL}"
	exit 1
fi