#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date:  April 2018
#
# Wrapper script to call getSourceVersion.sh/setSourceVersion.sh and runGetDataset.sh scripts
# To download the current version of the Data source.
# If a second argument is specified, then it's used as the version
# to download
# 
#
# What it does:
# 1) sources global configs
# 2) Calls the appropriate getSourceVersion.sh/setSourceVersion.sh to update the release flag file
# 3) Check if the specified tool version is installed
# 4) Trigger the downlaod if the specified source's version is not installed
#

cd `dirname $0`
WORKING_DIR=`pwd`
SCRIPT_NAME=`basename $0`
GLOBAL_CONFIG=Configuration
function displayDataSources() {
    echo ""
    echo " List of available data sources"
    echo "---------------------------"
    sources="`ls`"
    for datasource in ${sources}
    do
       [ -d ${datasource} ] && echo " ${datasource}"
    done
    echo ""
}


if [ $# -lt 1 ]
then
  echo "***********************************************"
  echo ""
  echo "Usage: ./${SCRIPT_NAME} source_name [source_version]"
  echo ""
  echo "Example: ./${SCRIPT_NAME} ensembl [91]"
  echo ""
  echo "A trigger that calls scripts involved in the download of a new data source."
  echo "If a second argument is specified,then it's used as the version to download."
  echo "It triggers the install only if the specified tool version is not installed."
  echo ""
  echo "NOTE: If you provide the source_version argument, "
  echo "make sure the format follows the pattern specified in REPOS_TAG_PATTERN variable "
  echo "in the source's config file (*_package.cfg)"
  displayDataSources
  exit 1
fi
SOURCE_NAME=$1

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

PACKAGE_DOWNLOADS_BASE=${EXTERNAL_DATA_BASE}/${SOURCE_NAME}
PACKAGE_CONFIG_FILE=${SOURCE_NAME}/${SOURCE_NAME}${PACKAGE_CONFIGFILE_SUFFIX}
LOCAL_DOWNLOAD_SCRIPT=${SOURCE_NAME}/${DOWNLOAD_SCRIPT}
LOG=$DOWNLOADS_LOG_DIR/$SCRIPT_NAME.${SOURCE_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "==" | tee -a ${LOG}
echo "Start Date:"`date` | tee -a ${LOG}

if [ ! -f ${PACKAGE_CONFIG_FILE} ]
then
  echo "${SOURCE_NAME}'S confifiguration file: '${PACKAGE_CONFIG_FILE}' missing under `pwd`" 
  exit 1
fi
if [ ! -f ${LOCAL_DOWNLOAD_SCRIPT} ]
then
     #We use the generic download script for this source downloads
     export PACKAGE_CONFIG_FILE PACKAGE_DOWNLOADS_BASE DOWNLOADS_LOG_DIR
     ./${DOWNLOAD_SCRIPT}  2>&1 | tee -a ${LOG}
     echo "== " | tee -a ${LOG}
     echo "Sanity Check on : ${LOG}" | tee -a 
     download_status=`getLogStatus ${LOG}`
     echo "${download_status}" | tee -a $LOG
     [ "${download_status}" != Success ] && exit 1
else 
    ## We use this source's specific download script for data downloads
    ## Update the release flag file
    if [ $# -lt 2 ]
    then 
        echo "Running cmd: ./${GET_SOURCE_VERSION_SCRIPT} ${SOURCE_NAME}  -- from `pwd`"
        ./${GET_SOURCE_VERSION_SCRIPT} ${SOURCE_NAME}
     else
        SOURCE_VERSION=$2
        echo "Running cmd:  ./{SET_SOURCE_VERSION_SCRIPT}  ${SOURCE_NAME} ${SOURCE_VERSION}  -- from `pwd` "
        ./${SET_SOURCE_VERSION_SCRIPT}  ${SOURCE_NAME} ${SOURCE_VERSION}
     fi
     if [ $? -ne 0 ]
     then
         echo "Cmd Status: FAILED"
         exit 1
     fi
     RELEASE_FILE=${PACKAGE_DOWNLOADS_BASE}/${CURRENT_FLAG_FILE}
     if [ ! -f ${RELEASE_FILE} ]
     then
        echo "ERROR: ${RELEASE_FILE} file missing"
        exit 1
     fi
     RELEASE_NUMBER=`cat ${RELEASE_FILE}`
     #if this version of the tool is already installed, do run run the main install script
     source ./${PACKAGE_CONFIG_FILE}
     [ -d ${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR} ] && exit 1
     ## Run the main download script to get the version  found in current_release file 
     echo "Running cmd: ./${GET_PACKAGE_MAIN_SCRIPT} ${SOURCE_NAME}  -- from `pwd`"
     ./${GET_PACKAGE_MAIN_SCRIPT} ${SOURCE_NAME}
fi
