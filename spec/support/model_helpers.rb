module ModelHelpers

  # TODO: stinky
  def phenotypes_of(container, character)
    if (container.respond_to?(:flies))
      flies = container.flies
    else
      flies = container
    end
    flies.map { |fly| fly.phenotype(character) }
  end

  # TODO: stinky
  def assert_basically_the_same_fly(fly1, fly2)
    assert_equal fly1.species.characters, fly2.species.characters
    fly1.species.order(fly1.genotypes).zup(fly2.genotypes) do |fly1_genotype, fly2_genotype|
      assert_equal fly1_genotype.gene_number, fly2_genotype.gene_number, "gene number"
      assert_equal fly1_genotype.mom_allele, fly2_genotype.mom_allele, "mom allele for #{fly1_genotype.gene_number}"
      assert_equal fly1_genotype.dad_allele, fly2_genotype.dad_allele, "dad allele for #{fly1_genotype.gene_number}"
    end
  end

end
