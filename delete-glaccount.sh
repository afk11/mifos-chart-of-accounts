#!/bin/bash
#
# delete-glaccount.sh
# Delete a GLAccount using it's internal ID
#
# Usage:
#
# e.g. ./delete-glaccount.sh -u mifos -p password -t default -a https://domain.com:80/fineract-provider/ -i ID
#
# Version: 0.0.1
# Author:  Thomas Kerin
# Contact: thomas.kerin@gmail.com
#
# Based on import script by Steven Hodgson, steven@kanopi.asia
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
    -i|--id)
    DELETEID="$2"
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
if [ -z "$DELETEID" ]
then
	echo ID:
	read DELETEID
fi

# Set up variables
OLDIFS=$IFS
INDEX=0
declare -A ACTUALID
#Set separator as comma (for CSV format)
IFS=,


# Make HTTP request
RESPONSE=$(curl -k -s \
	${URL}"api/v1/glaccounts/$DELETEID" \
	-X DELETE \
	-H "Content-Type: application/json" \
	-H "Fineract-Platform-TenantId: $TENANT" \
	-u ${USERNAME}":"${PASSWORD} )

if [ $? -ne 0 ]; then
	echo "Request appears to have failed"
else
	# Check the server reponded successfully with {"resourceId":xx}
	if [[ "$RESPONSE" == *"resourceId"* ]]; then
		RESOURCEID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$RESPONSE")
		echo "Deleted GLAccount $RESOURCEID"
	else
		echo "[ERROR] Could not create general ledger account with name [$name]"
		echo "Response from server:"
		echo $RESPONSE
		exit 1
	fi
fi


IFS=$OLDIFS

