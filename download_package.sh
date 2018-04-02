#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: September 2017
#
# Wrapper script to download a given package from its download site. 
# This creates an additional log that could be use later on

#
cd `dirname $0`
SCRIPT_NAME=`basename $0`
WGET=`which wget`

if [ $# -lt 3 ]
then
  echo "Usage: ./${SCRIPT_NAME} PACKAGE_CONFIG_FILE DOWNLOAD_DIR REMOTE_URL
fi
PACKAGE_CONFIG_FILE=$1
source ./${PACKAGE_CONFIG_FILE}
DOWNLOAD_DIR=$2
REMOTE_URL=$3
remote_file=`basename ${REMOTE_URL}`

WGET_COMMAND="${WGET_OPTIONS} '${REMOTE_URL}'"
[  ! -d ${DOWNLOAD_DIR} ] && mkdir -p ${DOWNLOAD_DIR}
 cd ${DOWNLOAD_DIR}
 
if [ ${is_xml_query} ]
then
   ##don't do the loop if this is a xml query string
   echo "---- ${WGET} ${WGET_OPTIONS} ${REMOTE_URL}" 
   ${WGET}  ${WGET_OPTIONS} "${REMOTE_URL}"
else
(
set -f
   # delete local files as needed
   if [ "${do_deletes}" = true ]
   then
       rm -f ${remote_file}
   fi
   if [ "${IS_HTTP_PATTERN}" = true ]
   then
       ${WGET} ${WGET_OPTIONS} -A "${remote_file}" "${REMOTE_URL}/" 
    else
       ${WGET}  ${WGET_OPTIONS} ${REMOTE_URL} 
    fi
 done
 )
 fi
 
echo "End Date:"`date` | tee -a ${LOG}  
echo "==" | tee -a ${LOG}  
echo ""
exit 0
