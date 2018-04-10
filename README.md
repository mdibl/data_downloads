
# Biocore Data Downloads Repos

A repository to create automations that download external bioinformatics Datasets.

For each database source, this package can be setup to run an automation that checks if a new version of the database is available. As soon as it detects a new release , the automation will download it locally.

## What It Does

For each database source,the automation creates a root directory that is the name of the database in the path set in the main Configuration (EXTERNAL_DATA_BASE). The organization of files under these root directories
will depend on the way a given data source publishes its data.

### Release-Centric Data Sources
 Under data source root directory, you will find:
  * A file (current_release_NUMBER) that stores the latest release of the data source
  * A directory for each version downloaded
  * A symbolic "current"  that points to the latest version

### Non Release-Centric Data Sources
 Under data source root directory, the files will be stored by datasets
 or as specified in variables DATASETS, or/and TAXA in the data source configuration file 

Package Documentation:  https://github.com/mdibl/data_downloads/wiki

