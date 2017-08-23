Base directory to store Mirbase downloads scripts and config files

# What do we download from MirBase?

## Datasets
 * miRNA.dat     - all entries in (almost) EMBL format
 * hairpin.fa    - predicted miR stem-loop sequences in fasta format
 * mature.fa     - mature sequences in fasta format
 * miFam.dat     - family classification of related hairpin sequences
 * high_conf_hairpin.fa.gz 
 * database_files/mature_read_count.txt.gz
 * high_conf_mature.fa.gz

## Mirbase downloads frequency
According to their site, miRBase is updated every six months; however, this schedule is flexible. http://www.mirbase.org/help/FAQs.shtml#How%20often%20do%20you%20update%20miRBase?. However, we have scheduled 
our new release detector cron to run daily and toggle the download whenever a new release is detected.

See : https://jenkins.mdibl.org/job/Mirbase/

Runs Daily: 1PM
