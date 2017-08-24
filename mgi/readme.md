Base directory to store MGI downloads scripts and config files

# What do we download from MGI -- http:://www.informatics.jax.org?

## Datasets 
 Path to remote data : /download/reports

### Alleles And Phenotypes:
 * MPheno_OBO.ontology
 * VOC_MammalianPhenotype.rpt
 * HMD_HumanPhenotype.rpt
 * MGI_PhenotypicAllele.rpt

### Gene Expression:
 * MRK_GXD.rpt
 * MRK_GXDAssay.rpt
 * adult_mouse_anatomy.obo
 * ma2ncit.obo

### Gene Ontology:
 * gene_association.mgi.gz
 * go_terms.mgi
 * gp2protein.mgi

## MGI downloads frequency
MGI  updates its reports Monday night. Our download cron runs Tuesdays @6AM.

See : https://jenkins.mdibl.org/job/MGI/

Runs Once a week - Tuesday: 6AM
