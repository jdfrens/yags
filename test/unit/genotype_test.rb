require File.dirname(__FILE__) + '/../test_helper'

class GenotypeTest < ActiveSupport::TestCase
  fixtures :genotypes, :flies, :vials

  def test_belongs_to_fly
    assert_equal flies(:fly_00), genotypes(:fly_00_eye_color).fly
  end
  
  def test_genotype_for?
    assert  genotypes(:fly_00_eye_color).genotype_for?(:"eye color")
    assert !genotypes(:fly_00_eye_color).genotype_for?(:antenna)
    assert !genotypes(:fly_00_eye_color).genotype_for?(:sex)

    assert !genotypes(:fly_00_antenna).genotype_for?(:"eyecolor")
    assert  genotypes(:fly_00_antenna).genotype_for?(:antenna)
    assert !genotypes(:fly_00_antenna).genotype_for?(:sex)
  end
end
