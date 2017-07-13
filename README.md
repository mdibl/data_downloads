# Data Downloads
A repository to store scripts and configuration files used to download external datasets 

## Overview:

This product uses wget utilities to download files from a remote server to our local /data/external/ directory (by default).
There is one main script, written in sh, that does the download. Each package has its own config file that's passed to the main script at run time. 

The package config file is a shell (sh) config file that sets the following global variables:

```bash

description:  contains a brief description of the package 
                (example: description="Mouse CDNA annotations from Ensembl")
REMOTE_SITE:  remote site (example: REMOTE_SITE=ftp.ensembl.org)
REMOTE_SITE_URL: full url to remote site 
                 (example: REMOTE_SITE_URL=ftp://$REMOTE_SITE )
REMOTE_DIR:   absolute path to files to download 
              (example: REMOTE_DIR=/pub/current_fasta/mus_musculus/cdna)
REMOTE_FILES: list of files to download - wild cards can be used 
              (example: REMOTE_FILES="Mus_musculus.*.cdna.all.fa.gz"
LOCAL_DIR: absolute path to local downloads directory 
             (example: LOCAL_DIR =$REMOTE_SITE$REMOTE_DIR)
By default the program will set this to LOCAL_DIR =$REMOTE_SITE$REMOTE_DIR if the variable LOCAL_DIR was not set in the package configuration file.

WGET_OPTIONS - wget command line options to use (example: WGET_OPTIONS="-S -t 10 -nd -m")
```

## Usage

```bash 

ssh to server host
cd /path2/data_downloads/
run ./download_package package.config (where package.config is the configuration file of the package to download)
Example 1: To download Ensembl CDNA data, ssh to mirror server and

run /path2/data_downloads/download_package /path2/data_downloads/ftp.ensembl.org.cdna

```

## Dependencies
```bash
   sh shell
   wget
```
