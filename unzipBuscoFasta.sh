#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date:  October 2019
#
# This script unzip the newly downloaded fasta
# files under the /data/scratch directory.
# Under /data/scratch , datasets are stored by source-version
#
# Example under  /data/scratch/mgi/
#
# This script is called by the download manager script.
# Assumption: all the expected environment variables have been
# sourced by the caller.
#
cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`

SHORT_NAME=busco_lineages
GLOBAL_CONFIG=Configuration
ZIP_EXTENSION=tar.gz

if [ ! -f ${GLOBAL_CONFIG} ]
then
  echo "ERROR: global environment GLOBAL_CONFIG not set by the caller" 
  exit 1
fi
source ./${GLOBAL_CONFIG}
PACKAGE_CONFIG_FILE=$SHORT_NAME/${SHORT_NAME}$PACKAGE_CONFIGFILE_SUFFIX
if [ ! -f ${PACKAGE_CONFIG_FILE} ]
then
    echo "ERROR: global environment PACKAGE_CONFIG_FILE not set by the caller " 
    exit 1
fi
CRELEASE_FILE=${EXTERNAL_DATA_BASE}/${SHORT_NAME}/$CURRENT_FLAG_FILE
if [ ! -f ${CRELEASE_FILE} ]
then
   echo "ERROR: global environment RELEASE_FILE ${CRELEASE_FILE} not set by the caller"
   exit 1
fi
RELEASE_NUMBER=`cat ${CRELEASE_FILE} | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`

source ./${PACKAGE_CONFIG_FILE}
SCRATCH_DIR=${SCRATCH_DATA_BASE}/${SHORT_NAME}-${RELEASE_NUMBER}
PACKAGE_BASE=${EXTERNAL_DATA_BASE}/${SHORT_NAME}/$RELEASE_DIR

[ ! -d ${SCRATCH_DIR} ] && mkdir -p ${SCRATCH_DIR}
cd ${SCRATCH_DIR}
for dataset in "${!DATASETS[@]}"
do
     dataset_dir=${SCRATCH_DIR}/${dataset}
     TARGET_FILES=`ls $PACKAGE_BASE/$dataset | grep ${ZIP_EXTENSION} `
     echo "Calling command: ls $PACKAGE_BASE/$dataset | grep ${ZIP_EXTENSION}"
     [ -z "${TARGET_FILES}"  ] && continue 
     mkdir -p ${dataset_dir}
     cd ${dataset_dir}
     for target_file in ${TARGET_FILES}
     do
        echo "Expanding: ${PACKAGE_BASE}/$dataset/$target_file"
        if [ -f ${PACKAGE_BASE}/$dataset/$target_file ]
        then
              cp -p ${PACKAGE_BASE}/$dataset/${target_file} .
              tar -xvzf ${target_file}
        fi
     done
done
echo ""
echo "Program complete"
date 

exit 0




