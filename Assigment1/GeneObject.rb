class Gene

  attr_accessor :geneid
  attr_accessor :name
  attr_accessor :mutant_phenotype
  @@number_of_objects = 0
  
# create an "attribute accessor" (read and write) for "name"
  
  def initialize (params = {}) # get a name from the "new" call, or set a default
      @geneid = params.fetch(:geneid, 'AT0G00000')
      @name = params.fetch(:name, 'unknown name')
      @mutant_phenotype = params.fetch(:mutant_phenotype, 'unknown phenotype')
      @@number_of_objects =+ 1
  end
  
  def Gene.data(thisfile)
   File.readlines(thisfile).each_with_index do |line, index|
    next line if index == 0
    geneid, name, mutant_phenotype = line.split("\t")
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


