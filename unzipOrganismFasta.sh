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
PYTHON=`which python`

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
  for dataset in "${!DATASETS_PATTERN[@]}"
  do
     dataset_dir=${SCRATCH_DIR}/${organism}-${dataset}
     organism_dataset_base=${organism_dir}
     [ -d ${organism_dir}/${dataset} ] && organism_dataset_base=${organism_dir}/${dataset}
     TARGET_FILES=`ls ${organism_dataset_base} | grep ${DATASETS_PATTERN[$dataset]} | grep ${ZIP_EXTENSION} `
     [ -z "${TARGET_FILES}"  ] && continue 
     mkdir -p ${dataset_dir}
     cd ${dataset_dir}
     [ ! -d temp ] && mkdir temp
     #OLD_FASTAS=`ls | grep .fa`
     OLD_FILES=`ls | grep ${DATASETS_PATTERN[$dataset]}`
     [ -n "${OLD_FILES}" ] && mv *${DATASETS_PATTERN[$dataset]}  temp
     for target_file in ${TARGET_FILES}
     do
        if [ -f ${organism_dataset_base}/$target_file ]
        then
              cp -p ${organism_dataset_base}/${target_file} .
              ${GUNZIP} ${target_file}
              if [ "${dataset}" == gtf ]
              then
                  $PYTHON ${WORKING_DIR}/${TX2GENE_SCRIPT} -f ${dataset_dir}/${target_file} -d ${dataset_dir}
              fi
        fi
     done
     rm -rf temp  
  done
  ## Create the joined transcriptome by combining 
  ## mRNA and ncRNA transcripts
  if [ -d ${SCRATCH_DIR}/${organism}-${MRNA_TR} ]
  then
      if [ -d ${SCRATCH_DIR}/${organism}-${NCRNA_TR} ]
      then
          joined_dir=${SCRATCH_DIR}/${organism}-transcriptome_joined
          [ ! -d ${joined_dir} ] && mkdir ${joined_dir}
          joined_file=${joined_dir}/${organism}-transcriptome-joined.fa
          cat ${SCRATCH_DIR}/${organism}-${MRNA_TR}/*.${MRNA_TR}.fa ${SCRATCH_DIR}/${organism}-${NCRNA_TR}/*.${NCRNA_TR}.fa >$joined_file
      fi
  fi
  #Create the mega file if this is dna dataset
  if [ "${GEN_MEGA_CHROMOSOME}" == true ]
  then
       genome_dir=${SCRATCH_DIR}/${organism}-genome
       [ ! -d ${genome_dir} ] && mkdir ${genome_dir}
       genome_file=${genome_dir}/${organism}.genome.fa
       [ ! -f ${genome_file} ] && cat ${SCRATCH_DIR}/${organism}-${CHROMOSOMES_DATASET}/${CHROMOSOMES} > ${genome_file}
  fi
  ## Generate gtf files
  
done

echo ""
echo "Program complete"
date 

exit 0




