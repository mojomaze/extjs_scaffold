<%
  # build reference fields
  refs = attributes.select {|attr| attr.reference? }.collect{|a| a.name }
-%>
require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  setup do
    @<%= singular_table_name %> = <%= plural_table_name %>(:one)
  <% refs.each_with_index do |ref| -%>
  @<%= singular_table_name %>.<%= ref %> = <%= ref.pluralize %>(:one)
  <% end -%>
  @<%= singular_table_name %>_2 = <%= plural_table_name %>(:two)
  <% refs.each_with_index do |ref| -%>
  @<%= singular_table_name %>_2.<%= ref %> = <%= ref.pluralize %>(:two)
  <% end -%>
end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= plural_table_name %>)
  end

  test "should create <%= singular_table_name %>" do
    assert_difference('<%= class_name %>.count') do
      post :create, <%= resource_attributes %>
    end

    assert_redirected_to <%= singular_table_name %>_path(assigns(:<%= singular_table_name %>))
  end
  
  test "should create <%= singular_table_name %> via xhr json requests" do
    assert_difference('<%= class_name %>.count') do
      xhr :post, :create, <%= resource_attributes %>, :format => :json
    end
    
    json = ActiveSupport::JSON.decode(@response.body)
    assert json['success']
    assert_equal json['data']['id'], <%= class_name %>.last.id
  end

  test "should show <%= singular_table_name %> via xhr json" do
    xhr :get, :show, id: @<%= singular_table_name %>.to_param, :format => :json
    json = ActiveSupport::JSON.decode(@response.body)
    assert json['success']
    assert_equal json['data']['id'], @<%= singular_table_name %>.id
  end

  test "should get edit <%= singular_table_name %> via xhr json" do
    xhr :get, :edit, id: @<%= singular_table_name %>.to_param, :format => :json
    json = ActiveSupport::JSON.decode(@response.body)
    assert json['success']
    assert_equal json['data']['id'], @<%= singular_table_name %>.id
  end
   
  test "should update <%= singular_table_name %> via xhr json" do
    xhr :put, :update, id: @<%= singular_table_name %>.to_param, <%= resource_attributes %>, :format => :json
    json = ActiveSupport::JSON.decode(@response.body)
    assert json['success']
    assert_equal json['data']['id'], @<%= singular_table_name %>.id
  end

  test "should destroy <%= singular_table_name %>" do
    assert_difference('<%= class_name %>.count', -1) do
      delete :destroy, id: @<%= singular_table_name %>.to_param
    end

    assert_redirected_to <%= plural_table_name %>_path
  end
  
  test "should destroy_all via xhr json" do
    assert_difference('<%= class_name %>.count', -2) do
      xhr :post, :destroy_all, <%= singular_table_name %>: [@<%= singular_table_name %>, @<%= singular_table_name %>_2].to_json, :format => :json
    end
    json = ActiveSupport::JSON.decode(@response.body)
    assert json['success']
  end
  
  test "should update_all via xhr json" do
    xhr :post, :destroy_all, <%= singular_table_name %>: [@<%= singular_table_name %>, @<%= singular_table_name %>_2].to_json, :format => :json
    json = ActiveSupport::JSON.decode(@response.body)
    assert json['success']
  end
end
