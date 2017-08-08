#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: August 2017
#
#Wrapper script to download Ensembl protein dataset
#
cd `dirname $0`
WORKING_DIR=`pwd`
SCRIPT_NAME=`basename $0`

if [ $# -lt 1 ]
then
  echo "Usage ./$SCRIPT_NAME annotation_config"
  exit 1
fi
#
#Relative to current working directory
#
DOWNLOAD_SCRIPT=../download_package
PEP_CONFIG=ftp.ensembl.org.pep.cfg
MAIN_CONFIG=../Configuration


if [ ! -f $MAIN_CONFIG ]
then
  echo "$MAIN_CONFIG file missing "     
  exit 1
fi
if [ ! -f $PEP_CONFIG ]
then
  echo "'$PEP_CONFIG' file missing under $WORKING_DIR"     
  exit 1
fi

# get global environment variable from config files
#
source ./$MAIN_CONFIG
source ./$PEP_CONFIG

SRC_NAME=$SHORT_NAME

LOG=$DOWNLOADS_LOG_DIR/$SCRIPT_NAME.$SRC_NAME.$RELEASE_NUMBER.log
rm -f $LOG
touch $LOG
echo "==" | tee -a $LOG
echo "Date:"`date` | tee -a $LOG
echo "Ensembl Release: $RELEASE_NUMBER"  | tee -a $LOG
echo "Ensembl Dataset: pep"  | tee -a $LOG
echo "Remote site: $REMOTE_SITE"  | tee -a $LOG
echo "Remote directory: $REMOTE_DIR"  | tee -a $LOG
echo "Local directory: $EXTERNAL_DATA_BASE/$LOCAL_DIR" | tee -a $LOG 
echo "==" | tee -a $LOG
echo "Remote files:" | tee -a $LOG
echo " $REMOTE_FILES" | tee -a $LOG
echo "==" | tee -a $LOG
echo "Running script from: $WORKING_DIR"| tee -a $LOG
echo "Command: ./$DOWNLOAD_SCRIPT $SRC_NAME/$PEP_CONFIG"| tee -a $LOG
echo "==" | tee -a $LOG

./$DOWNLOAD_SCRIPT $SRC_NAME/$PEP_CONFIG   2>&1 | tee -a $LOG

echo "=="
if [ $? -ne 0 ]
then
  echo "Status: FAILED" | tee -a $LOG
  exit 1
fi
echo "Status: SUCCESS" | tee -a $LOG
echo "=="
date | tee -a $LOG
echo ""
exit 0