<%
  # build reference fields
  refs = attributes.select {|attr| attr.reference? }.collect{|a| a.name }
-%>
require 'spec_helper'

describe <%= controller_class_name %>Controller do

  def valid_attributes
      { 
  <% refs.each_with_index do |ref, index| -%>
      <%= ", " if index > 0 %>:<%= ref %>_id => <%= ref.classify %>.create!(<%= ref %>_valid_attributes)
  <% end -%>
      }
  end

<% refs.each_with_index do |ref| -%>
  def <%= ref %>_valid_attributes
    {}
  end
  
<% end -%>
  describe "GET index" do
    it "assigns all <%= plural_table_name %> as @<%= plural_table_name %>" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      get :index
      assigns(:<%= plural_table_name %>).should eq([<%= singular_table_name %>])
    end
    
    it "renders index template" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      get :index
      render_template("index")
    end
    
    it "responds to xhr json requests" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      xhr :get, :index, :format => :json
      json = ActiveSupport::JSON.decode(response.body)
      json['total'].should eq(1)
      json['<%= singular_table_name %>'].size.should eq(1)
      json['<%= singular_table_name %>'].first['id'].should eq(<%= singular_table_name %>.id)
    end
  end
  
  describe "GET show" do
    it "responds to xhr json requests" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      xhr :get, :show, :id => <%= singular_table_name %>.id, :format => :json
      json = ActiveSupport::JSON.decode(response.body)
      json['success'].should be_true
      json['data']['id'].should eq(<%= singular_table_name %>.id)
    end
  end
  
  describe "GET edit" do
    it "responds to xhr json requests" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      xhr :get, :edit, :id => <%= singular_table_name %>.id, :format => :json
      json = ActiveSupport::JSON.decode(response.body)
      json['success'].should be_true
      json['data']['id'].should eq(<%= singular_table_name %>.id)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new <%= class_name %>" do
        expect {
          post :create, :<%= singular_table_name %> => valid_attributes
        }.to change(<%= class_name %>, :count).by(1)
      end

      it "assigns a newly created <%= singular_table_name %> as @<%= singular_table_name %>" do
        post :create, :<%= singular_table_name %> => valid_attributes
        assigns(:<%= singular_table_name %>).should be_a(<%= class_name %>)
        assigns(:<%= singular_table_name %>).should be_persisted
      end

      it "redirects to the created <%= singular_table_name %>" do
        post :create, :<%= singular_table_name %> => valid_attributes
        response.should redirect_to(<%= class_name %>.last)
      end
      
      it "responds to xhr json requests" do
        xhr :post, :create, :<%= singular_table_name %> => valid_attributes, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
        json['data']['id'].should eq(<%= class_name %>.last.id)
      end
    end

    describe "with invalid params" do
      it "responds to xhr json requests" do
        # Trigger the behavior that occurs when invalid params are submitted
        <%= class_name %>.any_instance.stub(:save).and_return(false)
        xhr :post, :create, :<%= singular_table_name %> => valid_attributes, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "responds to xhr json requests" do
        <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
        xhr :put, :update, :id => <%= singular_table_name %>.id, :<%= singular_table_name %> => valid_attributes, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
        json['data']['id'].should eq(<%= singular_table_name %>.id)
        
      end
    end

    describe "with invalid params" do
      it "responds to xhr json requests" do
        <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        <%= class_name %>.any_instance.stub(:invalid?).and_return(true)
        xhr :put, :update, :id => <%= singular_table_name %>.id, :<%= singular_table_name %> => {}, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested <%= singular_table_name %>" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      expect {
        delete :destroy, :id => <%= singular_table_name %>.id
      }.to change(<%= class_name %>, :count).by(-1)
    end

    it "redirects to the <%= plural_table_name %> list" do
      <%= singular_table_name %> = <%= class_name %>.create! valid_attributes
      delete :destroy, :id => <%= singular_table_name %>.id
      response.should redirect_to(<%= plural_table_name %>_url)
    end
  end
  
  describe "POST destory_all" do
    describe "with valid params" do
      it "responds to xhr json requests" do
        <%= singular_table_name %> = []
        2.times{|n| <%= singular_table_name %> << <%= class_name %>.create!(valid_attributes) }
        expect {
          xhr :post, :destroy_all, :<%= singular_table_name %> => <%= singular_table_name %>.to_json, :format => :json
        }.to change(<%= class_name %>, :count).by(-2)
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
      end
    end
    
    describe "with invalid params" do
      it "responds to xhr json requests" do
        <%= singular_table_name %> = []
        2.times{|n| <%= singular_table_name %> << <%= class_name %>.create!(valid_attributes) }
        <%= class_name %>.find(<%= singular_table_name %>.last).destroy
        expect {
          xhr :post, :destroy_all, :<%= singular_table_name %> => <%= singular_table_name %>.to_json, :format => :json
        }.to change(<%= class_name %>, :count).by(0)
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end
  
  describe "POST update_all" do
    describe "with valid params" do
      it "responds to xhr json requests" do
        <%= singular_table_name %> = []
        2.times{|n| <%= singular_table_name %> << <%= class_name %>.create!(valid_attributes) }
        xhr :post, :update_all, :<%= singular_table_name %> => <%= singular_table_name %>.to_json, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
      end
    end
    
    describe "with invalid params" do
      it "responds to xhr json requests" do
        <%= singular_table_name %> = []
        2.times{|n| <%= singular_table_name %> << <%= class_name %>.create!(valid_attributes) }
        <%= class_name %>.find(<%= singular_table_name %>.last).destroy
        xhr :post, :update_all, :<%= singular_table_name %> => <%= singular_table_name %>.to_json, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end

end
