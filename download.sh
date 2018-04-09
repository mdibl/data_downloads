#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: April 2018
#
# Wrapper script to download datasets from their download site. 
# This creates an additional log that could be use later on
#
# This script is called by the download manager script.
# Assumption: all the expected environment variables have been
# sourced by the caller.
#
cd `dirname $0`
SCRIPT_NAME=`basename $0`
DATE=`date +"%B %d %Y"`
DATE=`echo $DATE | sed -e 's/[[:space:]]/-/g'`
WGET=`which wget`

if [ ! -f ${PACKAGE_CONFIG_FILE} ]
then
    echo "ERROR: global environment PACKAGE_CONFIG_FILE not set " 
    exit 1
fi
RELEASE_NUMBER=""
[ -f ${RELEASE_FILE} ] && RELEASE_NUMBER=`cat ${RELEASE_FILE}`

source ./${PACKAGE_CONFIG_FILE}

PACKAGE_BASE=${PACKAGE_DOWNLOADS_BASE}
[ "${HAS_RELEASE}" = true] && PACKAGE_BASE=${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR}

LOG=${DOWNLOADS_LOG_DIR}/${SCRIPT_NAME}.${SHORT_NAME}.log

rm -f ${LOG}
touch ${LOG}
if [ "${DOWNLOADS_LOG_DIR}" = "" ]
then
    echo "ERROR: global environment DOWNLOADS_LOG_DIR not set "  | tee -a ${LOG}   
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
echo "-------------------------------------"
echo "Using Wget to Download datasets"| tee -a ${LOG}
echo ""
echo ">>>>>>>> Wget output starts here " | tee -a ${LOG}
(
set -f
for dataset in "${!DATASETS[@]}"
do
  DOWNLOAD_DIR=${PACKAGE_BASE}/${dataset}
  mkdir -p ${DOWNLOAD_DIR}
  cd ${DOWNLOAD_DIR}
  REMOTE_FILES=${DATASETS[$dataset]}
  for REMOTE_FILE in ${REMOTE_FILES}
  do
      ## Remote path to this dataset files
      REMOTE_URL=${REMOTE_SITE}/${REMOTE_FILE}
      remote_file=`basename ${REMOTE_URL}`
      if [ "${IS_HTTP_PATTERN}" = true ]
      then
          ${WGET} ${WGET_OPTIONS} -A ${remote_file} "${REMOTE_URL}/"  2>&1 | tee -a ${LOG}
      else
          ${WGET}  ${WGET_OPTIONS} ${REMOTE_URL}  2>&1 | tee -a ${LOG}
      fi 
  done
done
)
echo "End Date:`date`" | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
echo ""
exit 0
