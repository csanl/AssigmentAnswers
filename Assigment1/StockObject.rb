class StockData

  attr_accessor :stock
  attr_accessor :idmutant_gene
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  
  
  def initialize (params = {}) 
      @stock = params.fetch(:stock, '0000')
      @idmutant_gene = params.fetch(:idmutant_gene, 'AT0G00000')
      @last_planted = params.fetch(:last_planted, 'unknown date')
      @storage = params.fetch(:storage, 'cama0')
      @grams_remaining = params.fetch(:grams_remaining, "0")
  end

#this Class method creates some objects from a file, they are saved in a global variable called "stockdata", it has an index, so for example stockdata[0] is the object with the @properties=values: @stock="A334", @idmutant_gene="AT1G69120", @last_planted="5/7/2014", @storage="cama2", @grams_remaining=28)

  def StockData.data(thisfile)
    File.readlines(thisfile).each_with_index do |line, index|
    next line if index == 0
    stock, idmutant_gene, last_planted, storage, grams_remaining = line.split("\t")
    $stockdata[index-1] = StockData.new(
      :stock => stock,
      :idmutant_gene => idmutant_gene,
      :last_planted => last_planted,
      :storage => storage,
      :grams_remaining => grams_remaining.to_i)
    end
  end

#this Class method is for planting "x" grams of seed, updating the data in a new data file with the updated grams of seed, and the last date of planting
  def StockData.seed(grams, date, lastfile)
      grams = grams.to_i
      for i in 0..($stockdata.length-1)
        new_grams = $stockdata[i].grams_remaining - grams
#         puts new_grams
        if new_grams <= 0
          $stockdata[i].grams_remaining = 0
          puts "WARNING: we have run out of Seed Stock #{$stockdata[i].stock}"
        else 
          $stockdata[i].grams_remaining = new_grams
          #puts "we have #{$stockdata[i].grams_remaining} grams of Seed Stock #{$stockdata[i].stock}"
        end
        $stockdata[i].last_planted = date
      end
      new = File.new("new_stock_file.tsv", "w")
      File.readlines(lastfile).each_with_index do |line, index|
        if index == 0
          new.write("#{line}")
        else 
           new.write("#{$stockdata[index-1].stock}\t#{$stockdata[index-1].idmutant_gene}\t#{$stockdata[index-1].last_planted}\t#{$stockdata[index-1].storage}\t#{$stockdata[index-1].grams_remaining}\n")
        end
      end
    new.close
  end   

#with this Object method we can obtain a hash named "hashinfo" with the gene information (from de Gene Classe) corresponding to the idmutant_gene we have in the StockData Class. 
  def gene_information(i)
    if  $gene[i].geneid == $stockdata[i].idmutant_gene
      $hashinfo["#{$stockdata[i].stock}"] = $gene[i]
    end
    return $hashinfo
  end

#With this Class method we can know the gene name of the object from StockData we choose introducing its stock number
  def StockData.get_name (stockdata_object)
    return $hashinfo["#{stockdata_object.stock}"].name
  end
    
end
