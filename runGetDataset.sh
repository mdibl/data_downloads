#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: September 2017
# Modified: April 2018
#
# Wrapper script to call scripts that download  external data.
# It creates an additional log that could be use later on.
#
# What it does:
# 1) sources global configs
# 2) Calls the appropriate download script to download the specified version of this datasets
# 3) Updates the tool symbolic link on success 

cd `dirname $0`
WORKING_DIR=`pwd`
SCRIPT_NAME=`basename $0`
GLOBAL_CONFIG=Configuration
#
## Diplays list of available external sources
function displayTools() {
    echo ""
    echo " List of available tools"
    echo "----------------------------"
    tools="`ls`"
    for tool in ${tools}
    do
       [ -d ${tool} ] && echo " ${tool}"
    done
    echo ""
}
echo "
***************************************
 BIOCORE External Data Download AUTOMATION 
***************************************
A package to create automations that downloads
commonly used bioinformatics datasets. 
"
if [ $# -lt 1 ]
then
  echo "Usage: ./${SCRIPT_NAME} source_name"
  echo "Example: ./${SCRIPT_NAME} ensembl"
  displayTools
  exit 1
fi
SOURCE_NAME=$1
if [ ! -d ${SOURCE_NAME} ]
then
   echo "ERROR: No automation found for ${SOURCE_NAME}"
   echo "Check the spelling or the case sensitive"
   displayTools
   exit 1
fi
##The config file is relative to
# the root directory of package download 

if [ ! -f ${GLOBAL_CONFIG} ]
then
  echo "'${GLOBAL_CONFIG}' file missing under `pwd`" 
  echo "You must run the setup.sh script first to generate this file"
  echo "Usage: ./setup.sh "
  exit 1
fi
source ./${GLOBAL_CONFIG}

## Checks logs for failure 
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
            rstatus="Failure"
            echo "Found: \"$error_found\" "   
        fi
  done
  echo "$rstatus" 
}
# Create base directories if not exist
# Make sure the directory is not empty or
# the main root directory "/" 
#
[ ! -d ${DOWNLOADS_LOG_DIR} ] && mkdir -p ${DOWNLOADS_LOG_DIR}

PACKAGE_DOWNLOADS_BASE=${EXTERNAL_DATA_BASE}/${SOURCE_NAME}
RELEASE_FILE=${PACKAGE_DOWNLOADS_BASE}/${CURRENT_FLAG_FILE}
PACKAGE_CONFIG_FILE=${SOURCE_NAME}/${SOURCE_NAME}${PACKAGE_CONFIGFILE_SUFFIX}

export PACKAGE_CONFIG_FILE PACKAGE_DOWNLOADS_BASE RELEASE_FILE DOWNLOADS_LOG_DIR GLOBAL_CONFIG

LOG=$DOWNLOADS_LOG_DIR/$SCRIPT_NAME.${SOURCE_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "==" | tee -a ${LOG}
echo "Start Date:"`date` | tee -a ${LOG}

./${SOURCE_NAME}/download.sh  2>&1 | tee -a ${LOG}

cd ${WORKING_DIR}
RELEASE_NUMBER=`cat ${RELEASE_FILE}`
source ./${PACKAGE_CONFIG_FILE}

download_log=${DOWNLOADS_LOG_DIR}/${DOWNLOAD_SCRIPT}.${SOURCE_NAME}.${RELEASE_DIR}.log
echo "== " | tee -a ${LOG}
echo "Sanity Check on : ${download_log} " | tee -a ${LOG}

download_status=`getLogStatus ${download_log}`
echo "${download_status}" | tee -a $LOG
[ "${download_status}" != Success ] && exit 1

## update the symbolic link to point to the lasted download version
cd ${PACKAGE_DOWNLOADS_BASE}
rm -f current
ln -s ${RELEASE_DIR} current
cd ${WORKING_DIR}
if [ "${UNZIP_FILES}" == true ]
then
  ./${UNZIP_FILES_SCRIPT}
fi
echo "=="
echo "End Date:"`date` | tee -a $LOG
echo ""
exit 0
