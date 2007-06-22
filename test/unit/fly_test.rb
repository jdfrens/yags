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
    assert_equal 5, Genotype.find(:all, :conditions => "fly_id = 5").size # :bob's genotypes
    
    flies(:bob).destroy
    assert_equal number_of_old_flies - 1, Fly.find(:all).size
    assert_equal number_of_old_genotypes - 5, Genotype.find(:all).size
    assert_equal 0, Fly.find(:all, :conditions => "id = 5").size # :bob
    assert_equal 0, Genotype.find(:all, :conditions => "fly_id = 5").size # :bob's genotypes
  end
  
  def test_make_gamete
    assert_equal [[1,137],[1,144],[1,52],[1,163],[1,7]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([0,0,0,0]))
    assert_equal [[1,137],[0,144],[0,52],[0,163],[0,7]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([0,1,0,0]))
    assert_equal [[0,137],[1,144],[0,52],[1,163],[0,7]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([1,1,1,1]))
    assert_equal [[0,137],[0,144],[0,52],[1,163],[0,7]], 
        flies(:gamete_maker).make_gamete(CookedBitGenerator.new([1,0,0,1]))
    assert_equal [[1,137],[0,144],[0,52],[0,163],[1,7]], 
        flies(:bob).make_gamete(CookedBitGenerator.new([1,0,0,0]))
  end
  
  def test_mate_with
    s = Species.singleton
    s.order(flies(:child_one).genotypes).zip(flies(:fly_mom).mate_with(flies(:fly_dad), 
        CookedBitGenerator.new([0])).genotypes) do |pair|
      assert_equal pair[0].gene_number, pair[1].gene_number
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
    s.order(flies(:child_one).genotypes).zip(flies(:fly_dad).mate_with(flies(:fly_mom), 
        CookedBitGenerator.new([0])).genotypes) do |pair|
      assert_equal pair[0].gene_number, pair[1].gene_number
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
    s.order(flies(:child_two).genotypes).zip(flies(:fly_mom).mate_with(flies(:fly_dad), 
        CookedBitGenerator.new([1,0,0,0,0])).genotypes) do |pair|
      assert_equal pair[0].gene_number, pair[1].gene_number
      assert_equal pair[0].mom_allele, pair[1].mom_allele
      assert_equal pair[0].dad_allele, pair[1].dad_allele
    end
    s.order(flies(:child_two).genotypes).zip(flies(:fly_dad).mate_with(flies(:fly_mom), 
        CookedBitGenerator.new([1,0,0,0,0])).genotypes) do |pair|
      assert_equal pair[0].gene_number, pair[1].gene_number
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
