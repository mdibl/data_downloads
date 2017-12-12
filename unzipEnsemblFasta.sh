#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: December  2017
#
# This script unzip the newly downloaded fasta
# files under the /data/scratch directory.
# Under /data/scratch , datasets are stored by source-version
# then by organism-dataset
#
# Example under  /data/scratch/ensembl-91/
# caenorhabditis_elegans-cdna    homo_sapiens-cdna
# caenorhabditis_elegans-cds     homo_sapiens-cds
# caenorhabditis_elegans-dna     homo_sapiens-dna
# caenorhabditis_elegans-ncrna   homo_sapiens-ncrna
# caenorhabditis_elegans-pep     homo_sapiens-pep
# danio_rerio-cdna               mus_musculus-cdna
# danio_rerio-cds                mus_musculus-cds
# danio_rerio-dna                mus_musculus-dna
# danio_rerio-ncrna              mus_musculus-ncrna
# danio_rerio-pep                mus_musculus-pep
# drosophila_melanogaster-cdna   saccharomyces_cerevisiae-cdna
# drosophila_melanogaster-cds    saccharomyces_cerevisiae-cds
# drosophila_melanogaster-dna    saccharomyces_cerevisiae-dna
# drosophila_melanogaster-ncrna  saccharomyces_cerevisiae-ncrna
# drosophila_melanogaster-pep    saccharomyces_cerevisiae-pep

cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`
RELEASE_NUMBER=0

if [ $# -lt 1 ]
then 
  echo "Usage: ./$SCRIPT_NAME souce_name/source_name.cfg"
  echo "Example: ./$SCRIPT_NAME ensembl/ensembl.cfg"
  exit 1
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
    DATA_DIR="$RELEASE_BASE/current"
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
  if [ -d $DATA_DIR/$organism ]
  then
     echo ""
     echo ""
     echo "===== $organism ====="
     for dataset in $FASTA_ANNOTATIONS
     do
        if [ -d $DATA_DIR/$organism/$dataset ]
        then 
           mkdir -p $SCRATCH_DIR/$organism-$dataset  
           cd $SCRATCH_DIR/$organism-$dataset
           echo "Unzipping $DATA_DIR/$organism/$dataset dataset under $SCRATCH_DIR/$organism-$dataset" | tee -a $LOG
           FASTA_FILES=`ls $DATA_DIR/$organism/$dataset | grep gz`
           for fasta_file in $FASTA_FILES
           do
              if [ -f $DATA_DIR/$organism/$dataset/$fasta_file ]
              then
                  echo "$fasta_file" | tee -a $LOG
                  cp -p $DATA_DIR/$organism/$dataset/$fasta_file .
                  gunzip $fasta_file
              fi
           done
           #Create the mega file if this is dna dataset
        fi
     done 
  fi
done

echo ""
echo "Program complete"
date | tee -a $LOG

exit 0




