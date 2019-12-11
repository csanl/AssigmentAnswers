#-------------------------------------------------------
#The ortologues founded in this blast reciprocal search will be in the ortologues.txt file

# The files with the sequences can be proteomes or genomes, and one will contain the
# sequences of interest (search_file), and you want to find its orthologues in other
# set of data (target_file). By making a BLAST with the sequences in the search_file with
# each sequence in target_file, and viceversa it is possible to determine the orthologues of the sequence. 
# 
#-------------------------------------------------------
require 'bio'

s_file = File.open('./pep.fa', "r")
t_file = File.open('./TAIR10_seq_20110103_representative_gene_model_updated', "r")
s_file_name= File.basename(s_file)
t_file_name= File.basename(t_file)


def type(filename) #this function detects the database's type of data (nucl or prot)
 i=0
  while i<2 #only in the first two sequences 
    filename.each do |report|
      type = Bio::Sequence.new(report.seq)
      if type.guess(0.9, 100) == Bio::Sequence::AA
       return "prot"
      i+=1
      elsif type.guess(0.9, 100) == Bio::Sequence::NA
       return "nucl"
      i+=1
      else 
        puts "no automatic detection, insert prot or nucl" #in case it can not be detecte, insert the type of data manually
        type = gets.chomp
        return type
      i+=1
      end
    end
  end
end
      
search_file = Bio::FastaFormat.open('./pep.fa')
target_file = Bio::FastaFormat.open('./TAIR10_seq_20110103_representative_gene_model_updated')

#in this directory the database will be stored 
system("rm -r db")
system("mkdir db")

system("makeblastdb -in '#{s_file_name}' -dbtype #{type(search_file)} -out ./db/search_db") 
system("makeblastdb -in '#{t_file_name}' -dbtype #{type(target_file)} -out ./db/target_db")


#this function will be use to do different type of blast, according to the different type of data in each db
def pre_blast (search_blast, target_blast)
  $factory_search = Bio::Blast.local(search_blast, "./db/search_db")
  $factory_target = Bio::Blast.local(target_blast, "./db/target_db")
end

if type(search_file) == 'nucl' and type(target_file) == 'nucl' # Both files contain genomes
    pre_blast('blastn', 'blastn')
  
elsif type(search_file) == 'prot' and type(target_file) == 'prot' # Both files contain proteomes
    pre_blast('blastp', 'blastp')

elsif type(search_file) == 'Nucl' and type(target_file) == 'prot' # First file contains a genome and the second one a proteome
    pre_blast('tblastn', 'blastx')
    
elsif type(search_file) == 'prot' and type(target_file) == 'nucl' # First file contains a proteome and the second one a genome
    pre_blast('blastx', 'tblastn')
end


#the parameters chossen for analysing the data (Ward & Moreno-Hagelsieb, 2014) are: 
$evalue = 10**-6
$overlap = 50


output_prueba = File.open('./ortologues.txt', "w")
output_prueba.puts "ORTHOLOGUES\n #{s_file_name}\t#{t_file_name}\n"

search_file.rewind()
search_file.each do |seq|
  puts seq.entry_id
  query = $factory_target.query(seq) #here the blast is done
  if query.hits[0] #if the hits exists
    if query.hits[0].evalue <= $evalue and query.hits[0].overlap >= $overlap
      #if the hit pass the conditions required
      a = query.hits[0].definition.to_s #to save the credentials to identify the sequence
      target_file.each do |seq_r| #now we search in the reverse way, making the blast with the
        #sequences founded as good hits 
        if a == seq_r.definition.to_s #here we select only the sequence we are interested in
          #(the one appearing as a hit to the search sequence which pass the evalue and overlapping conditions)
        query_r = $factory_search.query(seq_r) #we make the blast in the reverse way 
          if query_r.hits[0]
            if query_r.hits[0].evalue <= $evalue and query_r.hits[0].overlap >= $overlap
                if query_r.hits[0].definition == seq.definition
                  #if in this blast also appear the search sequence as a hit, and it passes the conditions,
                  #we consider it as a orthologue
                  puts "orthologue found"
                  output_prueba.puts seq.entry_id + "\t" + seq_r.entry_id
                end
            end
          end
        end
      end
      target_file.rewind()
    end
  end
end

output_prueba.close

puts "Work done! To know the orthologues found, check the file ortologues.txt"

#Bibliography
#- Ward, Natalie & Moreno-Hagelsieb, Gabriel. (2014).
#Quickly finding orthologs as reciprocal best hits with BLAT, LAST, and UBLAST:
#how much do we miss?. PloS one. 9. e101850. 10.1371/journal.pone.0101850.


#-------------------------------------------------------------------
#BONUS
#------------------------------------------------------------------
# For make a deeper search of the orthologues relationship in the genes founded:
#Construct a phylogenetic tree and searching the paralogues and orthologues infered by the algorithm used to construct it.
#Search in webs like eggNOG to know if they are gropued as orthologues
#Also the  GO terms shared give information of the probability of being orthologues

#Bibliography Bonus

#- Glover, Natasha, et al. (2019).
#Quest for Orthologs Consortium, Advances and Applications in the Quest for Orthologs,
#Molecular Biology and Evolution, Volume 36, Issue 10, Pages 2157–2164, https://doi.org/10.1093/molbev/msz150

#- Huerta-Cepas, Jaime, et al. (2015).
#"eggNOG 4.5: a hierarchical orthology framework with improved functional annotations for eukaryotic,
#prokaryotic and viral sequences."
#Nucleic acids research 44.D1: D286-D293.


