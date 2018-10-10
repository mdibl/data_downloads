# -*- coding: utf-8 -*-
import getopt,os,sys,re
from os import makedirs
from os.path import join,isfile,isdir,basename
import gzip,shutil

def prog_usage():
    usage='''
***************************************************************************************
    The tool does the following:
    1) Decompress the input gtf file if the input gtf file has *.gtf.gz extension
    2) Use the input gtf file to generate a *.tx2gene.txt file - a two-column file
       mapping transcript to gene association
    3) Generate *.gene_tx_tally.txt 

***************************************************************************************
    Usage: PROG [-h] --gtf=path2/gtf_file --destdir=path2/dest_dir
    Where:
        -h To show the usage
        -f gtf_file Or --gtf=gtf_file  ... required, specifies the gtf file input
        -d dest_dir Or  --destdir=dest_dir ... optional default working directory
   
   
    Example : 
        python gen_tx2gen_gtf  -f /data/external/ensembl/release-89/saccharomyces_cerevisiae/Saccharomyces_cerevisiae.R64-1-1.89.gtf.gz -d /data/scratch/ensembl-89/saccharomyces_cerevisiae-gtf
          
    '''
    print("%s"%(usage))

def get_tx_count(genes_container):
    tx_count=0
    for gene_id,transcripts in genes_container.items():
        tx_count+=len(transcripts)
    return tx_count

class GtfDOM:
    def __init__(self,line):
        self.seqname=""
        self.source=""
        self.feature=""
        self.start=""
        self.end=""
        self.score=""
        self.strand=""
        self.frame=""
        self.attributes={}
        self.fields_count=0
        self.__set(line)

    def __set(self,line):
        try:
            self.fields_count=len(line.split("\t"))
            [self.seqname,self.source,self.feature,self.start,
            self.end,
            self.score,
            self.strand,
            self.frame,
            attributes_string]=line.split("\t")
            attributes=attributes_string.split(";")
            for attribute in attributes:
                label,value=attribute.split()
                self.attributes[label]=re.sub(r'"','',value)
        except:pass
 

#cut -f9 Danio_rerio.GRCz11.92.gtf | grep transcript_id | cut -d ";" -f "1 3" |sed 's/"//g' |sed 's/gene_id//'|sed 's/transcript_id/\t/'| sort | uniq | head 
if __name__== "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hf:d:", 
                    ["help", "gtf=","destdir="])
    except(getopt.GetoptError, err):
        # print help information and exit:
        log.write(str(err)) # will print something like "option -a not recognized"
        print("ERROR:%s" % (str(err) )) # will print something like "option -a not recognized"
        prog_usage()
        sys.exit(1)
    #set program arguments
    gtf_file=None
    dest_dir=None
    # set current working directory
    working_dir = os.getcwd()

    for o, a in opts:
        if o in ("-f", "--gtf"):gtf_file = a
        elif o in ("-d", "--destdir"):dest_dir = a
        elif o in ("-h", "--help"):
            prog_usage()
            sys.exit()
        else:
            assert False, "unhandled option"
   
    if gtf_file is None:
        prog_usage()
        sys.exit()
    if dest_dir is None:
        dest_dir="./"
    if not isdir(dest_dir): makedirs(dest_dir)
    ##Check the input file 
    temp_file=basename(gtf_file)
    zip_extension=".gtf.gz"
    extension=".gtf"
    tx_file_prefix=re.sub(extension,'',temp_file)
    if temp_file.endswith(zip_extension):
        ## unzip the file
        tx_file_prefix=re.sub(zip_extension,'',temp_file)
        os.chdir(dest_dir)
        temp_gtf_file=tx_file_prefix+".gtf"
        temp_gtf_file=join(dest_dir,temp_gtf_file)
        if not isfile(temp_gtf_file):
            print("Unzipping file:%s under %s"%(gtf_file,os.getcwd()))
            with gzip.open(gtf_file, 'rb') as f_in:
                with open(temp_gtf_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
        gtf_file=join(dest_dir,temp_gtf_file)
        os.chdir(working_dir)

    if not isfile(gtf_file):
        print("ERROR: %s does not exist."%(gtf_file))
        sys.exit()
    ## The the input file prefix - assuming the name of th
    ## input file ends with *.gtf
    ## 
    #print working_dir
    try:
        tx_file_name=tx_file_prefix+".tx2gene.txt"
        tx_tally_file_name=tx_file_prefix+".gene_tx_tally.txt"
        tx_fd=open(join(dest_dir,tx_file_name),'w')
        txt_fd=open(join(dest_dir,tx_tally_file_name),'w')
        fd=open(gtf_file,'r')
        genes={}
      
        for line in fd.readlines():
            gtf_obj=GtfDOM(line)
            if gtf_obj.fields_count>0: 
                if "transcript" not in gtf_obj.feature:continue
                gene_id=gtf_obj.attributes["gene_id"]
                tx_id=gtf_obj.attributes["transcript_id"]
                if gene_id not in genes:genes[gene_id]=[]
                if tx_id not in genes[gene_id]:
                    genes[gene_id].append(tx_id)
                    tx_fd.write(gene_id+"\t"+tx_id+"\n")
            else:
                print("ERROR- fields count:%s for line:%s"%(gtf_obj.fields_count,line))
        txt_fd.write("Genes Count: %s\n"%(len(genes))) 
        tx_count=get_tx_count(genes)
        txt_fd.write("Transcripts Count:%d\n"%(tx_count)) 
        txt_fd.write("Transcripts Tally Per Gene:\n") 
        for gene_id,transcripts in genes.items():
           txt_fd.write("%s\t%d\n"%(gene_id,len(transcripts)))
    except:raise
    print("\n***************************\n\nThe following files were generated:")
    print("****************************\nTranscript-Gene mapping:%s"%(join(dest_dir,tx_file_prefix+".tx2gene.gtf")))
    print("Gene Transcript Tally:%s"%(join(dest_dir,tx_file_prefix+".gene_tx_tally.gtf")))
    print("Program Complete")
    sys.exit()
