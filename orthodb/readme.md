Base directory to store Orthodb downloads scripts and config files

# What Do We Download From OrthoDB -  http://www.orthodb.org ?

## Annotations : /$RELEASE_NUMBER/download
  * README.txt
  * odb9v1_OG2genes.tab.gz 
  * odb9v1_OGs.tab.gz
  * odb9v1_species.tab.gz
  * odb9v1_genes.tab.gz
  * odb9v1_levels.tab.gz
  
## OrthoDB downloads frequency

Since it's not easy task to programatically get the release information of this data source
from their download site, 
we will set the updates to run on demand - with the release info being
passed to the downloader script as an argument.

```
Usage: ./${DATA_DOWNLOADS_DIR}/trigger_download.sh orthodb version_numebr

Example: ./${DATA_DOWNLOADS_DIR}/trigger_download.sh orthodb v9.1


```
See: https://jenkins.mdibl.org/job/Orthodb/
