#!/bin/sh
#
# This script checks logs generated
# from wget process for errors
# It is called after each data download
# (ensembl, ncbi, ...)
#
# Usage: ./check_logs.sh report_out_file list_of_log_files
# Example: 
# ./check_logs.sh $MIRRORLOGS/ensembl.sh.log $DOWNLOADS_LOG_DIR/logfile1.log ... $DOWNLOADS_LOG_DIR/logfile_n.log  
#
# Author: lnh
# Date : August 2017
#
log_report=""
LOG_FILES=""

if [ $# -lt 2 ]
then
   echo "Usage: ./check_mirror_log.sh report_out_file list_of_log_files "
   exit 1
fi
# Source mgiconfig master config file
cd `dirname $0`
WORKING_DIR=`pwd`
#
# Check if the main config file exists
#
MAIN_CONFIG=$WORKING_DIR/Configuration
if [ ! -r $MAIN_CONFIG ]
then
  echo "The main Configuration file is missing from $WORKING_DIR"
  echo "Run the Install script "
  exit 1
fi
# source the main config file
. ${MAIN_CONFIG}

date

log_report=$1
LOG_FILES=$2

ERROR_TERMS=("Fatal"
"Failure"
"failed"
"ERROR 404: Not Found"
"timed out"
"No such file or directory")

function getLogStatus() {
  log=$1
  IFS=""
  rstatus="Success"
  for ((i = 0; i < ${#ERROR_TERMS[@]}; i++))
  do
       error_term=${ERROR_TERMS[$i]}
       error_found=`grep -i $error_term $log `
       if [ "$error_found" != "" ]
       then
            rstatus="Failed"
            echo "Found: \"$error_found\" "   
        fi
  done
  echo "Status: $rstatus" 
}
#clean previous report
rm -rf $log_report
touch $log_report
date | tee -a $log_report
run_status=""
for log in $LOG_FILES
do
  if [ ! -f $log ]
  then
       echo "--------------------------------------- " | tee -a $log_report
       echo "Sanity Check on : $log " | tee -a $log_report
       echo "ERROR: $log does not exist " | tee -a $log_report
       echo "Status: Failed " | tee -a $log_report
       continue
   fi
   echo "--------------------------------------- " | tee -a $log_report
   echo "Sanity Check on : $log " | tee -a $log_report
   echo "**************************************"| tee -a $log_report
   getLogStatus $log | tee -a $log_report
   echo "--------------------------------------- " | tee -a $log_report
done
echo "Logs check done " | tee -a $log_report
date | tee -a $log_report

mailx -s "MIRROR: $log_report" $EMAIL_TO < $log_report
