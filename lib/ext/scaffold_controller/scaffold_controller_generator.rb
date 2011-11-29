require 'generators/ext'
require 'rails/generators/resource_helpers'

module Ext
  module Generators
    class ScaffoldControllerGenerator < Base
      include Rails::Generators::ResourceHelpers
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :routes, :type => :boolean, :default => true
      #class_option :list_type, :type => :string, :default => "paging", :desc => "'livegrid' or 'paging', defaults to paging"
      
      check_class_collision :suffix => "Controller"

      def create_controller_files
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      # create js files under public/javascipts/app/controller
      def create_js_root_folder
        empty_directory File.join("app/assets/javascripts", "controller")
        empty_directory File.join("app/assets/javascripts", "model")
        empty_directory File.join("app/assets/javascripts", "store")
        empty_directory File.join("app/assets/javascripts", "view")
        empty_directory File.join("app/assets/javascripts/view", singular_table_name)
      end

      # copy over js files
      def copy_js_files
        available_js.each do |name|
          filename = [name, :js].compact.join(".")
          case name
          when 'Controller'
            template filename, File.join("app/assets/javascripts/controller", "#{plural_table_name.capitalize}.js")  
          when 'Model'
            template filename, File.join("app/assets/javascripts/model", "#{singular_table_name.capitalize}.js")
          when 'Store'
            template filename, File.join("app/assets/javascripts/store", "#{plural_table_name.capitalize}.js")
          else
            template filename, File.join("app/assets/javascripts/view", singular_table_name, filename)
          end
        end
      end
      
      # create stores for any reference lookup combos
      def create_reference_stores
        attributes.select {|attr| attr.reference? }.each do |attribute|
          @reference_attribute = attribute
          filename = [reference_store, :js].compact.join(".")
          template filename, File.join("app/assets/javascripts/store", "#{singular_table_name.capitalize}#{attribute.name.capitalize.pluralize}.js")
        end
      end
      
      # def update_application_js
      #         app_init = "\n"
      #         app_init << "      // move up to controllers config for true mvc framework \n"
      #         app_init << "      if (undefined != Ext.get('#{plural_table_name}_main')) { \n"
      #         app_init << "        var controller = this.getController('#{plural_table_name.capitalize}');\n"
      #         app_init << "        controller.init();\n"
      #         app_init << "        Ext.create('App.view.#{singular_table_name}.Grid',{renderTo: Ext.getBody() });\n"
      #         app_init << "      }\n"
      #         
      #         insert_into_file "public/javascripts/app/Application.js", app_init, :after => "launch: function() {"
      #       end
      
      def add_resource_route
        return unless options[:routes]
        route_config =  class_path.collect{|namespace| "namespace :#{namespace} do " }.join(" ")
        route_config << "resources :#{file_name.pluralize} do \n"
        route_config << "    collection do \n"
        route_config << "      post :destroy_all \n"
        route_config << "      post :update_all \n"
        route_config << "    end\n"
        route_config << "  end"
        route_config << " end" * class_path.size
        route route_config
      end

      hook_for :test_framework, :as => :ext_scaffold

      # Invoke the helper using the controller name (pluralized)
      hook_for :helper do |invoked|
        invoke invoked, [ controller_name ]
      end
      
      hook_for :template_engine

      protected
        def available_js
          %w(Controller Model Store Grid Form EditWindow)
        end
        
        def reference_store
          return 'ReferenceStore'
        end
        
        def create_controller_store_list
          list = []
          attributes.select {|attr| attr.reference? }.each do |attribute|
            list << "'#{singular_table_name.capitalize}#{attribute.name.pluralize.capitalize}'"
          end
          return list.join(',')
        end
        
        def create_ext_record(attribute)
          case attribute.type.to_s
          when 'boolean'
            return "name: '#{attribute.name}', type: 'bool'"
          when 'datetime', 'date'
            return "type: 'date', sortType: 'asDate', name: '#{attribute.name}', dateFormat: 'c'"
        	end
        	if attribute.reference?
            return "name: '#{attribute.name}_name'"
          else
            return "name: '#{attribute.name}'"
          end
        end
        
        def create_ext_column(attribute)
          case attribute.type.to_s
          when 'boolean'
            return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 80, renderer: App.util.Format.booleanRenderer(), sortable: true"
          when 'datetime', 'date'
            return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 100, renderer: App.util.Format.dateRenderer(), sortable: true"
          end
        	if attribute.reference?
            return "dataIndex: '#{attribute.name}_name', header: '#{attribute.name.titleize}', width: 120, sortable: true"
          else
            return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 120, sortable: true"
          end
        end
        
        def create_ext_formfield(attribute)
          case attribute.type.to_s
          when 'boolean'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}?', width: 120, xtype: 'checkbox'}"
          when 'date'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 120, xtype: 'datefield'}"
          when 'text'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 350, height: 200, xtype: 'textarea'}"
          when 'integer'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 120, xtype: 'numberfield'}"
          end
          
          if attribute.reference?
            return "{ id: '#{attribute.name}_name', 
              fieldLabel: '#{attribute.name.titleize}', 
              name: '[#{singular_table_name}]#{attribute.name}_id',
  			      store: App.store.#{singular_table_name.capitalize}#{attribute.name.capitalize.pluralize},
  						xtype: 'parentcombo'}"
  				else
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 200, xtype: 'textfield'}"
          end
        end
    end
  end
end
