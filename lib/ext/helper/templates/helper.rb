module <%= class_name %>Helper
  # handles sorting from index.html.erb view
  # will be duplicated for each controller - move to application_helper.rb for muliple controllers
  
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc" 
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
end
