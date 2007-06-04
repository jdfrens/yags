require File.dirname(__FILE__) + '/../test_helper'

class FlyTest < Test::Unit::TestCase
  fixtures :flies, :genotypes

  def test_phenotype_eye_color
    assert_equal :white, flies(:fly_00).phenotype(:eye_color)
    assert_equal :red, flies(:fly_01).phenotype(:eye_color)
    assert_equal :red, flies(:fly_10).phenotype(:eye_color)
    assert_equal :red, flies(:fly_11).phenotype(:eye_color)
  end
  
  def test_phenotype_gender
    assert_equal :male, flies(:fly_00).phenotype(:gender)
    assert_equal :male, flies(:fly_01).phenotype(:gender)
    assert_equal :male, flies(:fly_10).phenotype(:gender)
    assert_equal :female, flies(:fly_11).phenotype(:gender)
  end
  
  def test_deletion_of_genotypes_upon_deletion_of_fly
    number_of_old_flies = Fly.find(:all).size
    number_of_old_genotypes = Genotype.find(:all).size
    assert_equal 1, Fly.find(:all, :conditions => "id = 5").size # :bob
    assert_equal 2, Genotype.find(:all, :conditions => "id = 9 or id = 10").size # :bob's genotypes
    
    flies(:bob).destroy
    assert_equal number_of_old_flies - 1, Fly.find(:all).size
    assert_equal number_of_old_genotypes - 2, Genotype.find(:all).size
    assert_equal 0, Fly.find(:all, :conditions => "id = 5").size # :bob
    assert_equal 0, Genotype.find(:all, :conditions => "id = 9 or id = 10").size # :bob's genotypes
  end
  
  def test_mate_with
    flies(:child_one).genotypes.zip(flies(:fly_mom).mate_with(flies(:fly_dad), CookedBitGenerator.new([0])).genotypes) do |pair|
      assert_equal pair[0].position, pair[1].position
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
    flies(:child_one).genotypes.zip(flies(:fly_dad).mate_with(flies(:fly_mom), CookedBitGenerator.new([0])).genotypes) do |pair|
      assert_equal pair[0].position, pair[1].position
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
    flies(:child_two).genotypes.zip(flies(:fly_mom).mate_with(flies(:fly_dad), CookedBitGenerator.new([1])).genotypes) do |pair|
      assert_equal pair[0].position, pair[1].position
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
  flies(:child_two).genotypes.zip(flies(:fly_dad).mate_with(flies(:fly_mom), CookedBitGenerator.new([1])).genotypes) do |pair|
      assert_equal pair[0].position, pair[1].position
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
  end
  
  def test_mate_with_same_sex
    assert_raise ArgumentError do
      flies(:fly_mom).mate_with(flies(:fly_11))   
    end
    assert_raise ArgumentError do
      flies(:fly_dad).mate_with(flies(:fly_00))    
    end
  end
  
  def test_has_species
    assert_not_nil flies(:fly_mom).species
  end
  
end
