require 'generators/extjs_scaffold'
require 'rails/generators/resource_helpers'

module ExtjsScaffold
  module Generators
    class ScaffoldControllerGenerator < Base
      
      include Rails::Generators::ResourceHelpers
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      class_option :file_name, :desc => "Name of file used to hold Ext.application", 
              :aliases => '-n', :default =>ExtjsScaffold::Generators::Base.rails_app_name
      class_option :app_name, :desc => "Name of app used in Ext.application", 
              :aliases => '-a', :default => ExtjsScaffold::Generators::Base.rails_app_name
      
      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :views, :type => :boolean, :default => true
      class_option :routes, :type => :boolean, :default => true
      class_option :pagination, :desc => "Rails pagination gem 'kaminari' or 'will_paginate'", :default => 'kaminari'
      class_option :reference_fields, :type => :hash, :desc => "Collection of fields to use for one table lookup: --reference_fields parent_table:field_name
                                           # Default: parent_table:name"
      class_option :test_framework, :desc => "Test framework to be invoked"
      
      # add class method 'search' to model
      def create_model_methods
        @pagination = options.pagination
        if File.exists?("#{destination_root}/app/models/#{singular_table_name}.rb")
          template "model.rb", "app/models/#{controller_file_name}_tmp.rb"
          f = File.open "#{destination_root}/app/models/#{controller_file_name}_tmp.rb", "r"
          model_methods = f.read
          # make related tables updateable - add to attr_accessible
          refs = reference_attributes.map{|a| ":#{a.name}_id, :#{a.name}_#{reference_field(a)}"}
          if refs.size > 0
            refs_attr = refs.sort.join(", ")
            insert_into_file "app/models/#{singular_table_name}.rb", ", "+refs_attr, :after => /attr_accessible.*/
          end
          # add search with pagination class method
          insert_into_file "app/models/#{singular_table_name}.rb", "\n"+model_methods, :after => /attr_accessible.*/
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

      def copy_test_files
        case options[:test_framework]
        when :rspec, 'rspec'
          template "tests/controller_spec.rb", File.join("spec/controllers", "#{controller_file_name}_controller_spec.rb")
        when :test_unit, 'test_unit'
          template "tests/controller_test.rb", File.join("test/functional", "#{controller_file_name}_controller_test.rb")
        end
      end
      
      protected
      
      def app_file_name
        [options.file_name, :js].compact.join(".")
      end
      
      def app_name
        options.app_name
      end
      
      def available_views
        %w(index)
      end

      def filename_with_extensions(name, prefix, suffix)
        [name, prefix, suffix].compact.join(".")
      end
      
      def available_js
        %w(Controller Model Store Grid EditForm EditWindow UpdateForm UpdateWindow)
      end
      
      def reference_store
        return 'ReferenceStore'
      end
      
      def reference_model
        return 'ReferenceModel'
      end
      
      def reference_field(attribute)
        if options.reference_fields && options.reference_fields[attribute.name]
          options.reference_fields[attribute.name]
        else
          'name'
        end
      end
      
      def create_controller_model_list
        list = []
        attributes.select {|attr| attr.reference? }.each do |attribute|
          list << "'#{attribute.name.capitalize}'"
        end
        return list.join(',')
      end
      
      def create_controller_store_list
        list = []
        attributes.select {|attr| attr.reference? }.each do |attribute|
          list << "'#{singular_table_name.capitalize}#{attribute.name.pluralize.capitalize}'"
        end
        return list.join(',')
      end
      
      def create_ext_record(attribute)
        if attribute.reference?
          return "name: '#{attribute.name}_#{reference_field(attribute)}'"
        else
          case attribute.type.to_s
          when 'boolean'
            return "name: '#{attribute.name}', type: 'bool'"
          when 'datetime', 'date'
            return "type: 'date', sortType: 'asDate', name: '#{attribute.name}', dateFormat: 'c'"
        	else
        	  return "name: '#{attribute.name}'"
        	end
        end
      end
      
      def create_ext_column(attribute)
        if attribute.reference?
          return "dataIndex: '#{attribute.name}_#{reference_field(attribute)}', header: '#{attribute.name.titleize}', width: 120, sortable: true"
        else  
          case attribute.type.to_s
          when 'boolean'
            return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 80, renderer: #{app_name}.util.Format.booleanRenderer(), sortable: true"
          when 'datetime', 'date'
            return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 100, renderer: #{app_name}.util.Format.dateRenderer(), sortable: true"
          else
           return "dataIndex: '#{attribute.name}', header: '#{attribute.name.titleize}', width: 120, sortable: true"
          end
        end
      end
      
      def create_ext_formfield(attribute)
        if attribute.reference?
          return "{ id: '#{attribute.name}_#{reference_field(attribute)}', 
            fieldLabel: '#{attribute.name.titleize}', 
            name: '[#{singular_table_name}]#{attribute.name}_id',
            store: #{app_name}.store.#{singular_table_name.capitalize}#{attribute.name.capitalize.pluralize},
            displayField:'#{reference_field(attribute)}',
            emptyText: 'type at least 2 characters from #{reference_field(attribute)}',
            xtype: 'parentcombo'}"
        else
          case attribute.type.to_s
          when 'boolean'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}?', width: 120, xtype: 'checkbox'}"
          when 'date'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 250, xtype: 'datefield'}"
          when 'text'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 500, height: 200, xtype: 'textarea'}"
          when 'integer'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 250, xtype: 'numberfield', allowDecimals: false}"
          when 'decimal'
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 250, xtype: 'numberfield', allowDecimals: true}"
          else
            return "{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', fieldLabel: '#{attribute.name.titleize}', width: 500, xtype: 'textfield'}"
          end
        end
      end
      
      def create_ext_updateformfield(attribute)
        # build field container with disable checkbox
        field = "{ xtype: 'fieldcontainer', fieldLabel: '#{field_label(attribute)}', layout: 'hbox', width: #{updatefield_width(attribute)}, combineErrors: true,
						items:[
							{ xtype: 'displayfield', hideLabel: true, value: 'Enable'}
							,{ xtype: 'checkboxfield', width: 20, hideLabel: true, style: 'margin-left: 5px'}
							"
        if attribute.reference?
          field += ",{ id: '#{attribute.name}_#{reference_field(attribute)}', 
            hideLabel: true, 
            name: '[#{singular_table_name}]#{attribute.name}_id',
            store: #{app_name}.store.#{singular_table_name.capitalize}#{attribute.name.capitalize.pluralize},
            displayField:'#{reference_field(attribute)}',
            emptyText: 'type at least 2 characters from #{reference_field(attribute)}',
            flex: 1,
            disabled: true,
            xtype: 'parentcombo'}"
        else
          case attribute.type.to_s
          when 'boolean'
            field += ",{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', hideLabel: true, width: 120, flex: 1, disabled: true, xtype: 'checkbox'}"
          when 'date'
            field += ",{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', hideLabel: true, width: 250, flex: 1, disabled: true, xtype: 'datefield'}"
          when 'text'
            field += ",{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', hideLabel: true, width: 500, height: 200, flex: 1, disabled: true, xtype: 'textarea'}"
          when 'integer'
            field += ",{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', hideLabel: true, width: 250, flex: 1, disabled: true, xtype: 'numberfield', allowDecimals: false}"
          when 'decimal'
            field += ",{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', hideLabel: true, width: 250, flex: 1, disabled: true, xtype: 'numberfield', allowDecimals: true}"
          else
            field += ",{id: '#{attribute.name}', name: '[#{singular_table_name}]#{attribute.name}', hideLabel: true, width: 500, flex: 1, disabled: true, xtype: 'textfield'}"
          end
        end
        
        field += "
			      ]
	      }
  
        "    
        return field
      end
      
      def field_label(attribute)
        return attribute.type.to_s == 'boolean' ? "#{attribute.name.titleize}?" : attribute.name.titleize    
      end
      
      def updatefield_width(attribute) 
        return %w(boolean date integer).include?(attribute.type.to_s) ? 275 : 575
      end
      
      private

        def resource_attributes
          key_value singular_table_name, "{ #{attributes_hash} }"
        end

        def attributes_hash
          return if accessible_attributes.empty?

          accessible_attributes.map do |a|
            name = a.name
            key_value name, "@#{singular_table_name}.#{name}"
          end.sort.join(', ')
        end

        def accessible_attributes
          attributes.reject(&:reference?)
        end
        
        def reference_attributes
          attributes.select(&:reference?)
        end
    end
  end
end
