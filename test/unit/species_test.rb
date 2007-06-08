require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < Test::Unit::TestCase
  fixtures :flies, :genotypes
  
  def test_singleton_is_not_nil
    assert_not_nil Species.singleton 
  end
  
  def test_singleton_represents_fruit_fly
    assert_equal [:gender, :eye_color, :wings, :legs], Species.singleton.characters
    assert_equal [:not_possible, :male, :female], Species.singleton.phenotypes(:gender)
    assert_equal [:white, :red, :red], Species.singleton.phenotypes(:eye_color)
    assert_equal [:curly, :straight, :straight], Species.singleton.phenotypes(:wings)
    assert_equal [:smooth, :hairy, :hairy], Species.singleton.phenotypes(:legs)
    assert_equal 137, Species.singleton.gene_number_of(:gender)
    assert_equal 52, Species.singleton.gene_number_of(:eye_color)
    assert_equal 163, Species.singleton.gene_number_of(:wings)
    assert_equal 7, Species.singleton.gene_number_of(:legs)
  end
  
  def test_phenotype_from
    assert_equal :female, Species.singleton.phenotype_from(:gender, 1, 1)
    assert_equal :male, Species.singleton.phenotype_from(:gender, 0, 1)
    assert_equal :red, Species.singleton.phenotype_from(:eye_color, 1, 0)
    assert_equal :curly, Species.singleton.phenotype_from(:wings, 0, 0)
    assert_equal :hairy, Species.singleton.phenotype_from(:legs, 1, 1)
  end
  
  def test_ordering_of_genotypes
    assert_equal [137, 52, 163, 7], 
        flies(:fly_00).species.order(flies(:fly_00).genotypes).map { |g| g.gene_number }
    assert_equal [137, 52, 163, 7], 
        flies(:bob).species.order(flies(:bob).genotypes).map { |g| g.gene_number }
  end
  
  def test_distance_between
    assert_equal 0.5, Species.singleton.distance_between(nil, 137)
    assert_equal 0.5, Species.singleton.distance_between(137, 52)
    assert_equal 0.5, Species.singleton.distance_between(52, 163)
    
    assert_equal 0.125, Species.singleton.distance_between(163, 7)
    # WARNING: Ruby thinks that 0.2 is not equal to 0.2
    
    assert_equal 0.5, Species.singleton.distance_between(137, 7)
    assert_equal 0.5, Species.singleton.distance_between(52, 7)
    
    assert_equal -1.0, Species.singleton.distance_between(163, 137)
    # is it ok to get negatives when the gene_numbers are backwards?
  end
  
end