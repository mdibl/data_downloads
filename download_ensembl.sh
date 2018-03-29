#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: September 2017
# Modified: March 2018
#
# Wrapper script to download datasets from their download site. 
# This creates an additional log that could be use later on
#
# This script is called by the download manager script.
# Assumption: all the expected environment variables have been
# sourced by the caller.
#
cd `dirname $0`
WORKING_DIR=`pwd`
SCRIPT_NAME=`basename $0`
DATE=`date +"%B %d %Y"`
DATE=`echo $DATE | sed -e 's/[[:space:]]/-/g'`

WGET=`which wget`
GLOBAL_CONFIG=Configuration
#
# Set path of files on local server
if [ "${GLOBAL_CONFIG}" = "" ]
then
    echo "ERROR: global environment GLOBAL_CONFIG not set " 
    exit 1
fi
source ./${GLOBAL_CONFIG}

SOURCE_NAME=ensembl
PACKAGE_DOWNLOADS_BASE=${EXTERNAL_DATA_BASE}/${SOURCE_NAME}
RELEASE_FILE=${PACKAGE_DOWNLOADS_BASE}/${CURRENT_FLAG_FILE}
PACKAGE_CONFIG_FILE=${SOURCE_NAME}/${SOURCE_NAME}${PACKAGE_CONFIGFILE_SUFFIX}


if [ ! -f ${PACKAGE_CONFIG_FILE}]
then
    echo "ERROR: global environment PACKAGE_CONFIG_FILE not set " 
    exit 1
fi
if [ ! -f ${RELEASE_FILE} ]
then
   echo "Missing release flag file: ${RELEASE_FILE}"
   exit 1
fi
RELEASE_NUMBER=`cat ${RELEASE_FILE}`
source ./${PACKAGE_CONFIG_FILE}

PACKAGE_BASE=${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR}

LOG=${DOWNLOADS_LOG_DIR}/${SCRIPT_NAME}.${SHORT_NAME}.${RELEASE_DIR}.log
WGET_COMMAND="${WGET_OPTIONS} '${REMOTE_URL}'"
rm -f ${LOG}
touch ${LOG}

if [ "${DOWNLOADS_LOG_DIR}" = "" ]
then
    echo "ERROR: global environment DOWNLOADS_LOG_DIR not set "  | tee -a ${LOG}   
    exit 1
fi
if [ "${REMOTE_URL}" = "" ]
then
    echo "ERROR: global environment REMOTE_URL not set "  | tee -a ${LOG}   
    exit 1
fi
echo "==" | tee -a ${LOG}  
echo "Start Date:"`date` | tee -a ${LOG}  
echo "Package: ${SHORT_NAME} - ${RELEASE_DIR}"  | tee -a ${LOG}  
echo "Remote site: ${REMOTE_SITE}"  | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
echo "Local directory: ${PACKAGE_BASE}" | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
[ ! -d ${PACKAGE_BASE} ] && mkdir --parents ${PACKAGE_BASE}
(
set -f
for taxonomy in ${TAXA}
do
   
   for dataset in "${!DATASETS[@]}"
   do
       echo "${taxonomy}/${dataset}"
       REMOTE_DIR=${FTP_ROOT}/$RELEASE_DIR/${DATASETS_TYPE[$dataset]}
       REMOTE_FILE=$taxonomy/${dataset}/${DATASETS[$dataset]}
       README_FILE=$taxonomy/${dataset}/README
       echo "Processing: ${REMOTE_FILE}"
       echo " ${REMOTE_DIR}"
   done
   
done
)
echo "End Date:"`date` | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
echo ""
exit 0
