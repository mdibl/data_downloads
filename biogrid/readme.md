
## What Do We Download From BioGRID -  https://downloads.thebiogrid.org?

### Annotations : /BioGRID/Release-Archive/BIOGRID-$RELEASE_NUMBER
  * BIOGRID-ALL-3.4.160.tab2.zip
 
  
### BioGRID downloads frequency

Since it's not easy task to programatically get the release information of this data source
from their download site, 
we will set the updates to run on demand - with the release info being
passed to the downloader script as an argument.

```
Usage: ./${DATA_DOWNLOADS_DIR}/trigger_download.sh biogrid version_numebr

Example: ./${DATA_DOWNLOADS_DIR}/trigger_download.sh biogrid 3.4.160


```
See: https://jenkins.mdibl.org/job/BioGRID/
