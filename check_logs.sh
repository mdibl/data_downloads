#!/bin/sh
#
# This script checks logs generated
# from wget process for errors
# It is called after each data download
# (ensembl, ncbi, ...)
#
# Usage: ./check_logs.sh list_of_log_files
# Example: 
# ./check_logs.sh $DOWNLOADS_LOG_DIR/ftp.ensembl.org
#
# Author: Lucie Hutchins 
# Date : August 2017
#
log_report=""
LOG_FILES=""

if [ $# -lt 1 ]
then
   echo "Usage: ./check_logs.sh path2/list_of_log_files "
   echo "Example:"
   echo "./check_logs.sh DOWNLOADS_LOG_DIR/ftp.ensembl.org"
   exit 1
fi
date

LOG_BASE=`dirname $1`
log_prefix=`basename $1`
log_report="$LOG_BASE/$log_prefix-check_logs.log"
LOG_FILES="$log_prefix.*"

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
