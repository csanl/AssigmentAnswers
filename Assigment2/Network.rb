
class Network
  attr_accessor :network_id #I have assigned the ID to a network according to the gene in level 1 wich make me achieve this network
  attr_accessor :network_genes # gene members of each network
  @@number_of_networks = 0
  @@total_networks = Hash.new #hash containing all the network (if the number of genes is large, I think this could be an inefficient use of the memory... )
  
  
  def initialize (params = {}) 
      @network_id = params.fetch(:network_id, 'nada')
      @network_genes = params.fetch(:network_genes, 'nada')
    
      @@number_of_networks += 1
      @@total_networks[network_id] = self
  end
  
  def Network.create_objects #annotating the networks achieved by the function get_merged_network
    Network.get_merged_network.each do |i|
      network_id = i[0] #It is the ID of the gene of level 1, I used as first step to achieve the network  
      if not Network.all_networks["#{network_id}"] #we make sure the network does not exist
        puts network_id
        network_genes = i[1]
        

        Network.new(
          :network_id => network_id,
          :network_genes => network_genes)
      end
    end
  end
  
  
  def Network.total_number
    return @@number_of_networks
  end
  
  def Network.all_networks
    return @@total_networks
  end
  
  
  def Network.get_primary_network  #first I create a primary set of network from each gene at level 1, it never could be more networks than genes at this level. 
    $network = Hash.new
    Gene.get_array_all_id.each do |id|
      if Gene.get_all_objects["#{id}"].gene_depth == 1 #from each gene with gene_depth 1, we make an array indexed with its ID
        $network["#{id}"] = Array.new
        Gene.get_all_objects["#{id}"].int_array.each do |gene2| #we take the interaction array corresponding to this gene, and search for the genes interacting with them... and so on until we achieve the level desired. 
          Network.prueba("#{id}", "#{gene2}") 
        end
      end
    end
    return $network
  end
  
    
     def Network.prueba(id, gene) #this function has been created to allow the iteration of the search of genes until we achieve the maximum level.
       #From the genes with te maximum depth, we can have also the genes interacting with them, but they are not anotated.
       #For example, at level 2, we have some genes anotated in the gene class, but also we have the interaction array for each one, containing genes that are not anotated in the gene class.
      if not $network[id].include?(gene) #we make sure we don't have genes duplicated.  
        $network[id] << gene
      end
      Gene.get_all_objects["#{gene}"].int_array.each do |gene2|
    
        if Gene.get_all_objects["#{gene}"].gene_depth < $max_depth_level #here we continue making this iteration if the max_depth level is not achieved. 
          Network.prueba(id, "#{gene2}")
        else #if we are in the max_depth_level, we only include the genes from its array, and we stop the iteration. 
          if not $network[id].include?(gene2)
          $network[id] << gene2
          end
        end
      end
    end
    
  def Network.get_merged_network #for merge the independent arrays created from genes at level 1, creating the definitive networks
      Network.get_primary_network.each_with_index do |i, index|
        Network.get_primary_network.each do |j|
         if i[1] != j[1]
           c = i[1] & j[1] #we search if the different networks have common genes, then they are from the same network.
           if not c.empty?
             Network.get_primary_network[index] = (i[1] + j[1]).uniq #if they have common genes, we make a new array combining
             # the two initial networks keeping the index of the first one (in order), and deleting the second one (it has been added to the first network array)
             Network.get_primary_network.delete(j[1]) 
           end
         end
        end
      end
    return Network.get_primary_network
  end
  
  
end