Base directory to store NCBI downloads scripts and config files

# What Do We Download From NCBI -  ftp://ftp.ncbi.nih.gov ?

## Genes : /gene
  * README
  * DATA/gene2accession.gz 
  * DATA/gene2pubmed.gz 
  * DATA/gene2refseq.gz 
  * DATA/gene_history.gz 
  * DATA/gene_info.gz 
  * DATA/README
  * DATA/mim2gene_medgen
  * GeneRIF/generifs_basic.gz
 
 ## Pathways : /pub/biosystems
  * CURRENT/biosystems_gene.gz
  * CURRENT/bsid2info.gz
  * README.txt
  
## Taxonomy : /pub/taxonomy
  * taxdump.tar.gz
  * taxdump_readme.txt
  * taxdump.tar.gz.md5
  
## NCBI downloads frequency

Genes and taxonomy files are updated daily so, we have scheduled our downloads to run daily.

  
Runs daily: 9:30AM

See: https://jenkins.mdibl.org/job/ncbi/
