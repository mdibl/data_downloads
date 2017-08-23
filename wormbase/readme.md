# WormBase Downloads

## What do we download from WormBase -- ftp://ftp.wormbase.org ?

### Datasets : /pub/wormbase/releases/$RELEASE_NUMBER/
  * species/c_elegans/*
  * species/ASSEMBLIES.$RELEASE_NUMBER.json
  * ONTOLOGY/gene_association.$RELEASE_NUMBER.wb
  * ONTOLOGY/gene_association.$RELEASE_NUMBER.wb.c_elegans
  * ONTOLOGY/gene_ontology.$RELEASE_NUMBER.obo
  * ONTOLOGY/disease_ontology.$RELEASE_NUMBER.obo
  * ONTOLOGY/development_ontology.$RELEASE_NUMBER.obo
  * ONTOLOGY/anatomy_ontology.$RELEASE_NUMBER.obo
  * ONTOLOGY/phenotype_ontology.$RELEASE_NUMBER.obo
  * ONTOLOGY/phenotype_association.$RELEASE_NUMBER.wb
  * ONTOLOGY/phenotype2go.$RELEASE_NUMBER.wb

### Downloads Frequency 
According to their site, WormBase follows a two month release cycle. http://blog.wormbase.org/2017/07/20/wormbase-release-information/. However, we have scheduled our new release detector cron to run daily and toggle the download whenever a new release is detected.

See : https://jenkins.mdibl.org/job/Wormbase/

Runs Daily: 10AM
