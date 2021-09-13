#!/bin/bash
#
# list-coa.sh
# Import chart of accounts from CSV to Mifos X
#
# Usage:
#
# e.g. ./list-coa.sh -u mifos -p password -t default -a https://domain.com:80/fineract-provider/
#
# Version: 0.0.1
# Author:  Thomas Kerin
# Contact: thomas.kerin@gmail.com
# Based on import by
#



# Get command line arguments

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -u|--username)
    USERNAME="$2"
    shift 
    ;;
    -p|--password)
    PASSWORD="$2"
    shift
    ;;
    -t|--tenant)
    TENANT="$2"
    shift
    ;;
    -a|--address)
    URL="$2"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

# Ask for argument values if not provided
if [ -z "$USERNAME" ]
then
	echo Username:
	read USERNAME
fi
if [ -z "$PASSWORD" ]
then
	echo Password:
	read -s PASSWORD
fi
if [ -z "$TENANT" ]
then
	echo "Tenant (leave blank for 'default'):"
	read TENANT
	if [ -z "$TENANT" ] 
	then
		TENANT='default'
	fi
fi
if [ -z "$URL" ]
then
	echo URL:
	read URL
fi

# Set up variables
OLDIFS=$IFS
INDEX=0
declare -A ACTUALID
#Set separator as comma (for CSV format)
IFS=,


# Make HTTP request
RESPONSE=$(curl -k -s \
	${URL}"api/v1/glaccounts" \
	-X GET \
	-H "Content-Type: application/json" \
	-H "Fineract-Platform-TenantId: $TENANT" \
	-u ${USERNAME}":"${PASSWORD} )

if [ $? -ne 0 ]; then
	echo "Request appears to have failed"
	exit 1;
fi

# Iterate over chart in reverse to process children first
IDS_TO_DELETE=$(jq -r '.[].id' <<< "$RESPONSE" | sort -r)

while read id; do
  ./delete-glaccount.sh -u $USERNAME -p $PASSWORD -t $TENANT -a $URL -i $id
  if [ $? -ne 0 ]; then
    echo "Failed to delete account $id"
    exit 1;
  fi
done <<<"$IDS_TO_DELETE"

IFS=$OLDIFS

