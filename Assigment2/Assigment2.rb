require 'rest-client'  
require 'json'
require './Gene.rb'
require './Network.rb'

def fetch(url, headers = {accept: "*/*"}, user = "", pass="") #lo mas imp es la url
  response = RestClient::Request.execute({
    method: :get,
    url: url.to_s,
    user: user,
    password: pass,
    headers: headers})
  return response
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.response
    response = false
    return response  
  rescue RestClient::Exception => e
    $stderr.puts e.response
    response = false
    return response  
  rescue Exception => e
    $stderr.puts e
    response = false
    return response 
end

Gene.create_object(ARGV[0])

$max_depth_level = 1
$LEVEL = 2
Gene.create_object_next_depth

Network.get_primary_network

Network.get_merged_network

Network.create_objects

def write_processed_data(filename)
 if File.exist?(filename)
   File.delete(filename) # We remove the file in case it exits to update it
  end
  fo = File.open(filename, 'a+')
    fo.puts "Assigment2"
    fo.puts "------------------------------"
  Network.all_networks.each do |id|
  fo.puts "------------------------------"
  fo.puts "NETWORK ID: #{Network.all_networks["#{id[0]}"].network_id}"
  fo.puts "Number of genes in this network: #{Network.all_networks["#{id[0]}"].network_genes.length}"
  fo.puts "Genes interacting at level #{$LEVEL} as maximum level  and its annotations"
    Network.all_networks["#{id[0]}"].network_genes.each do |gene|
      if Gene.get_array_all_id.include?(gene)
        fo.puts "\t #{gene}"
        Gene.get_all_objects["#{gene}"].go.each do |go|
        fo.puts "\t\t GO ID: #{go[0]};\t GO Term name: #{go[1]}"
        end
        Gene.get_all_objects["#{gene}"].kegg.each do |kegg|
        fo.puts "\t\t KEGG Pathways ID => Pathways name : #{kegg}"
        end
      end
      
    end
  fo.puts "------------------------------"
  end
  
  fo.puts "END"
  fo.close
end
  
write_processed_data(ARGV[1])

puts "final report in #{ARGV[1]}"
puts "TASK DONE"
 