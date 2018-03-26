#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: August 2017
# Modified: March 2018
#
# This script returns the release number

cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`
RELEASE_NUMBER=0

if [ $# -lt 1 ]
then 
  echo "Usage: ./$SCRIPT_NAME souce_name/source_name.cfg"
  echo "Example: ./$SCRIPT_NAME ensembl/ensembl.cfg"
  exit 1
fi

source ./Configuration
source ./$1
RELEASE_BASE=$EXTERNAL_DATA_BASE/$SHORT_NAME

if [ -f $RELEASE_BASE/current_release_NUMBER ]
then
    cd $RELEASE_BASE
    RELEASE_NUMBER=`cat current_release_NUMBER | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`
    #Check if the release directory exists - then check if symbolic link 'current' exists
    RELEASE_DIR="$RELEASE_DIR_PREFIX$RELEASE_NUMBER"
    if [ -d $RELEASE_DIR ]
    then
        rm -f current
        ln -s $RELEASE_DIR current
    fi
fi 
echo "$RELEASE_NUMBER"

exit 0




