class <%= controller_class_name %>Controller < ApplicationController
  helper_method :sort_column, :sort_direction
  
  respond_to :html, :js, :json
  
  # GET <%= route_url %>
  def index
    params[:page] ||= 1
    params[:limit] ||= 40
    @<%= plural_table_name %> = <%= class_name %>.search(params[:query], params[:page], params[:limit], sort_column, sort_direction)
    respond_with @<%= plural_table_name %> do |format|
      format.json { render :json => format_json({:collection => @<%= plural_table_name %>}), :layout => false }
    end
  end
  
  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.js
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with @<%= singular_table_name %> do |format|
      format.json { render :json => format_json({:member => @<%= singular_table_name %>}), :layout => false }
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
      format.any { render :json => format_json({:data => @<%= singular_table_name %>}), :layout => false }
    end
  end
  
  # POST <%= route_url %>
  def create
    params[:<%= singular_table_name %>] = filter_params(params[:<%= singular_table_name %>])
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    @<%= orm_instance.save %>
    respond_with @<%= singular_table_name %> do |format|
      if @<%= singular_table_name %>.invalid?
        format.any { render :json => { :success => false, :error_count => @<%= singular_table_name %>.errors.count, :errors => @<%= singular_table_name %>.errors }.to_json, :layout => false }
      else
        format.any { render :json => format_json({:member => @<%= singular_table_name %>}), :layout => false }
      end
    end
  end

  # PUT <%= route_url %>/1
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    params[:<%= singular_table_name %>] = filter_params(params[:<%= singular_table_name %>])
    respond_with @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %> do |format|
      if @<%= singular_table_name %>.invalid?
        format.any { render :json => { :success => false, :error_count => @<%= singular_table_name %>.errors.count, :errors => @<%= singular_table_name %>.errors }.to_json, :layout => false }
      else
        format.any { render :json => format_json({:member => @<%= singular_table_name %>}), :layout => false }
      end
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>
    respond_with @<%= singular_table_name %>
  end
  
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
        @errors << "<div><b>Record Not Found - Changes rolled back</div>"
        raise ActiveRecord::Rollback
      end
    end
    respond_with @errors do |format|
      if @errors.size > 0
        format.any { render :json => { :success => false, :errorMsg => @errors.join }.to_json, :layout => false }
      else
        format.any { render :json => { :success => true }.to_json, :layout => false }
      end
    end
  end
  
  def update_all
    @errors = []
    params[:<%= singular_table_name %>] = ActiveSupport::JSON.decode(params[:<%= singular_table_name %>]) if params[:<%= singular_table_name %>] && request.format == 'json'
    # perform updates in transaction - rollback if any fail
    <%= class_name %>.transaction do
      begin
        params[:<%= singular_table_name %>].each do |<%= singular_table_name %>|
          @<%= singular_table_name %> = <%= orm_class.find(class_name, "#{singular_table_name}[:id]") %>
          if !@<%= orm_instance.update_attributes("params[#{singular_table_name}]") %>
            @<%= singular_table_name %>.errors.each_full do |error|
              @errors << "<div><b>#{@<%= singular_table_name %>.id}</b>: #{ error }</div>"
            end
            raise ActiveRecord::Rollback
            break
          end
        end
      rescue ActiveRecord::RecordNotFound
        @errors << "<div><b>Record Not Found - Changes rolled back</div>"
        raise ActiveRecord::Rollback
      end
    end
    respond_with @errors do |format|
      if @errors.size > 0
        format.any { render :json => { :success => false, :errorMsg => @errors.join }.to_json, :layout => false }
      else
        format.any { render :json => { :success => true }.to_json, :layout => false }
      end
    end
  end
  
  private
  
  def sort_column
    # set defualt sort column
    <%  default_sort = ''
        if attributes.first 
          default_sort = attributes.first.name 
          if attributes.first.reference?
            default_sort += '_name'
          end 
        end
    -%>
    sort = ActiveSupport::JSON.decode(params[:sort]) if params[:sort]
    if sort
      session["<%= singular_table_name %>_sort_column"] = <%= class_name %>.column_names.include?(sort[0]['property']) || <%= class_name %>.method_defined?(sort[0]['property']) ? sort[0]['property'] : session["<%= singular_table_name %>_sort_column"]
    else
      session["<%= singular_table_name %>_sort_column"] ||= '<%= default_sort %>'
      session["<%= singular_table_name %>_sort_column"] = session["<%= singular_table_name %>_sort_column"]
    end
  end
  
  def sort_direction
    # set default sort direction
    sort = ActiveSupport::JSON.decode(params[:sort]) if params[:sort]
    if sort
      session["<%= singular_table_name %>_sort_direction"] = %w[ASC DESC].include?(sort[0]['direction']) ? sort[0]['direction'] : session["<%= singular_table_name %>_sort_direction"]
    else
      session["<%= singular_table_name %>_sort_direction"] ||= 'ASC'
      session["<%= singular_table_name %>_sort_direction"] = session["<%= singular_table_name %>_sort_direction"]
    end
  end
  
  def safeDateStr(datetime)
    datestr = ''
    datetime = DateTime.parse(datetime) if datetime.class == String
    datestr = datetime.strftime('%Y-%m-%d') if datetime
    datestr
  end
  
  def fix_dates(datestr)
    # change mm-dd-yy to yy-mm-dd to be safe
    datestr =~ %r{(\d+)(/|:)(\d+)(/|:)(\d+)}
    return "#{$5}-#{$1}-#{$3}"
  end
  
  def filter_params(<%= singular_table_name %>)
    # filter booleans and fix dateparse for ruby 1.9.2p0 - wtf!!!
    <% attributes.each do |attribute|
      case attribute.type.to_s
      when 'boolean' -%>
    <%= singular_table_name %>[:<%= attribute.name %>] = <%= singular_table_name %>[:<%= attribute.name %>] ? 'true' : 'false'
      <% when 'date' -%>
        <%= singular_table_name -%>[:<%= attribute.name %>] = fix_dates(<%= singular_table_name %>[:<%= attribute.name %>])
      <% end -%>
    <% end -%>
    return <%= singular_table_name %>
  end
  
  <%
    related_attr = []
    attributes.select {|attr| attr.reference? }.each do |attribute|
      related_attr << ":#{attribute.name}_name"
    end 
  %>
  
  def format_json(options = {})
    if options.include? :collection
      @<%= plural_table_name %> = options[:collection]
      return '{"total":'+@<%= plural_table_name %>.total_entries.to_s+',"<%= singular_table_name %>":'+@<%= plural_table_name %>.to_json(:methods => [<%= related_attr.join(",") %>])+'}'
    end
    if options.include? :member
      @<%= singular_table_name -%> = options[:member]
      return '{"success":true,"data":'+@<%= singular_table_name -%>.to_json(:methods => [<%= related_attr.join(",") %>])+'}'
    end
    if options.include? :data
      @<%= singular_table_name -%> = options[:data]
      return '{"success":true,"data":'+@<%= singular_table_name -%>.to_json(:methods => [<%= related_attr.join(",") %>])+'}'
    end
  end
end
