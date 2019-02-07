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
SCRIPT_NAME=`basename $0`
SCRIPT_DIR=`pwd`
DATE=`date +"%B %d %Y"`
DATE=`echo $DATE | sed -e 's/[[:space:]]/-/g'`
WGET=`which wget`
md5sum_prog=gen_md5sum.sh

PACKAGE_CONFIG=`basename ${PACKAGE_CONFIG_FILE}`
if [ ! -f ${PACKAGE_CONFIG} ]
then
    echo "ERROR: global environment ${PACKAGE_CONFIG} missing from `pwd` " 
    exit 1
fi
if [ ! -f ${RELEASE_FILE} ]
then
   echo "Missing release flag file: ${RELEASE_FILE}"
   exit 1
fi
if [ ! -f $WGET ]
then
  echo "ERROR: wget not installed on `uname -n`"
  exit 1
fi
RELEASE_NUMBER=`cat ${RELEASE_FILE}`

source ./${PACKAGE_CONFIG}

PACKAGE_BASE=${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR}

LOG=${DOWNLOADS_LOG_DIR}/${SCRIPT_NAME}.${SHORT_NAME}.${RELEASE_DIR}.log
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
echo "Local directory: ${PACKAGE_BASE}" | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
[ ! -d ${PACKAGE_BASE} ] && mkdir --parents ${PACKAGE_BASE}
echo "-------------------------------------"
echo "Using Wget to Download datasets"| tee -a ${LOG}
echo ""
echo ">>>>>>>> Wget output starts here " | tee -a ${LOG}
(
set -f
for taxonomy in ${TAXA}
do
     DOWNLOAD_DIR=${PACKAGE_BASE}/${SPECIES_DIR}/${taxonomy}
     mkdir -p ${DOWNLOAD_DIR}
     cd ${DOWNLOAD_DIR}
     REMOTE_FILE=${SPECIES_DIR}/$taxonomy/*
     REMOTE_URL=${REMOTE_SITE}${REMOTE_DIR}/${REMOTE_FILE}
     ${WGET}  ${WGET_OPTIONS} ${REMOTE_URL} 2>&1 | tee -a ${LOG}
done
)

cd ${PACKAGE_BASE}
mkdir -p ${ONTOLOGY_DIR}
cd ${ONTOLOGY_DIR}
(
set -f
for annotation in "${!ONTOLOGY[@]}"
do
    REMOTE_FILE=${ONTOLOGY_DIR}/${ONTOLOGY[$annotation]}
    ## Remote path to this dataset files
    REMOTE_URL=${REMOTE_SITE}${REMOTE_DIR}/${REMOTE_FILE}
    remote_file=`basename ${REMOTE_URL}`
    if [ "${IS_HTTP_PATTERN}" = true ]
    then
         ${WGET} ${WGET_OPTIONS} -A ${remote_file} "${REMOTE_URL}/"  2>&1 | tee -a ${LOG}
    else
         ${WGET}  ${WGET_OPTIONS} ${REMOTE_URL} 2>&1 | tee -a ${LOG}
    fi 
done
)
echo "<<<<<<<< Wget output ends here " | tee -a ${LOG}
echo ""
## generate the md5sum
cd $SCRIPT_DIR
./$md5sum_prog ${PACKAGE_BASE}
echo "End Date:`date`" | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
echo ""
exit 0
