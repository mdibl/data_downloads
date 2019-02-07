#!/bin/bash
# 
# Given a release, this script generates a md5sum
# for each organism/dataset
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
source ./ensembl_package.cfg

for taxonomy in ${TAXA}
do
   taxonomy_dir=$release_dir/$taxonomy
   if [ -d $taxonomy_dir ]
   then
      cd $taxonomy_dir
      echo `pwd`
      #get dataset list
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
done 
