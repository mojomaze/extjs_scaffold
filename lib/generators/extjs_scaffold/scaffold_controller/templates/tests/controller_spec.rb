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
      part = Part.create! valid_attributes
      get :index
      render_template("index")
    end
    
    it "responds to xhr json requests" do
      part = Part.create! valid_attributes
      xhr :get, :index, :format => :json
      json = ActiveSupport::JSON.decode(response.body)
      json['total'].should eq(1)
      json['part'].size.should eq(1)
      json['part'].first['id'].should eq(part.id)
    end
  end
  
  describe "GET show" do
    it "responds to xhr json requests" do
      part = Part.create! valid_attributes
      xhr :get, :show, :id => part.id, :format => :json
      json = ActiveSupport::JSON.decode(response.body)
      json['success'].should be_true
      json['data']['id'].should eq(part.id)
    end
  end
  
  describe "GET edit" do
    it "responds to xhr json requests" do
      part = Part.create! valid_attributes
      xhr :get, :edit, :id => part.id, :format => :json
      json = ActiveSupport::JSON.decode(response.body)
      json['success'].should be_true
      json['data']['id'].should eq(part.id)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Part" do
        expect {
          post :create, :part => valid_attributes
        }.to change(Part, :count).by(1)
      end

      it "assigns a newly created part as @part" do
        post :create, :part => valid_attributes
        assigns(:part).should be_a(Part)
        assigns(:part).should be_persisted
      end

      it "redirects to the created part" do
        post :create, :part => valid_attributes
        response.should redirect_to(Part.last)
      end
      
      it "responds to xhr json requests" do
        xhr :post, :create, :part => valid_attributes, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
        json['data']['id'].should eq(Part.last.id)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved part as @part" do
        # Trigger the behavior that occurs when invalid params are submitted
        Part.any_instance.stub(:save).and_return(false)
        post :create, :part => {}
        assigns(:part).should be_a_new(Part)
      end

      it "responds to xhr json requests" do
        # Trigger the behavior that occurs when invalid params are submitted
        Part.any_instance.stub(:invalid?).and_return(true)
        xhr :post, :create, :part => {}, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "responds to xhr json requests" do
        part = Part.create! valid_attributes
        xhr :put, :update, :id => part.id, :part => valid_attributes, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
        json['data']['id'].should eq(part.id)
        
      end
    end

    describe "with invalid params" do
      it "responds to xhr json requests" do
        part = Part.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Part.any_instance.stub(:invalid?).and_return(true)
        xhr :put, :update, :id => part.id, :part => {}, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested part" do
      part = Part.create! valid_attributes
      expect {
        delete :destroy, :id => part.id
      }.to change(Part, :count).by(-1)
    end

    it "redirects to the parts list" do
      part = Part.create! valid_attributes
      delete :destroy, :id => part.id
      response.should redirect_to(parts_url)
    end
  end
  
  describe "POST destory_all" do
    describe "with valid params" do
      it "responds to xhr json requests" do
        part = []
        2.times{|n| part << Part.create!(valid_attributes) }
        expect {
          xhr :post, :destroy_all, :part => part.to_json, :format => :json
        }.to change(Part, :count).by(-2)
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
      end
    end
    
    describe "with invalid params" do
      it "responds to xhr json requests" do
        part = []
        2.times{|n| part << Part.create!(valid_attributes) }
        Part.find(part.last).destroy
        expect {
          xhr :post, :destroy_all, :part => part.to_json, :format => :json
        }.to change(Part, :count).by(0)
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end
  
  describe "POST update_all" do
    describe "with valid params" do
      it "responds to xhr json requests" do
        part = []
        2.times{|n| part << Part.create!(valid_attributes) }
        xhr :post, :update_all, :part => part.to_json, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_true
      end
    end
    
    describe "with invalid params" do
      it "responds to xhr json requests" do
        part = []
        2.times{|n| part << Part.create!(valid_attributes) }
        Part.find(part.last).destroy
        xhr :post, :update_all, :part => part.to_json, :format => :json
        json = ActiveSupport::JSON.decode(response.body)
        json['success'].should be_false
        json['errors'].should_not be_nil
      end
    end
  end

end
