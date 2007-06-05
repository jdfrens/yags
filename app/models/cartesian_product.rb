module CartesianProduct
   
  def cartesian_product(factor_list)
    if factor_list.empty? 
      [[]]
    else
      first_factor = factor_list.first
      rest_of_factors = factor_list[1..-1]
      binary_cartesian_product first_factor, cartesian_product(rest_of_factors)
    end  
  end
  
  private
  def binary_cartesian_product(factor, accumulated_product)
    result = []
    factor.each do |e1| 
      accumulated_product.each do |e2|
        result << ([e1] + e2)
      end
    end
    result
  end
  
end