#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: August 2017
#
# This script returns the release number

cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`

if [ $# -lt 1 ]
then 
  echo "Usage: ./$SCRIPT_NAME souce_name/source_name.cfg"
  echo "Example: ./$SCRIPT_NAME ensembl/ensembl.cfg"
  exit 1
fi

source ./Configuration
source ./$1

RELEASE_BASE=$EXTERNAL_DATA_BASE/$SHORT_NAME
RELEASE_NUMBER=0
if [ -d $RELEASE_BASE ]
then
  cd $RELEASE_BASE
  RELEASE_NUMBER=`cat current_release_NUMBER | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`
fi
echo "$RELEASE_NUMBER"

exit 0




