class StockData

  attr_accessor :stock
  attr_accessor :idmutant_gene
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  
# create an "attribute accessor" (read and write) for "name"
  
  def initialize (params = {}) # get a name from the "new" call, or set a default
      @stock = params.fetch(:stock, '0000')
      @idmutant_gene = params.fetch(:idmutant_gene, 'AT0G00000')
      @last_planted = params.fetch(:last_planted, 'unknown date')
      @storage = params.fetch(:storage, 'cama0')
      @grams_remaining = params.fetch(:grams_remaining, "0")
  end
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
  
  def gene_information(i)
    if  $gene[i].geneid == $stockdata[i].idmutant_gene
      $hashinfo["#{$stockdata[i].stock}"] = $gene[i]
    end
    return $hashinfo
  end
  
  def StockData.get_name (stockdata_object)
    return $hashinfo["#{stockdata_object.stock}"].name
  end
    
end