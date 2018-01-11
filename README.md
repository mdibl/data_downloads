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
By default the program will set this to LOCAL_DIR =$REMOTE_SITE$REMOTE_DIR 
   if the variable LOCAL_DIR was not set in the package configuration file.

WGET_OPTIONS - wget command line options to use (example: WGET_OPTIONS="-S -t 10 -nd -m")
```

## Usage

```bash 

ssh to server host
cd /path2/data_downloads/
run ./getAnnotations.sh  source/package.config 
   (where package.config is the configuration file of the package to download)
   
Example 1: To download Ensembl CDNA data, ssh to downloads server and
 1) ssh to one biocore servers
 2) cd to /usr/local/biocore/data_downloads
 3) run ./getAnnotations.sh ensembl/ftp.ensembl.org.cdna.cfg
 

```
# Local Data Storage

Data is stored by sourcce/version/organism/ - We stored data as downloaded from the source 
under /data/external.

The uncompressed version of the data is stored under /data/scratch

## Ensembl Data - Uncompressed data
For each organism in addition to the original file :
1) We create a structure that stores a joined fasta file for both cdna and ncrna datasets. The file name will be : current_prefix.joined.fa
```
 Example :
cat Caenorhabditis_elegans.WBcel235.cdna.all.fa Caenorhabditis_elegans.WBcel235.ncrna.fa >    
  Caenorhabditis_elegans.WBcel235.joined.fa
```
The file is stored under /data/scratch/ensembl-version/organism-transcriptome-joined

2) We create a structure that stores a joined fasta file for the genome. The file has the suffix *.dna.genome.fa
 
 ```
    Example:  cat *.dna.chromosome.*.fa > $organism.dna.genome.fa
 ```
The file is stored under the dna directory for that organism in addition 
to the chromosome files (/data/scratch/ensembl-version/organism-dna/ )


## Dependencies
```bash
   sh shell
   wget
```
