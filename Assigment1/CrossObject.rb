class CrossData

  attr_accessor :parent1
  attr_accessor :parent2
  attr_accessor :f2_wild
  attr_accessor :f2_p1
  attr_accessor :f2_p2
  attr_accessor :f2_p1p2
  
# create an "attribute accessor" (read and write) for "name"
  
  def initialize (params = {}) # get a name from the "new" call, or set a default
      @parent1 = params.fetch(:parent1, '0000')
      @parent2 = params.fetch(:parent2, '0000')
      @f2_wild = params.fetch(:f2_wild, "0")
      @f2_p1 = params.fetch(:f2_p1, "0")
      @f2_p2 = params.fetch(:f2_p2, "0")
      @f2_p1p2 = params.fetch(:f2_p1p2, "0")
     
  end

#this Class method creates some objects from a file, they are saved in a global variable called "crossdata". It works similar than the other classes already explained. 
  def CrossData.data(thisfile)
    File.readlines(thisfile).each_with_index do |line, index|
    next line if index == 0
    parent1, parent2, f2_w, f2_p1, f2_p2, f2_p1p2 = line.split("\t")
    $crossdata[index-1] = CrossData.new(
      :parent1 => parent1,
      :parent2 => parent2,
      :f2_wild => f2_w.to_i,
      :f2_p1 => f2_p1.to_i,
      :f2_p2 => f2_p2.to_i,
      :f2_p1p2 => f2_p1p2.to_i)
    end
  end
 
#this Class method allows us to know the gene name of the CrossData Object we choose, thanks to the hash created in the StockData method "gene_information" (by linking the Gene Class information to the StockData Class)
  def CrossData.get_name (crossdata_object)
    return $hashinfo["#{crossdata_object}"].name
  end

#this Class method obtain the chi-square value of the crosses represented in the data.
  def CrossData.chi_square
      for i in 0..($crossdata.length-1)
        #n is the total number of individuals in every cross
       n = $crossdata[i].f2_wild + $crossdata[i].f2_p1 + $crossdata[i].f2_p2 + $crossdata[i].f2_p1p2 
        #expected number of individuals according to the total number and the expected proportion (9:3:3:1) if the genes were genetically independent
        exp_wild = 9.fdiv(16)*n 
        exp_p1 = 3.fdiv(16)*n
        exp_p2 = 3.fdiv(16)*n
        exp_p1p2 = 1.fdiv(16)*n
       chi_square = ((($crossdata[i].f2_wild - exp_wild)**2)/exp_wild) + ((($crossdata[i].f2_p1 - exp_p1)**2)/exp_p1) + ((($crossdata[i].f2_p2 - exp_p2)**2)/exp_p2) + ((($crossdata[i].f2_p1p2 - exp_p1p2)**2)/exp_p1p2)
#         puts "chi-square  for #{$crossdata[i].parent1} x #{$crossdata[i].parent2} is #{chi_square}"
        if chi_square > 7.82 #this value is taken from the chi-square table with 3 degrees of freedom and 95% of confiden interval
        puts "Recording: #{CrossData.get_name($crossdata[i].parent1)} is genetically linked to #{CrossData.get_name($crossdata[i].parent2)} with chi-square score #{chi_square}"
        puts "\n\n\nFinal Report:\n#{CrossData.get_name($crossdata[i].parent1)} is linked to #{CrossData.get_name($crossdata[i].parent2)}\n#{CrossData.get_name($crossdata[i].parent2)} is linked to #{CrossData.get_name($crossdata[i].parent1)}"
        end
      end
  end
  
  
   
end
