#!/bin/bash
# 
# Given a release, this script generates a md5sum
# for each species/dataset
#
# Input: release base directory

cd `dirname $0`
md5sum=`which md5sum`
release_dir=$1
if [ ! -d $release_dir ]
then
   echo "ERROR: Argument 1 must be a directory"
   exit 1
fi
source ./wormbase_package.cfg

cd $release_dir
[ -d $ONTOLOGY_DIR ] && $md5sum $ONTOLOGY_DIR/* > $ONTOLOGY_DIR.md5sum
if [ -d $SPECIES_DIR ]
then
   cd $SPECIES_DIR
   declare -a datasets
   datasets=`ls`
   for dataset in ${datasets}
   do
      if [ -d $dataset ]
      then 
          echo "Genrating $dataset.md5sum"
          $md5sum $dataset/* > $dataset.md5sum
      else
          echo "Generating $dataset.md5sum "
          $md5sum $dataset > $dataset.md5sum
      fi
   done
fi
