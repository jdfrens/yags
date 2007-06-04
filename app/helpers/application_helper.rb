# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def crossproduct(factor_list)
    if factor_list.empty? 
      [[]]
    else
      first_factor = factor_list.first
      rest_of_factors = factor_list[1..-1]
      binary_crossproduct first_factor, crossproduct(rest_of_factors)
    end
    
  end
  
  private
  def binary_crossproduct(factor, accumulated_product)
    result = []
    factor.each do |e1| 
      accumulated_product.each do |e2|
        result << ( [e1] + e2)
      end
    end
    result
  end
  
end
