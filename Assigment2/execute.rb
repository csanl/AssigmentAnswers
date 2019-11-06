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
  #si algo va mal:rescue
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.response
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue RestClient::Exception => e
    $stderr.puts e.response
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue Exception => e
    $stderr.puts e
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end

Gene.create_object('./genesprueba.txt')

$max_depth_level = 1
$LEVEL = 2
Gene.create_object_next_depth

Network.get_primary_network

Network.get_merged_network

Network.create_objects





 