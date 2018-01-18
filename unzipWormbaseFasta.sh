#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date:  January 2018
#
# This script unzip the newly downloaded fasta
# files under the /data/scratch directory.
# Under /data/scratch , datasets are stored by source-version
# then by organism.project-dataset
#
# Example under  /data/scratch/wormbase-WS261/
# c_elegans.PRJNA13758-genomic 

cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`
RELEASE_NUMBER=0

if [ $# -lt 1 ]
then 
  echo "****************************************"
  echo ""
  echo "Usage: ./$SCRIPT_NAME path2/source_config.cfg"
  echo "Example: ./$SCRIPT_NAME wormbase/wormbase.cfg"
  echo "Where the source config path is relative to this script base"
  echo ""
  echo "****************************************"
  exit 1
fi
if [ ! -f $1 ]
then
  echo "ERROR: $1 config file missing from `pwd`"
fi

source ./Configuration
source ./$1
RELEASE_BASE=$EXTERNAL_DATA_BASE/$SHORT_NAME
SCRATCH_DIR=""
DATA_DIR=""

if [ -f $RELEASE_BASE/current_release_NUMBER ]
then
    RELEASE_NUMBER=`cat $RELEASE_BASE/current_release_NUMBER | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//'`
    SCRATCH_DIR="$SCRATCH_DATA_BASE/$SHORT_NAME-$RELEASE_NUMBER"
    DATA_DIR="$RELEASE_BASE/current/species"
    if [ ! -d $SCRATCH_DIR ]
    then
        mkdir -p $SCRATCH_DIR
    fi
fi 

if [ ! -d $SCRATCH_DIR ]
then
  echo "Failed to create $SCRATCH_DIR "
  exit 1
fi
LOG=$DOWNLOADS_LOG_DIR/$SCRIPT_NAME.$RELEASE_NUMBER.
rm -f $LOG
touch $LOG

date | tee -a $LOG

cd $SCRATCH_DIR

for organism in $TAXA
do
  organism_dir=$DATA_DIR/$organism
  if [ ! -d $organism_dir ]
  then
     echo "ERROR: Missing directory $organism_dir"
     exit 1
  fi
  echo ""
  echo "===== $organism ====="
  for project in $PROJECTS
  do
    
      for dataset in $FASTA_ANNOTATIONS
      do
        dataset_dir=$SCRATCH_DIR/$project-$dataset
        FASTA_FILES=`ls $organism_dir | grep $project | grep $dataset |grep gz`
        ## Next if this project does not include this dataset
        [ ${#FASTA_FILES[@]} -lt 1 ] && continue

        mkdir -p $dataset_dir
        cd $dataset_dir
        echo "Unzipping $organism_dir/$project*.$dataset dataset under $dataset_dir" | tee -a $LOG
        [ ! -d temp ] && mkdir temp
        OLD_FASTAS=`ls | grep .fa`
        [ ${#OLD_FASTAS[@]} -gt 0 ] && mv *.fa temp

        for fasta_file in $FASTA_FILES
        do
           if [ -f $organism_dir/$fasta_file ]
           then
               echo "$fasta_file" | tee -a $LOG
               cp -p $organism_dir/$fasta_file .
               gunzip $fasta_file
           fi
        done
        rm -rf temp 
      done
     ## Create the joined transcriptome - for c_elegans.PRJNA13758 project only
     #
     if [ "$project" = "c_elegans.PRJNA13758" ]
     then
        joined_dir=$SCRATCH_DIR/$project-transcriptome_joined
        [ ! -d $joined_dir ] && mkdir $joined_dir
        joined_file=$joined_dir/$oproject-joined.fa
        cat $SCRATCH_DIR/$project-mRNA_transcripts/*.mRNA_transcripts.fa $SCRATCH_DIR/$project-ncRNA_transcripts/*.ncRNA_transcripts.fa > $joined_file
     fi
  done
done

echo ""
echo "Program complete"
date | tee -a $LOG

exit 0




