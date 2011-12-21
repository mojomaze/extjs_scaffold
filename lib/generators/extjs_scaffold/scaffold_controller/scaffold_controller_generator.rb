require 'generators/extjs_scaffold'
require 'rails/generators/resource_helpers'

module ExtjsScaffold
  module Generators
    class ScaffoldControllerGenerator < Base
      
      include Rails::Generators::ResourceHelpers
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      class_option :file_name, :desc => "Name of file used to hold Ext.application", :aliases => '-n'
      class_option :app_name, :desc => "Name of app used in Ext.application", :aliases => '-a'
      
      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :views, :type => :boolean, :default => true
      class_option :routes, :type => :boolean, :default => true
      class_option :pagination, :desc => "Rails pagination gem 'kaminari' or 'will_paginate'", :default => 'kaminari'
      class_option :reference_fields, :type => :hash, :desc => "Optional collection of fields to use for reference lookup, --reference_fields parent_table:field_name"
      
      # add class method 'search' to model
      def create_model_methods
        @pagination = options.pagination
        if File.exists?("#{destination_root}/app/models/#{singular_table_name}.rb")
          template "model.rb", "app/models/#{controller_file_name}_tmp.rb"
          f = File.open "#{destination_root}/app/models/#{controller_file_name}_tmp.rb", "r"
          model_methods = f.read
          inject_into_class "app/models/#{singular_table_name}.rb", singular_table_name.capitalize, model_methods
          remove_file "app/models/#{controller_file_name}_tmp.rb"
        end
      end
      
      check_class_collision :suffix => "Controller"

      def create_controller_files
        template 'controller.rb', File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end

      # create Extjs MVC structure
      def create_js_root_folder
        empty_directory File.join("app/assets/javascripts", "controller")
        empty_directory File.join("app/assets/javascripts", "model")
        empty_directory File.join("app/assets/javascripts", "store")
        empty_directory File.join("app/assets/javascripts", "view")
        # create Extjs controller view folder
        empty_directory File.join("app/assets/javascripts/view", singular_table_name)
      end

      # copy over controller js files
      def copy_js_files
        available_js.each do |name|
          filename = [name, :js].compact.join(".")
          case name
          when 'Controller'
            template "js/#{filename}", File.join("app/assets/javascripts/controller", "#{plural_table_name.capitalize}.js")  
          when 'Model'
            template "js/#{filename}", File.join("app/assets/javascripts/model", "#{singular_table_name.capitalize}.js")
          when 'Store'
            template "js/#{filename}", File.join("app/assets/javascripts/store", "#{plural_table_name.capitalize}.js")
          else
            template "js/#{filename}", File.join("app/assets/javascripts/view", singular_table_name, filename)
          end
        end
      end
      
      # create stores for any reference lookup combos
      def create_reference_stores
        attributes.select {|attr| attr.reference? }.each do |attribute|
          @reference_attribute = attribute
          @options = options
          filename = [reference_store, :js].compact.join(".")
          template "js/#{filename}", File.join("app/assets/javascripts/store", "#{singular_table_name.capitalize}#{attribute.name.capitalize.pluralize}.js")
        end
      end
      
      def update_application_js
        app_init = "\n"
        app_init << "      // #{plural_table_name.capitalize}: Initialize controller and create list grid \n"
        app_init << "      if (undefined != Ext.get('#{plural_table_name}_list')) { \n"
        app_init << "        var controller = this.getController('#{plural_table_name.capitalize}');\n"
        app_init << "        controller.init();\n"
        app_init << "        Ext.create('#{app_name}.view.#{singular_table_name}.Grid',{renderTo: Ext.getBody() });\n"
        app_init << "      }\n"
        
        insert_into_file "app/assets/javascripts/#{app_file_name}", app_init, :after => "launch: function() {"
      end
      
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
      
      # copy view templates or hook to :template_engine
      
      def copy_view_files
        return unless options[:views]
        empty_directory File.join("app/views", controller_file_path)
        # accept haml or default to erb
        template = options[:template_engine] == 'haml' ? options[:template_engine] : 'erb'
        
        available_views.each do |view|
          filename = filename_with_extensions(view, :html, template)
          template "views/#{template}/#{filename}", File.join("app/views", controller_file_path, filename)
        end
      end

      #hook_for :test_framework, :as => :ext_scaffold
      
      protected
      
      def app_file_name
        file_name = options.file_name || rails_app_name
        [file_name, :js].compact.join(".")
      end
      
      def app_name
        options.app_name || rails_app_name
      end
      
      def rails_app_name
        # get app name and convert to capcase
        Rails.root.to_s.split('/').last.titlecase.split.join
      end
      
      def available_views
        %w(index)
      end

      def filename_with_extensions(name, prefix, suffix)
        [name, prefix, suffix].compact.join(".")
      end
      
      def available_js
        %w(Controller Model Store Grid Form EditWindow)
      end
      
      def reference_store
        return 'ReferenceStore'
      end
      
      def reference_field(attribute)
        if options.reference_fields && options.reference_fields[attribute.name]
          options.reference_fields[attribute.name]
        else
          'name'
        end
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
          return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 80, renderer: #{app_name}.util.Format.booleanRenderer(), sortable: true"
        when 'datetime', 'date'
          return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 100, renderer: #{app_name}.util.Format.dateRenderer(), sortable: true"
        end
      	if attribute.reference?
          return "dataIndex: '#{attribute.name}_#{reference_field(attribute)}', header: '#{attribute.name.titleize}', width: 120, sortable: true"
        else
          return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 120, sortable: true"
        end
      end
      
      def create_ext_formfield(attribute)
        case attribute.type.to_s
        when 'boolean'
          return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}?', width: 120, xtype: 'checkbox'}"
        when 'date'
          return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 250, xtype: 'datefield'}"
        when 'text'
          return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 500, height: 200, xtype: 'textarea'}"
        when 'integer'
          return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 250, xtype: 'numberfield'}"
        end
        
        if attribute.reference?
          return "{ id: '#{attribute.name}_#{reference_field(attribute)}', 
            fieldLabel: '#{attribute.name.titleize}', 
            name: '[#{singular_table_name}]#{attribute.name}_id',
			      store: App.store.#{singular_table_name.capitalize}#{attribute.name.capitalize.pluralize},
						xtype: 'parentcombo'}"
				else
          return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 500, xtype: 'textfield'}"
        end
      end
    end
  end
end
