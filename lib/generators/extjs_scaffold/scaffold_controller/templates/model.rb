<%
  # build search query on all attributes
  query = []
  params = []
  attributes.each do |a|
    a.reference? ?  query << "#{a.name.pluralize}.#{reference_field(a)} LIKE ?" : query << "#{plural_table_name}.#{a.name} LIKE ?"
    params << "search"
  end
  
  virtual_fields = {}
  join_tables = []
-%>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  
  validates :<%= attribute.name %>_<%= reference_field(attribute) %>, :presence => true

  def <%= attribute.name %>_<%= reference_field(attribute) %>
    <%= attribute.name %>.<%= reference_field(attribute) %> if <%= attribute.name %>
  end

  def <%= attribute.name %>_<%= reference_field(attribute) %>=(<%= reference_field(attribute) %>)
    # empty setter for update_all
  end
  <% virtual_fields["#{attribute.name}_#{reference_field(attribute)}"] = "#{attribute.name.pluralize}.#{reference_field(attribute)}" -%>
  <% join_tables << ":#{attribute.name}" -%>
<% end -%>

  # search or return all
  def self.search(query, page, size, sort_column, sort_direction)
  <% if virtual_fields.count > 0 -%>
  # handle sort columns - prepend table name and add reference attributes
    case sort_column
  <% virtual_fields.each do |key, value| -%>
    when '<%= key %>'
      sort_column = '<%= value %>'
  <% end -%>
    else
      sort_column = "<%= plural_table_name %>.#{sort_column}"
    end
  <% end -%>
  <%
    pagination_string = @pagination == "will_paginate" ? "paginate(:page => page, :per_page => size)" : "page(page).per(size)"
  -%>
if query
      search = "%#{query}%"
    <% if virtual_fields.count > 0 -%>
  return order(sort_column+" "+sort_direction).joins([<%= join_tables.join(',') %>]).where("<%= query.join(' OR ') %>", <%= params.join(',') %>).<%= pagination_string %>
    <% else -%>
  return order(sort_column+" "+sort_direction).where("<%= query.join(' OR ') %>", <%= params.join(',') %>).<%= pagination_string %>
    <% end -%>
end
  <% if virtual_fields.count > 0 -%>
  order(sort_column+" "+sort_direction).joins([<%= join_tables.join(',') %>]).<%= pagination_string %>
  <% else -%>
  order(sort_column+" "+sort_direction).page(page).<%= pagination_string %>
  <% end -%>
end
