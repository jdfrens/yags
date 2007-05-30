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
end
