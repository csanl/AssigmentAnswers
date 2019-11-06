class Gene

  attr_accessor :geneid 
  attr_accessor :kegg #hash containing kegg pathways id and name from each gene included in the class
  attr_accessor :go #hash containing GO ID number and its term name from each gene included in the class
  attr_accessor :int_array #array containing the IDs of all the genes interacting with this gene at the level we set
  attr_accessor :gene_depth #gene_depth = 1 are the genes introduced at first, gene_depth=2 are the genes interacting with the first ones, and so on...
  @@number_of_objects = 0 
  @@genes = Hash.new
  @@genesid_array = Array.new 
  
  
  def initialize (params = {}) 
      @geneid = params.fetch(:geneid, 'nada')
      match_id = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/) #to make sure the gene ID is correct
        if match_id.match(geneid)
        @geneid = geneid
        else
          puts "wrong Gene ID"
        end
      @kegg = params.fetch(:kegg, 'nada')
      @go = params.fetch(:go, 'nada')
      @int_array = params.fetch(:int_array, 'nada')
      @gene_depth = params.fetch(:gene_depth, 0)
      
      @@number_of_objects += 1 #we have in this variable the total number of genes introduced in the class
      @@genesid_array = []
      @@genes[geneid] = self #we have a hash with the information of all the objects, annotated by its geneid
    
  end 
    
  def Gene.get_all_objects 
    return @@genes
  end
  
  def Gene.get_array_all_id 
    Gene.get_all_objects.each do |id|
     if not @@genesid_array.include?(id[0])
        @@genesid_array.append(id[0])
     end
    end
    return @@genesid_array
  end
  
  def Gene.total_number
    return @@number_of_objects
  end
  
  def Gene.create_object(thisfile) #we create the gene objects at level 1, from the file given. 
    File.readlines(thisfile).each do |line|
    line = line.upcase.delete_suffix("\n") #we search each AGI code in the list
    puts line
    geneid = line
    go = self.get_go(line)
    kegg = self.get_kegg(line)
    intact = self.get_intact_array(line)
      if intact != [] #we are introducing in our Gene Class ***only the genes with interactions***
      Gene.new(
        :geneid => geneid,
        :go => go,
        :kegg => kegg,
        :int_array => intact,
        :gene_depth => 1) #we set the gene_depth as 1 because they are the initial genes
      end
    end
  end
  
  
def Gene.create_object_next_depth #if we want to go deeper, and anotate the genes interacting with the genes at level 1
  all_gene_id =  Gene.get_array_all_id
  all_gene_id.each do |id|
   if Gene.get_all_objects["#{id}"].gene_depth == $max_depth_level #the max_depth_level global variable report the maximum level register the gene objects
      Gene.get_all_objects["#{id}"].int_array.each do |gene|
        go = self.get_go(gene)
        kegg = self.get_kegg(gene)
        intact = self.get_intact_array(gene)
        gene_depth = Gene.get_all_objects["#{id}"].gene_depth + 1
        geneid = gene
        if not all_gene_id.include?("geneid") #we make sure the array does not content duplicates 
          if intact != []
            Gene.new(
            :geneid => geneid,
            :go => go,
            :kegg => kegg,
            :int_array => intact,
            :gene_depth => gene_depth)
          end
        end
      end
    end
  end
  $max_depth_level += 1
  if $max_depth_level < $LEVEL #we will keep doing this function until the max_depth_level achieve the LEVEL wished. (LEVEL is a global variable setting the level of depth in the interactions desired.)
   Gene.create_object_next_depth
  end
 end
  
  
  def self.get_go(agi_code) #we achieve the GO number of each gene
    
    res_go = fetch("http://togows.org/entry/ebi-uniprot/#{agi_code}/dr.json");
   
    if res_go
    body = JSON.parse(res_go.body)
    all_go = body[0]["GO"]
    go_p = Hash.new #here we make sure the GO ID is from a biological_process, because the term name start by P:
      all_go.each do |i|
        if i[1] =~ /P:/
          go_p[i[0]] = i[1]
        end
      end
    end
  
    return go_p
  end

    def self.get_kegg(agi_code) #we achieve the kegg ID pathways and its names
    res_kegg = fetch("http://togows.org/entry/genes/ath:#{agi_code}/pathways.json");
    
      if res_kegg  
        kegg = JSON.parse(res_kegg.body)  
      return kegg[0]
      end
      
    end
  

  def self.get_intact_array(agi_code) #this function get the genes interacting with a given gene, and create an associated array with its IDs.
    interaction=Array.new
    res_intact = fetch("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{agi_code}?format=tab25");
    
      if res_intact  
        body = res_intact.body  
        lines = body.split("\n") #each line of the tab=25 format is an interaction pair. 
        lines.each do |int|
          column = int.split("\t") #each column has a different infromation
          match_id = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/)  #we search for a valid gene ID form Arabidopsis thaliana's gene -
          #here we only search the interactions between self-specie-genes
          if match_id.match(column[4])
          idprot1 = match_id.match(column[4]).to_s.upcase
          end
          if match_id.match(column[5])
          idprot2 = match_id.match(column[5]).to_s.upcase
          end
          if idprot1 && idprot2
            if column[0]==column[1] #self-interaction
              interaction << agi_code #we add the id to an array
              #we don't know if the given gene is in the column 4 or column 5, so we check both cases
            elsif idprot1 == agi_code 
                interaction << idprot2 #we add the id of the protein in the other column to an array
            else idprot2 == agi_code 
                interaction << idprot1
            end
          end
          
        end
      end
    return interaction 
      
    end
    
end