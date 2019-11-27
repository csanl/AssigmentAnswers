#assigment3

require 'net/http' 
require 'bio'

def fetch(uri_str)  # this "fetch" routine does some basic error-handling.  

  address = URI(uri_str)  # create a "URI" object (Uniform Resource Identifier: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
  response = Net::HTTP.get_response(address)  # use the Net::HTTP object "get_response" method
                                               # to call that address

  case response   # the "case" block allows you to test various conditions... it is like an "if", but cleaner!
    when Net::HTTPSuccess then  # when response is of type Net::HTTPSuccess
      # successful retrieval of web page
      return response  # return that response object
    else
      raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
      response = false
      return response  # now we are returning False
    end 
end
    
  
def load_from_file(thisfile)
  
  genes = Array.new
  
  File.readlines(thisfile).each do |line|
    genes << line.upcase.delete_suffix("\n")
  end
  
  return genes

end
    
def get_object(agi_code) #here we create a Bio:EMBL object for each gene, and we obtain the sequence
  
  address = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{agi_code}"
  response = fetch(address)
  
  record = response.body
  entry = Bio::EMBL.new(record)
  
  seq = entry.to_biosequence
  
  return seq

end

def get_exons(bio_object, agi_code)
  
  $exons["#{agi_code}"] = Hash.new
  bio_object.features.each do |features| 
    if features.feature == 'exon' #for get the position if it is an exon      
    exonid = features.qualifiers[0].value
    $exons["#{agi_code}"]["#{exonid}"] = Hash.new #we create a hash with a key for the gene (agi_code), and other 
      # key for each exon 
    
      if /complement/ =~ features.position
        $exons["#{agi_code}"]["#{exonid}"]["strand"] = "-" #if appears complement, the exon is in a - strain
        position = features.position.tr("complement()", "")
        position_i = position.gsub(/.+:/, "")
        position_i_e = position_i.tr(")", "").split("..") #all this was for getting only the number of the position
        $exons["#{agi_code}"]["#{exonid}"]["position"] = position_i_e #we save the position, start and end, in a array 
      else 
        $exons["#{agi_code}"]["#{exonid}"]["strand"] = "+" #same for positive strand, when complement does not appear
        position = features.position.gsub(/.+:/, "")
        position_i_e = position.tr(")", "").split("..")
        $exons["#{agi_code}"]["#{exonid}"]["position"] = position_i_e
      end
    end
  end
    
  return $exons #we keep everything in a global variable, for taking the information in other functions...

end

def search_target(exon, seq)
  exon[1]["target_pos_ini"]=[]
  exon[1]["target_pos_end"]=[]
  if exon[1]["strand"] == "+" 
    map = seq.gsub(/#{$target}/).map { Regexp.last_match.begin(0) }    
  else 
     map = seq.gsub(/#{$target_complement}/).map { Regexp.last_match.begin(0) } #it the strand of the exon is -, 
    #the target appear as its complement in the + strand
  end

    map.each_with_index do |n| #for each match with the target, we search which are inside the exons positions
      target_position_ini = n + 1
      target_position_end = n + ($target.length + 1)
       if (target_position_ini.to_i >= exon[1]["position"][0].to_i) && (target_position_end.to_i <= exon[1]["position"][1].to_i)
         
        exon[1]["target_pos_ini"].append(target_position_ini)
        exon[1]["target_pos_end"].append(target_position_end) #we save the info in the global variable $exons 
       end
    end
  if exon[1]["target_pos_ini"].empty? 
    exon[1].delete("target_pos_ini")
    exon[1].delete("target_pos_end")
  end
end

def new_feature(agi_code, exon, seq)
  feat_exon = []
  if exon[1]["target_pos_ini"]
  exon[1]["target_pos_ini"].each_with_index do |n, index|
    if exon[1]["strand"] == "-" 
      pos_feature = "complement(#{n}..#{exon[1]["target_pos_end"][index]})" #all the positions obtained in this code
      #are referenced to the + strand, so for saving the information in a new feature we have to indicate it is in the complement
    else
      pos_feature = "#{n}..#{exon[1]["target_pos_end"][index]}"
    end
  f = Bio::Feature.new("#{$target}_match", "#{pos_feature}")
  f.append(Bio::Feature::Qualifier.new('strand', "#{exon[1]["strand"]}"))
    $gff.puts "#{agi_code}\t.\t#{f.feature}\t#{n}\t#{exon[1]["target_pos_end"][index]}\t.\t#{exon[1]["strand"]}\t.\t#{exon[0]}"
  feat_exon.append(f)
  end
  end
  seq.features.concat(feat_exon)
end

def chr_pos (bio_object, agi_code)
  chr_info= []
  if bio_object.primary_accession
    chr_info = bio_object.primary_accession.split(":") #the information of the start and end are in
    #the third and fourth position (for searching in the array)
    $gff_chr.puts "#{chr_info[2]}\t.\tgene\t#{chr_info[3]}\t#{chr_info[4]}\t.\t+\t.\tID=#{agi_code}"
  else 
    puts "problem with #{agi_code}"
  end 
  return chr_info
end

def chr_target_pos(exon, chr_info, agi_code) #we add the position we have for the targets to the position of the gene in the crhomosome
  if exon[1]["target_pos_ini"]
    exon[1]["target_pos_ini"].each_with_index do |n, index|
    chr_ini = chr_info[3].to_i + n 
    chr_end = chr_info[4].to_i + exon[1]["target_pos_end"][index]
    $gff_chr.puts "#{chr_info[2]}\t.\tnucleotide_motif\t#{chr_ini}\t#{chr_end}\t.\t#{exon[1]["strand"]}\t.\t#{exon[0]};parent=#{agi_code}"
 
  end
  end 
end

def create_open_file(filename)
  
  if File.exists?(filename) 
    File.delete(filename) # We remove the file in case it exits to update it
  end
  
  return File.open(filename, "a+")
  
end

#---------------------------------------------
#---------------------------------------------

$gff = create_open_file("genes.gff3")
$gff_chr = create_open_file("chr.gff3")
$no_target = create_open_file("no_target.txt")
$target = "cttctt"
$target_complement = "aagaag"
$exons = Hash.new

#headers on files
$gff.puts "##gff-version 3"
$gff_chr.puts "##gff-version 3"
$no_target.puts "Genes without #{$target} in exons\n"


genes = load_from_file(ARGV[0])
genes_with_target = []
genes.each do |gene|
  if not gene.empty?
    seq = get_object(gene)
    get_exons(seq, gene)
    chr = chr_pos(seq, gene)
    $exons[gene].each do |exon|
      search_target(exon, seq)
      new_feature(gene, exon, seq)
      chr_target_pos(exon, chr, gene)
      if exon[1]["target_pos_ini"]
        genes_with_target.append(gene)
      end
    end
    if not genes_with_target.include?(gene)
       $no_target.puts "#{gene}" #here we print the genes without a target, because any of them had
       #a target position associated in the exons hash
    end
  end
end

$gff.close
$gff_chr.close
$no_target.close
  
