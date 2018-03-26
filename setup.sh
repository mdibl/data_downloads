#!/bin/sh

#
# Organization: MDIBL
# Author: Lucie Hutchins
# Date: March 2018

#
cd `dirname $0`
echo " "
echo "************* Data Downloads Setup ****************"

if [ -f Configuration ]
then
  rm Configuration
fi
cp Configuration.default Configuration

source  ./Configuration

EXECUTABLES=`ls | grep .sh`
for script_name in ${EXECUTABLES}
do
  [ "${script_name}" == "setup.sh" ] && continue
  chmod 755 $script_name
done
echo ""
echo "Path to data_downloads base: `pwd`"
echo "*****************************************************"
echo ""
echo "Next: Update the file 'Configuration' "
echo " "
echo "  Set:"
echo "  EXTERNAL_DATA_BASE=path2/datasets_root     -- full path to where external data will be stored..."
echo "  SCRATCH_DATA_BASE=path2/unzipped_data      --  full path to where unzipped data should be stored "
echo "  LOGS_BASE=path2/logs_base  --  full path to the logs base"
echo ""
echo ""
