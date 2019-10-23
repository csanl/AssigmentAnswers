#Assigment1

require "./CrossObject.rb"
require "./GeneObject.rb"
require "./StockObject.rb"

$gene = []
$stockdata = []
$crossdata = []
Gene.data(ARGV[0])
StockData.data(ARGV[1])
CrossData.data(ARGV[2])


StockData.seed(7, "21/10/2019", "./seed_stock_data.tsv")
$hashinfo=Hash.new
for i in 0..($stockdata.length-1)
  $stockdata[i].gene_information(i)
end

CrossData.chi_square

puts"==============================================="
puts "DEMOSTRATION OF BONUS 1"
#I have created a similar file but introducing some errors in th id number of some genes
Gene.data("./gene_information_wrongid.tsv")

