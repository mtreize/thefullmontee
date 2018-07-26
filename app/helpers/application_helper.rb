module ApplicationHelper
  def chart_colors
    ["#339FB5","#B53333","#07750E","#E0E25B","#777777","#9B4BCA","#E98A1E"]
  end
  
  def color_array_for_stats_graphs
    ["#4792DB","#915B87","#18A2B8","#4D819D","#B7B9BB","#D1B0D5","#F8618E","#C8A403","#0F5DBB","#137124","#4A4A47"]
  end
  
	def mean(array)
	  array.inject(0) { |sum, x| sum += x } / array.size.to_f
	end

end
