# -*- coding: utf-8 -*-
import getopt,os,sys,re
from os import makedirs
from os.path import join,isfile,isdir,basename
import gzip,shutil

def prog_usage():
    usage='''
***************************************************************************************
    The tool filters the transcriptome_joined fasta file to remove
    fasta entries of all the transcripts not in the provided gtf
    
***************************************************************************************
    Usage: PROG [-h] --gtf=path2/gtf_file  --tx=path2/transcriptome.fa --destdir=path2/dest_dir
    Where:
        -h To show the usage
        -f gtf_file Or --gtf=gtf_file  ... required, specifies the gtf file input
        -t tx_fasta_file Or --tx=tx_fasta_file  ... required, specifies the transcriptome fasta input file
        -d dest_dir Or  --destdir=dest_dir ... optional default working directory
   
   
    Example : 
        python gen_tx2gen_gtf \
           -f /data/scratch/ensembl-94/saccharomyces_cerevisiae-gtf/Saccharomyces_cerevisiae.R64-1-1.89.gtf\
           -t /data/scratch/ensembl-94/saccharomyces_cerevisiae-transcriptome_joined/saccharomyces_cerevisiae-transcriptome-joined.fa
           -d /data/scratch/ensembl-94/saccharomyces_cerevisiae-transcriptome_joined
          
    '''
    print("%s"%(usage))

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
 
if __name__== "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hf:t:d:", 
                    ["help", "gtf=","tx=","destdir="])
    except(getopt.GetoptError, err):
        # print help information and exit:
        log.write(str(err)) # will print something like "option -a not recognized"
        print("ERROR:%s" % (str(err) )) # will print something like "option -a not recognized"
        prog_usage()
        sys.exit(1)
    #set program arguments
    gtf_file=None
    fasta_file=None
    dest_dir=None
    # set current working directory
    working_dir = os.getcwd()

    for o, a in opts:
        if o in ("-f", "--gtf"):gtf_file = a
        elif o in ("-t", "--tx"):fasta_file = a
        elif o in ("-d", "--destdir"):dest_dir = a
        elif o in ("-h", "--help"):
            prog_usage()
            sys.exit()
        else:
            assert False, "unhandled option"
   
    if fasta_file is None or gtf_file is None:
        prog_usage()
        sys.exit()
    if dest_dir is None:
        dest_dir="./"
    if not isdir(dest_dir): makedirs(dest_dir)
    ##Check the input file 
    temp_file=basename(gtf_file)
    zip_extension=".gtf.gz"
    fasta_extension=".fa"
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
    if not isfile(fasta_file):
        print("ERROR: %s does not exist."%(fasta_file))
        sys.exit()
    tx_file_prefix=re.sub(fasta_extension,'',basename(fasta_file))
    ## The the input file prefix - assuming the name of th
    ## input file ends with *.gtf
    ## 
    #print working_dir
    try:
        tx_file_name=tx_file_prefix+".gtf_filtered.fa"
        skip_file_name=tx_file_prefix+".txNotInGtf.txt"
        tx_fd=open(join(dest_dir,tx_file_name),'w')
        skip_fd=open(join(dest_dir,skip_file_name),'w')
        fd=open(gtf_file,'r')
        transcripts=[]
        #Load transcript ids into a list
        for line in fd.readlines():
            gtf_obj=GtfDOM(line)
            if gtf_obj.fields_count>0: 
                if "transcript" not in gtf_obj.feature:continue
                tx_id=gtf_obj.attributes["transcript_id"]
                if tx_id not in transcripts:
                    transcripts.append(tx_id)
            else:
                print("ERROR- fields count:%s for line:%s"%(gtf_obj.fields_count,line))
        ## Now read and filter the fasta file
        fd=open(fasta_file,'r')
        bucket={}
        current_tx_id=""
        previous_tx_id=""
        current_header=""
        previous_header=""
        for line in fd.readlines():
            if line.startswith( '>' ):        
               previous_tx_id=current_tx_id
               previous_header=current_header
               line_token=line.replace('>','')
               fields=line_token.split(' ')    
               current_tx_id=fields[0]
               if current_tx_id not in transcripts:
                   tx_token=fields[0].split('.')
                   token_count=len(tx_token)-1
                   current_tx_id='.'.join(tx_token[0:token_count])
               current_header=line
               if previous_tx_id not in transcripts:
                   skip_fd.write("%s\n"%(previous_tx_id))
                   bucket={}
                   continue
               else:
                   tx_fd.write(previous_header)
                   tx_fd.write("".join(bucket[previous_tx_id]))
               bucket={}
               bucket[current_tx_id]=[] 
            else:
                if current_tx_id not in bucket:bucket[current_tx_id]=[]
                bucket[current_tx_id].append(line)
              
    except:raise
    print("Program Complete")
    sys.exit()
