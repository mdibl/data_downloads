#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date:  April 2018
#
# This script unzip the newly downloaded fasta
# files under the /data/scratch directory.
# Under /data/scratch , datasets are stored by source-version
# then by organism.project-dataset
#
# Example under  /data/scratch/wormbase-WS261/
#
# This script is called by the download manager script.
# Assumption: all the expected environment variables have been
# sourced by the caller.
#
cd `dirname $0`
SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`
GUNZIP=`which  gunzip`

if [ ! -f ${GLOBAL_CONFIG} ]
then
  echo "ERROR: global environment GLOBAL_CONFIG not set by the caller" 
  exit 1
fi
if [ ! -d ${PACKAGE_DOWNLOADS_BASE} ]
then
  echo "ERROR: global environment PACKAGE_DOWNLOADS_BASE not set by the caller" 
  exit 1
fi
if [ ! -f ${PACKAGE_CONFIG_FILE} ]
then
    echo "ERROR: global environment PACKAGE_CONFIG_FILE not set by the caller " 
    exit 1
fi
if [ ! -f ${RELEASE_FILE} ]
then
   echo "ERROR: global environment RELEASE_FILE not set by the caller"
   exit 1
fi

RELEASE_NUMBER=`cat ${RELEASE_FILE} | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`
source ./${GLOBAL_CONFIG}
source ./${PACKAGE_CONFIG_FILE}

SCRATCH_DIR=${SCRATCH_DATA_BASE}/${SHORT_NAME}-${RELEASE_NUMBER}
PACKAGE_BASE=${PACKAGE_DOWNLOADS_BASE}/${ORGANISMS_DOWNLOAD_DIR}

[ ! -d ${SCRATCH_DIR} ] && mkdir -p ${SCRATCH_DIR}
cd ${SCRATCH_DIR}
for organism in ${TAXA}
do
  organism_dir=${PACKAGE_BASE}/${organism}
  if [ ! -d $organism_dir ]
  then
     echo "ERROR: Missing directory $organism_dir"
     exit 1
  fi
  for dataset in "${!DATASETS[@]}"
  do
     dataset_dir=${SCRATCH_DIR}/${organism}-${dataset}
     dataset_file=${dataset}.fa${ZIP_EXTENSION}
     FASTA_FILES=`ls ${organism_dir} | grep ${dataset_file}`
     echo "Unzipping ${organism_dir}/*${dataset_file} dataset under `pwd`" 
     ## Next if this project does not include this dataset
     [ -z "${FASTA_FILES}"  ] && continue 
     mkdir -p ${dataset_dir}
     cd ${dataset_dir}
     [ ! -d temp ] && mkdir temp
     OLD_FASTAS=`ls | grep .fa`
     [ -n "${OLD_FASTAS}" ] && mv *.fa temp
     for fasta_file in ${FASTA_FILES}
     do
        if [ -f $organism_dir/$fasta_file ]
        then
              cp -p ${organism_dir}/${fasta_file} .
              ${GUNZIP} ${fasta_file}
        fi
     done
     rm -rf temp 
     ## Create the joined transcriptome 
     #
     if [ -d $SCRATCH_DIR/${organism}-${MRNA_TR} ]
     then
         if [ -d $SCRATCH_DIR/${organism}-${NCRNA_TR} ]
         then
             joined_dir=$SCRATCH_DIR/${organism}-transcriptome_joined
             [ ! -d $joined_dir ] && mkdir $joined_dir
             joined_file=$joined_dir/$project-joined.fa
             cat $SCRATCH_DIR/${organism}-${MRNA_TR}/*.${MRNA_TR}.fa $SCRATCH_DIR/${organism}-${NCRNA_TR}/*.${NCRNA_TR}.fa > $joined_file
          fi
    fi
  done
done

echo ""
echo "Program complete"
date | tee -a $LOG

exit 0




