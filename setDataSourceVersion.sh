#!/bin/sh
#
# Organization: MDIBL
# Author: Lucie Hutchins
# Date: March 2018
# What it does:
#  1) sets the current release number flag with
#.    a specific release version
#
#
cd `dirname $0`
 
SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`
GLOBAL_CONFIG=Configuration
date | tee -a ${LOG_FILE}

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

echo "
***************************************
 BIOCORE External Data Downloads AUTOMATION 
***************************************
"

## Validate usage
if [ $# -lt 2 ]
then
    echo "Usage: ./${SCRIPT_NAME} source_name version"
    echo "example: ./${SCRIPT_NAME} ensembl 91"
    displayDataSources
    exit 1
fi

SOURCE_NAME=$1
RELEASE_NUMBER=$2

if [ ! -d ${SOURCE_NAME} ]
then
   echo "ERROR: No automation found for ${SOURCE_NAME}"
   echo "Check the spelling or the case sensitive"
   displayDataSources
   exit 1
fi
if [ ! -f ${GLOBAL_CONFIG} ]
then
  echo "ERROR: ${GLOBAL_CONFIG} file missing  under:${WORKING_DIR}"     
  echo "Make sure you run the ./setup.sh script first  under:${WORKING_DIR}"     
  exit 1
fi
source ./${GLOBAL_CONFIG}
#
## Path relative to this package install base
PACKAGE_DOWNLOADS_BASE=${EXTERNAL_DATA_BASE}/${SOURCE_NAME}
RELEASE_FILE=${PACKAGE_DOWNLOADS_BASE}/${CURRENT_FLAG_FILE}
[ ! -d ${PACKAGE_DOWNLOADS_BASE} ] && mkdir -p ${PACKAGE_DOWNLOADS_BASE}

LOG_FILE="${DOWNLOADS_LOG_DIR}/${SCRIPT_NAME}.${SOURCE_NAME}.log"

rm -rf ${LOG_FILE}
touch ${LOG_FILE}
echo "------------------------------"
RELEASE_NUMBER=`echo $RELEASE_NUMBER | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`

## Create/Update the current release Number file
echo "Setting ${SOURCE_NAME} release number to : ${RELEASE_NUMBER}"
if [[ ${RELEASE_NUMBER} =~ ${REPOS_TAG_PATTERN} ]]
then
   rm -f ${RELEASE_FILE}
   touch ${RELEASE_FILE}
   echo "${RELEASE_NUMBER}" > ${RELEASE_FILE}
fi
if [ ! -f ${RELEASE_FILE} ]
then
   echo "Missing release flag file: ${RELEASE_FILE}"
   exit 1
fi
RELEASE_NUMBER=`cat ${RELEASE_FILE}`
echo "${SOURCE_NAME}'s Release version $RELEASE_NUMBER set in ${RELEASE_FILE}"| tee -a ${LOG_FILE}
cd ${WORKING_DIR}
#
## Path relative to this script base
PACKAGE_CONFIG_FILE=${SOURCE_NAME}/${SOURCE_NAME}${PACKAGE_CONFIGFILE_SUFFIX}
if [ ! -f ${PACKAGE_CONFIG_FILE} ]
then
    echo "ERROR: ${PACKAGE_CONFIG_FILE} missing under: ${WORKING_DIR}"
    exit 1
fi
source ./${PACKAGE_CONFIG_FILE}
echo ""
if [ -d ${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR} ]
then
    echo "WARNING"
    echo "  ${SOURCE_NAME} version $RELEASE_NUMBER is already installed."
    echo "  See: ${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR} "
    echo "  Remove this directory first if you want to re-downlaod this version"
fi
echo ""| tee -a ${LOG_FILE}
echo "Program complete"| tee -a ${LOG_FILE}
exit 0
