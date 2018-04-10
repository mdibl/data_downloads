
# Biocore Package Downloads Repos

A repository to create automations that download external bioinformatics Datasets.

For each database source, this package can be setup to run an automation that checks if a new version of the database is available. As soon as it detects a new release , the automation will download it locally.

## What It Does

For each database source,the automation creates a root directory that is the name of the database in the path set in the main Configuration (EXTERNAL_DATA_BASE). The organization of files under these root directories
will depend on the way a given data source published its data.

### Release-Centric Data Sources
 Under data source root directory, you will find:
  * A file (current_release_NUMBER) that stores the latest release of the data source
  * A directory for each version downloaded
  * A symbolic "current"  that points to the latest version

### Non Release-Centric Data Sources
 Under data source root directory, the files will be stored by datasets
 or as specified in variable DATASETS in the data source configuration file 

Package Documentation:  https://github.com/mdibl/data_downloads/wiki

```




# Data Downloads
A repository to store scripts and configuration files used to download external datasets 

## Overview:

This product uses wget utilities to download files from a remote server to our local /data/external/ directory (by default).
There is one main script, written in sh, that does the download. 

Each data source  has its own config file  and each dataset has a config file where applicabl.
These files are passed to the main download script at run time. 

The package config file is a shell (sh) config file that sets the following global variables:

```bash

description:  contains a brief description of the package 
REMOTE_SITE:  remote site (example: REMOTE_SITE=ftp.ensembl.org)
REMOTE_SITE_URL: full url to remote site 
REMOTE_DIR:   absolute path to files remotely
REMOTE_FILES: list of files to download - wild cards can be used 
LOCAL_DIR: absolute path to local downloads directory 
 
By default the program will set this to LOCAL_DIR =$REMOTE_SITE$REMOTE_DIR 
   if the variable LOCAL_DIR was not set in the package configuration file.

WGET_OPTIONS - wget command line options to use (example: WGET_OPTIONS="-S -t 10 -nd -m")
```
# Project Organization

# Data Local Storage

Data is stored by sourcce/version/organism/ - We stored data as downloaded from the source 
under /data/external. However,the uncompressed version of the data is stored under /data/scratch.
I addition, we create a structure that stores a joined fasta file for both cdna and ncrna datasets where
applicable.

```
 Example :
cat Caenorhabditis_elegans.WBcel235.cdna.all.fa Caenorhabditis_elegans.WBcel235.ncrna.fa >    
  Caenorhabditis_elegans.WBcel235.joined.fa
```
The file is stored under /data/scratch/source-version/organism-transcriptome-joined

We alsocreate a structure that stores a joined fasta file for the genome. 
The file has the suffix *.genome.fa
 
 ```
    Example:  cat *.dna.chromosome.*.fa > $organism.genome.fa
 ```
The file is stored under the dna directory for that organism in addition 
to the chromosome files (/data/scratch/ensembl-version/organism-dna/ )


## Dependencies
```bash
   sh shell
   wget
```
