require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < Test::Unit::TestCase
  all_fixtures
  
  def test_singleton_is_not_nil
    assert_not_nil Species.singleton 
  end
  
  def test_singleton_represents_fruit_fly
    assert_equal [:sex, :"eye color", :wings, :legs, :antenna, :seizure], Species.singleton.characters
    assert_equal [:male, :female], Species.singleton.phenotypes(:sex)
    assert_equal [:white, :red], Species.singleton.phenotypes(:"eye color")
    assert_equal [:curly, :straight], Species.singleton.phenotypes(:wings)
    assert_equal [:smooth, :hairy], Species.singleton.phenotypes(:legs)
    assert_equal [:short, :long], Species.singleton.phenotypes(:antenna)
    assert_equal [:"no seizure", :"20% seizure", :"40% seizure"], Species.singleton.phenotypes(:seizure)
    assert_equal 137, Species.singleton.gene_number_of(:sex)
    assert_equal 52, Species.singleton.gene_number_of(:"eye color")
    assert_equal 163, Species.singleton.gene_number_of(:wings)
    assert_equal 7, Species.singleton.gene_number_of(:legs)
    assert_equal 144, Species.singleton.gene_number_of(:antenna)
    assert_equal 19, Species.singleton.gene_number_of(:seizure)
  end
  
  def test_alternate_phenotypes
    assert_equal [:orange, :beige, :turquoise, :blue, :green, :maroon], 
        Species.singleton.alternate_phenotypes(:"eye color")
    assert_equal [], Species.singleton.alternate_phenotypes(:sex)
    assert_equal [], Species.singleton.alternate_phenotypes(:wings)
    assert_equal [], Species.singleton.alternate_phenotypes(:legs)
    assert_equal [], Species.singleton.alternate_phenotypes(:antenna)
  end
  
  def test_phenotype_from
    assert_equal :female, Species.singleton.phenotype_from(:sex, 1, 1)
    assert_equal :male, Species.singleton.phenotype_from(:sex, 0, 1)
    assert_equal :red, Species.singleton.phenotype_from(:"eye color", 1, 0)
    assert_equal :curly, Species.singleton.phenotype_from(:wings, 0, 0)
    assert_equal :hairy, Species.singleton.phenotype_from(:legs, 1, 1)
    assert_equal :short, Species.singleton.phenotype_from(:antenna, 0, 0)
  end
  
  def test_ordering_of_genotypes
    assert_equal [137, 144, 52, 163, 7, 19], 
        flies(:fly_dad).species.order(flies(:fly_dad).genotypes).map { |g| g.gene_number }
    assert_equal [137, 144, 52, 163, 7, 19], 
        flies(:fly_00).species.order(flies(:fly_00).genotypes).map { |g| g.gene_number }
  end
  
  def test_distance_between
    assert_equal 0.5, Species.singleton.distance_between(nil, 137)
    assert_equal 0.5, Species.singleton.distance_between(137, 52)
    assert_equal 0.5, Species.singleton.distance_between(52, 163)
    assert_in_delta 0.2, Species.singleton.distance_between(163, 7), 1.0e-10
    assert_equal 0.5, Species.singleton.distance_between(137, 7)
    assert_equal 0.5, Species.singleton.distance_between(52, 7)
    assert_equal 0.0, Species.singleton.distance_between(137, 144)
    assert_equal 0.5, Species.singleton.distance_between(144, 19)
    
    assert_equal -1.0, Species.singleton.distance_between(163, 137)
    # is it ok to get negatives when the gene_numbers are backwards?
  end
  
  def test_is_sex_linked?
    assert !Species.singleton.is_sex_linked?(:"eye color")
    assert !Species.singleton.is_sex_linked?(:wings)
    assert !Species.singleton.is_sex_linked?(:legs)
    assert !Species.singleton.is_sex_linked?(:sex)
    assert !Species.singleton.is_sex_linked?(:seizure)
    
    assert Species.singleton.is_sex_linked?(:antenna)
  end
  
end