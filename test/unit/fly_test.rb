require File.dirname(__FILE__) + '/../test_helper'

class FlyTest < Test::Unit::TestCase
  fixtures :flies, :genotypes

  def test_phenotype_eye_color
    assert_equal :white, flies(:fly_00).phenotype(:"eye color")
    assert_equal :red, flies(:fly_01).phenotype(:"eye color")
    assert_equal :red, flies(:fly_10).phenotype(:"eye color")
    assert_equal :red, flies(:fly_11).phenotype(:"eye color")
  end
  
  def test_phenotype_sex
    assert_equal :male, flies(:fly_00).phenotype(:sex)
    assert_equal :male, flies(:fly_01).phenotype(:sex)
    assert_equal :male, flies(:fly_10).phenotype(:sex)
    assert_equal :female, flies(:fly_11).phenotype(:sex)
  end
  
  def test_genotypes_are_destroyed_along_with_fly
    assert_dependents_destroyed(Fly, Genotype, :foreign_key => "fly_id", 
        :fixture_id => 5, :number_of_dependents => 6)
  end
  
  def test_make_gamete
    assert_equal [[1,137],[1,144],[1,52],[1,163],[1,7],[1,19]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([0,0,0,0]))
    assert_equal [[1,137],[0,144],[0,52],[0,163],[0,7],[1,19]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([0,1,0,0]))
    assert_equal [[0,137],[1,144],[0,52],[1,163],[0,7],[1,19]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([1,1,1,1]))
    assert_equal [[0,137],[0,144],[0,52],[1,163],[0,7],[0,19]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([1,0,0,1]))
    assert_equal [[1,137],[0,144],[0,52],[0,163],[1,7],[0,19]], 
        flies(:bob).make_gamete(CookedBitGenerator.new([1,0,0,0]))
  end
  
  def test_mate_with
    assert_basically_the_same_fly flies(:child_one), 
        flies(:fly_mom).mate_with(flies(:fly_dad), CookedBitGenerator.new([0]))
    assert_basically_the_same_fly flies(:child_one), 
        flies(:fly_dad).mate_with(flies(:fly_mom), CookedBitGenerator.new([0]))
    assert_basically_the_same_fly flies(:child_two), 
        flies(:fly_mom).mate_with(flies(:fly_dad), CookedBitGenerator.new([1,0,0,0,0,0]))
    assert_basically_the_same_fly flies(:child_two), 
        flies(:fly_dad).mate_with(flies(:fly_mom), CookedBitGenerator.new([1,0,0,0,0,0]))
  end
  
  def test_mate_with_same_sex
    assert_raise ArgumentError do
      flies(:fly_mom).mate_with(flies(:fly_11))   
    end
    assert_raise ArgumentError do
      flies(:fly_dad).mate_with(flies(:fly_00))    
    end
  end
  
  def test_male?
    assert flies(:fly_dad).male?
    assert flies(:fly_00).male?
    assert !flies(:fly_mom).male?
    assert !flies(:fly_11).male?
  end
  
  def test_female?
    assert flies(:fly_mom).female?
    assert flies(:fly_11).female?
    assert !flies(:fly_dad).female?
    assert !flies(:fly_00).female?
  end
  
  def test_each_fly_has_a_species
    Fly.find(:all).each do |fly|
      assert_not_nil fly.species
    end
  end
  
  def test_each_fly_has_all_genotypes_of_its_species
    Fly.find(:all).each do |fly|
      assert_equal fly.species.characters.size, fly.genotypes.size
      fly.species.characters.each do |character|
        assert_equal 1, fly.genotypes.select { |g| # why can't this be a do end block?
          g.gene_number == fly.species.gene_number_of(character)
        }.size
      end
    end
  end
  
end
