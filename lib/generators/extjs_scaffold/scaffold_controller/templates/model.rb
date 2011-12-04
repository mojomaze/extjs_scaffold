<%
  # build search query on all attributes
  query = []
  params = []
  attributes.each do |a|
    a.reference? ?  query << "#{a.name.pluralize}.name LIKE ?" : query << "#{plural_table_name}.#{a.name} LIKE ?"
    params << "search"
  end
  
  virtual_fields = {}
  join_tables = []
-%>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  
  def <%= attribute.name %>_name
    <%= attribute.name %>.name if <%= attribute.name %>
  end
  <% virtual_fields["#{attribute.name}_name"] = "#{attribute.name.pluralize}.name" -%>
  <% join_tables << ":#{attribute.name}" -%>
<% end -%>

  # search or return all
  def self.search(query, page, size, sort_column, sort_direction)
  <% if virtual_fields.count > 0 -%>
  # handle sort columns - prepend table name and change reference attrbiutes from 'reftable_name'
    case sort_column
  <% virtual_fields.each do |key, value| -%>
    when '<%= key %>'
      sort_column = '<%= value %>'
  <% end -%>
    else
      sort_column = "<%= plural_table_name %>.#{sort_column}"
    end
  <% end -%>
    if query
      search = "%#{query}%"
    <% if virtual_fields.count > 0 -%>
      return order(sort_column+" "+sort_direction).joins([<%= join_tables.join(',') %>]).where("<%= query.join(' OR ') %>", <%= params.join(',') %>).paginate(:page => page, :per_page => size)
    <% else -%>
      return order(sort_column+" "+sort_direction).where("<%= query.join(' OR ') %>", <%= params.join(',') %>).paginate(:page => page, :per_page => size)
    <% end -%>
    end
  <% if virtual_fields.count > 0 -%>
    order(sort_column+" "+sort_direction).joins([<%= join_tables.join(',') %>]).paginate(:page => page, :per_page => size)
  <% else -%>
    order(sort_column+" "+sort_direction).paginate(:page => page, :per_page => size)
  <% end -%>
  end
