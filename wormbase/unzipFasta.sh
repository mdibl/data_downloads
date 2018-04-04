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

PACKAGE_CONFIG=`basename ${PACKAGE_CONFIG_FILE}`
if [ ! -f ${PACKAGE_CONFIG} ]
then
    echo "ERROR: global environment PACKAGE_CONFIG_FILE missing from `pwd` " 
    exit 1
fi
if [ ! -f ${RELEASE_FILE} ]
then
   echo "Missing release flag file: ${RELEASE_FILE}"
   exit 1
fi
RELEASE_NUMBER=`cat ${RELEASE_FILE} | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`

source ./${PACKAGE_CONFIG}

export PACKAGE_CONFIG_FILE PACKAGE_DOWNLOADS_BASE RELEASE_FILE DOWNLOADS_LOG_DIR MAIN_DOWNLOAD_SCRIPT
SCRATCH_DIR="$SCRATCH_DATA_BASE/$SHORT_NAME-$RELEASE_NUMBER"

PACKAGE_BASE=${PACKAGE_DOWNLOADS_BASE}/${RELEASE_DIR}/species"
if [ ! -d $SCRATCH_DIR ]
then
    mkdir -p $SCRATCH_DIR
fi
cd $SCRATCH_DIR
for organism in $TAXA
do
  organism_dir=$PACKAGE_BASE/$organism
  if [ ! -d $organism_dir ]
  then
     echo "ERROR: Missing directory $organism_dir"
     exit 1
  fi
  echo "===== $organism ====="
  for project in $PROJECTS
  do
    
      for dataset in $FASTA_ANNOTATIONS
      do
        dataset_dir=$SCRATCH_DIR/$project-$dataset
        FASTA_FILES=`ls $organism_dir | grep $project | grep $dataset |grep gz`
        ## Next if this project does not include this dataset
        [ -z "${FASTA_FILES}"  ] && continue 
        mkdir -p $dataset_dir
        cd $dataset_dir
        echo "Unzipping $organism_dir/$project*.$dataset dataset under $dataset_dir" 
        [ ! -d temp ] && mkdir temp
        OLD_FASTAS=`ls | grep .fa`
        [ -n "${OLD_FASTAS}" ] && mv *.fa temp
        for fasta_file in $FASTA_FILES
        do
           if [ -f $organism_dir/$fasta_file ]
           then
               echo "$fasta_file" 
               cp -p $organism_dir/$fasta_file .
               gunzip $fasta_file
           fi
        done
        rm -rf temp 
      done
     ## Create the joined transcriptome 
     #
     if [ -d $SCRATCH_DIR/$project-mRNA_transcripts ]
     then
         if [ -d $SCRATCH_DIR/$project-ncRNA_transcripts ]
         then
             joined_dir=$SCRATCH_DIR/$project-transcriptome_joined
             [ ! -d $joined_dir ] && mkdir $joined_dir
             joined_file=$joined_dir/$project-joined.fa
             cat $SCRATCH_DIR/$project-mRNA_transcripts/*.mRNA_transcripts.fa $SCRATCH_DIR/$project-ncRNA_transcripts/*.ncRNA_transcripts.fa > $joined_file
          fi
    fi
  done
done

echo ""
echo "Program complete"
date | tee -a $LOG

exit 0



