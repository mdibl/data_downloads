#!/bin/sh 

#
# Program: download_package 
#
# Original Author: lnh
#
# Purpose:
#
#	Download files from a remote server to our local download directory.
#       Each package will have its configuration file
#
# Usage : ./download_package package.config
# 
# Assumption: 
# A) In Configuration file:
#    1) EXTERNAL_DATA_BASE path is set 
#    2) DOWNLOADS_LOG_DIR directory is set
#
# B) In package-specific configuration file, the following global variables are set:
#    1) REMOTE_SITE  - package host - fetched from Configuration.default 
#    2) REMOTE_SITE_URL  - package site url (ftp://$REMOTE_SITE, http://$REMOTE_SITE, or https://$REMOTE_SITE)
#    3) REMOTE_DIR   - path to package on host
#    4) REMOTE_FILES - list of packages/files to fetch from host
#
#

# What it does:
# 1) source the Configuration file 
# 2) source the Package specific Configuration file to access global environment variables
# 3) setup path to files locally and remotely
# 4) if local_directory path does not exist create it
# 5) foreach file on the list, downloads a local copy
# 6) Write a log report
# 7) exit
#
#
# Note: This is a modification of what I implemented for MGI(mirror_wget)
# 
# Original Date: 2/25/2016
# Modification Date: 8/3/2017
#
WGET=`which wget`

if [ $# -lt 1 ]
then
   echo "-----------------------------------------------"
   echo ""
   echo "Usage: ./download_package annotation_config_file"
   echo ""
   echo "------------------------------------------------"
   exit 1
fi
cd `dirname $0`
WORKING_DIR=`pwd`
THIS_CONFIG_FILE=$1
SCRIPT_NAME=`basename $0`
#SERVER_NAME=`hostname -a`
SERVER_NAME=`uname -n`
#
# Check if package config file exists
#
if [ ! -f $THIS_CONFIG_FILE ]
then
  echo "The Configuration file $THIS_CONFIG_FILE is missing from $WORKING_DIR"
  exit 1
fi
#
#
# Check if the main config file exists
#
MAIN_CONFIG=$WORKING_DIR/Configuration

if [ ! -r $MAIN_CONFIG ]
then
  echo "The main Configuration file is missing from $WORKING_DIR"
  echo "Run the Install script "
  exit 1
fi
# source the main config file
. ${MAIN_CONFIG}

#source the config file specific to these annotations
. $THIS_CONFIG_FILE
#
#setup the log
package_file=`basename $THIS_CONFIG_FILE`
LOG_FILE="${DOWNLOADS_LOG_DIR}/$package_file.log"
rm -rf $LOG_FILE
touch $LOG_FILE
date | tee -a $LOG_FILE
#
# Set path of files on local server
#
if [ "$LOCAL_DIR" = "" ]
then
   LOCAL_DIR=$REMOTE_SITE$REMOTE_DIR
fi

LOCAL_DOWNLOAD_BASE=${EXTERNAL_DATA_BASE}/$LOCAL_DIR

#
# This are instances where you waant to store
if [ $loca_dir_is_absolute  ]
then
    LOCAL_DOWNLOAD_BASE=$LOCAL_DIR
fi
#
#LOG current setting 
#
echo "------------------------------" | tee -a $LOG_FILE
echo "***** Remote site setting *****" | tee -a $LOG_FILE
echo "------------------------------" | tee -a $LOG_FILE
echo "Remote site: $REMOTE_SITE" | tee -a $LOG_FILE
echo "Remote directory: $REMOTE_DIR" | tee -a $LOG_FILE
echo "Files to download: $REMOTE_FILES" | tee -a $LOG_FILE
echo "------------------------------" | tee -a $LOG_FILE
echo "***** Local setting *****" | tee -a $LOG_FILE
echo "------------------------------" | tee -a $LOG_FILE
echo "Working directory is:$WORKING_DIR" | tee -a $LOG_FILE
echo "Running $SCRIPT_NAME on Server :$SERVER_NAME" | tee -a $LOG_FILE
echo "config file used: $THIS_CONFIG_FILE" | tee -a $LOG_FILE
echo "download directory: $LOCAL_DOWNLOAD_BASE" | tee -a $LOG_FILE
echo "download logs directory: $DOWNLOADS_LOG_DIR" | tee -a $LOG_FILE
echo "log: $LOG_FILE" | tee -a $LOG_FILE
echo "------------------------------" | tee -a $LOG_FILE

#
# Set path of files on local server
# Make parent directories as needed
if [ ! -d $LOCAL_DOWNLOAD_BASE ]
then
   echo "Creating new directory $LOCAL_DOWNLOAD_BASE"
   mkdir -p $LOCAL_DOWNLOAD_BASE
fi

# attempt to set write lock
echo "Working directory is:$SERVER_NAME:`pwd`"

if [ $is_xml_query ]
then
   ##don't do the loop if this is a xml query string
   target_file="$REMOTE_SITE_URL$REMOTE_DIR/${REMOTE_FILES}"
   echo "---- $WGET $WGET_OPTIONS $target_file" | tee -a  ${LOG_FILE}
   cd ${LOCAL_DOWNLOAD_BASE}
   $WGET -a ${LOG_FILE} $WGET_OPTIONS "$target_file"
else
(
set -f
for remote_file in ${REMOTE_FILES}
do
   echo "$remote_file"
   target_file="$REMOTE_SITE_URL$REMOTE_DIR/$remote_file"
   ## get the directory part from the remote_file name
   target_local_dir=`dirname $remote_file`
   echo "Creating new directory $target_local_dir"
   #
   # Make parent directories as needed
   if [ "$target_local_dir" != "" ]
   then
      if [ ! -d ${LOCAL_DOWNLOAD_BASE}/$target_local_dir ]
      then
          echo "Creating new directory ${LOCAL_DOWNLOAD_BASE}/$target_local_dir"
          mkdir -p ${LOCAL_DOWNLOAD_BASE}/$target_local_dir
      fi
   fi
   #cd to LOCAL_DOWNLOAD_BASE and run wget command 
   cd ${LOCAL_DOWNLOAD_BASE}/$target_local_dir 
   # delete local files as needed
   if [ "$do_deletes" = true ]
   then
       rm -f $remote_file
   fi
   if [ "$IS_HTTP_PATTERN" = true ]
   then
       $WGET -a ${LOG_FILE} $WGET_OPTIONS -A "$remote_file" "$REMOTE_SITE_URL$REMOTE_DIR/" 
    else
       $WGET -a ${LOG_FILE} $WGET_OPTIONS "$target_file" 
    fi
done
)
fi

#
# Create symbolic link for this source if needed
#
if [ "$create_src_symlink" = true ]
then
  cd $EXTERNAL_DATA_BASE
  rm -f $source_name
  ln -s $REMOTE_SITE $source_name
fi

echo "$REMOTE_SITE annotations downloaded" | tee -a  ${LOG_FILE}
echo "Program complete" | tee -a  ${LOG_FILE}
echo "================================="| tee -a  ${LOG_FILE}
exit 0
