Base directory to store Ensembl downloads scripts and config files

# What do we download from Ensembl -- ftp:://ftp.ensembl.org ?

## Organisms
  * caenorhabditis_elegans 
  * danio_rerio
  * drosophila_melanogaster
  * homo_sapiens
  * mus_musculus
  * saccharomyces_cerevisiae

## Datasets
 * cdna (Transcript Sequence Data)
 * cds  (Coding Sequence Data)
 * dna  (Genome Sequence Data)
 * gtf   (Annotations (genes,transcript,exons,...) Data)
 * ncrna  (Non coding RNA Sequence Data)
 * pep   (Protein Sequence Data)

## Ensembl downloads frequency
According to Ensembl site, Ensembl data is released on an approximately three-month cycle http://www.ensembl.org/info/about/release_cycle.html. However, we have scheduled 
our new release detector cron to run daily and toggle the download whenever a new release is detected.

See : https://jenkins.mdibl.org/job/Ensembl/

Runs daily: 1PM
