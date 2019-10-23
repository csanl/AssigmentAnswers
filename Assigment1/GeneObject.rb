class Gene

  attr_accessor :geneid
  attr_accessor :name
  attr_accessor :mutant_phenotype
  #@@number_of_objects = 0
  

  
  def initialize (params = {}) 
      @geneid = params.fetch(:geneid, 'AT0G00000')
      @name = params.fetch(:name, 'unknown name')
      @mutant_phenotype = params.fetch(:mutant_phenotype, 'unknown phenotype')
      #@@number_of_objects =+ 1
  end

#this Class method creates some objects from a file, they are saved in a global variable called "gene". So for example gene[0] is the object with the @properties=values: @geneid="AT1G69120", @name="ap1", @mutant_phenotype="\"meristems replace first and second whorl\")

  def Gene.data(thisfile)
   File.readlines(thisfile).each_with_index do |line, index|
    next line if index == 0
    geneid, name, mutant_phenotype = line.split("\t")
#to verify the gene id
    match_id = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/)
      if match_id.match(geneid)
      $gene[index-1] = Gene.new(
        :geneid => geneid,
        :name => name,
        :mutant_phenotype => mutant_phenotype)
      else 
      puts "ERROR: Wrong identification number of the gene #{index-1}"
      end
   end
  end
end


