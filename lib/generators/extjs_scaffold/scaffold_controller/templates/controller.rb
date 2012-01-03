class <%= controller_class_name %>Controller < ApplicationController
  respond_to :html, :json
  
  # GET <%= route_url %>
  def index
    params[:page] ||= 1
    params[:limit] ||= 40
    @<%= plural_table_name %> = <%= class_name %>.search(params[:query], params[:page], params[:limit], sort_column, sort_direction)
    respond_with @<%= plural_table_name %> do |format|
      format.json { render :extjs => @<%= plural_table_name %>, :methods => related_attributes }
    end
  end
  
  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.js
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with @<%= singular_table_name %> do |format|
      format.json { render :extjs => @<%= singular_table_name %>, :methods => related_attributes }
    end
  end

  # GET <%= route_url %>/new
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    respond_with @<%= singular_table_name %>
  end

  # GET <%= route_url %>/1/edit
  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with @<%= singular_table_name %> do |format|
      format.json { render :extjs => @<%= singular_table_name %>, :methods => related_attributes }
    end
  end
  
  # POST <%= route_url %>
  def create
    params[:<%= singular_table_name %>] = filter_params(params[:<%= singular_table_name %>])
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    if @<%= orm_instance.save %>
      respond_with @<%= singular_table_name %> do |format|
        format.json { render :extjs => @<%= singular_table_name %>, :methods => related_attributes }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false, :error_count => @<%= singular_table_name %>.errors.count, :errors => @<%= singular_table_name %>.errors }.to_json, :layout => false }
        format.html
      end
    end
  end

  # PUT <%= route_url %>/1
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    params[:<%= singular_table_name %>] = filter_params(params[:<%= singular_table_name %>])
    respond_with @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %> do |format|
      if @<%= singular_table_name %>.invalid?
        format.json { render :json => { :success => false, :error_count => @<%= singular_table_name %>.errors.count, :errors => @<%= singular_table_name %>.errors }.to_json, :layout => false }
      else
        format.json { render :extjs => @<%= singular_table_name %>, :methods => related_attributes }
      end
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>
    respond_with @<%= singular_table_name %>
  end
  
  # json only
  def destroy_all
    @errors = []
    params[:<%= singular_table_name %>] = ActiveSupport::JSON.decode(params[:<%= singular_table_name %>]) if params[:<%= singular_table_name %>] && request.format == 'json'
    # perform deletes in transaction - rollback if any fail
    <%= class_name %>.transaction do
      begin
        params[:<%= singular_table_name %>].each do |<%= singular_table_name %>|
          @<%= singular_table_name %> = <%= orm_class.find(class_name, "#{singular_table_name}[:id]") %> 
          if !@<%= orm_instance.destroy %>
            @<%= singular_table_name %>.errors.each_full do |error|
              @errors << "<div><b>#{@<%= singular_table_name %>.id}</b>: #{ error }</div>"
            end
            raise ActiveRecord::Rollback
            break
          end
        end
      rescue ActiveRecord::RecordNotFound
        @errors << "<div>Record Not Found - Changes rolled back</div>"
        raise ActiveRecord::Rollback
      end
    end
    respond_with @errors do |format|
      if @errors.size > 0
        format.json { render :json => { :success => false, :errors => @errors.join }.to_json, :layout => false }
      else
        format.json { render :json => { :success => true }.to_json, :layout => false }
      end
    end
  end
  
  # json only
  def update_all
    @errors = []
    params[:<%= singular_table_name %>] = ActiveSupport::JSON.decode(params[:<%= singular_table_name %>]) if params[:<%= singular_table_name %>] && request.format == 'json'
    # perform updates in transaction - rollback if any fail
    <%= class_name %>.transaction do
      begin
        params[:<%= singular_table_name %>].each do |<%= singular_table_name %>|
          @<%= singular_table_name %> = <%= orm_class.find(class_name, "#{singular_table_name}[:id]") %>
          if !@<%= orm_instance.update_attributes("#{singular_table_name}") %>
            @<%= singular_table_name %>.errors.each_full do |error|
              @errors << "<div><b>#{@<%= singular_table_name %>.id}</b>: #{ error }</div>"
            end
            raise ActiveRecord::Rollback
            break
          end
        end
      rescue ActiveRecord::RecordNotFound
        @errors << "<div>Record Not Found - Changes rolled back</div>"
        raise ActiveRecord::Rollback
      end
    end
    respond_with @errors do |format|
      if @errors.size > 0
        format.json { render :json => { :success => false, :errors => @errors.join }.to_json, :layout => false }
      else
        format.json { render :json => { :success => true }.to_json, :layout => false }
      end
    end
  end
  
  private
  # set passed sort property or default to first attribute
  def sort_column
    # set defualt sort column
    <%  default_sort = ''
        if attributes.first 
          default_sort = attributes.first.name 
          if attributes.first.reference?
            default_sort += "_#{reference_field(attributes.first)}"
          end 
        end
    -%>
    sort = ActiveSupport::JSON.decode(params[:sort]) if params[:sort]
    return sort[0]['property'] if sort && ( <%= class_name %>.column_names.include?(sort[0]['property']) || <%= class_name %>.method_defined?(sort[0]['property']) )
    return '<%= default_sort %>'
  end
  
  # set passed sort direction or default to ASC
  def sort_direction
    # set default sort direction
    sort = ActiveSupport::JSON.decode(params[:sort]) if params[:sort]
    return sort[0]['direction'] if sort && %w[ASC DESC].include?(sort[0]['direction'])
    return 'ASC'
  end
  
  def filter_dates(datestr)
    # change mm-dd-yyyy to yyyy-mm-dd
    datestr =~ %r{(\d+)(/|:)(\d+)(/|:)(\d+)}
    return "#{$5}-#{$1}-#{$3}"
  end
  
  def filter_params(<%= singular_table_name %>)
    # filter booleans and dates
    <% attributes.each do |attribute|
      case attribute.type.to_s
      when 'boolean' -%>
    <%= singular_table_name %>[:<%= attribute.name %>] = <%= singular_table_name %>[:<%= attribute.name %>] ? 'true' : 'false'
      <% when 'date' -%>
        <%= singular_table_name -%>[:<%= attribute.name %>] = filter_dates(<%= singular_table_name %>[:<%= attribute.name %>])
      <% end -%>
    <% end -%>
    return <%= singular_table_name %>
  end
  
  <%
    related_attr = []
    attributes.select {|attr| attr.reference? }.each do |attribute|
      related_attr << ":#{attribute.name}_#{reference_field(attribute)}"
    end 
  %>
  
  # related attributes sent via json
  def related_attributes
    [<%= related_attr.join(",") %>]
  end

end
