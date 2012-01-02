require "spec_helper"
require "generator_spec/test_case"

require File.expand_path('../../../lib/generators/extjs_scaffold/scaffold/scaffold_generator.rb', __FILE__)

describe ExtjsScaffold::Generators::ScaffoldGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)
  support_path = File.expand_path("../../support", __FILE__)
  app_name = Rails.root.to_s.split('/').last.titlecase.split.join
  
  before(:each) do
    prepare_destination
    mkdir_p "#{destination_root}/config"
    copy "#{support_path}/rails_routes.rb", "#{destination_root}/config/routes.rb"
    mkdir_p "#{destination_root}//app/assets/javascripts"
    copy "#{support_path}/App.js", "#{destination_root}/app/assets/javascripts/#{app_name}.js"
  end
  
  it "generates scaffold using active_record and haml" do
    controller_name = "widget"
    run_generator %w(widget name:string color:string --orm=active_record --template_engine=haml)
  
    destination_root.should have_structure {
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            file "#{app_name}.js" do
              contains "if (undefined != Ext.get('#{controller_name.pluralize}_list'))"
            end
            file 'widgets.js'
            directory "controller" do
              file "#{controller_name.pluralize.capitalize}.js" do
                contains "Ext.define('#{app_name}.controller.#{controller_name.pluralize.capitalize}', {"
              end
            end
            directory "model" do
              file "#{controller_name.capitalize}.js" do
                contains "Ext.define('#{app_name}.model.#{controller_name.capitalize}', {"
              end
            end
            directory "store" do
              file "#{controller_name.pluralize.capitalize}.js" do
                contains "Ext.define('#{app_name}.store.#{controller_name.pluralize.capitalize}', {"
              end
            end
            directory "view" do
              directory "#{controller_name}" do
                file "EditWindow.js" do
                  contains "Ext.define('#{app_name}.view.#{controller_name}.EditWindow', {"
                end
                file "EditForm.js" do
                  contains "Ext.define('#{app_name}.view.#{controller_name}.EditForm', {"
                end
                file "UpdateWindow.js" do
                  contains "Ext.define('#{app_name}.view.#{controller_name}.UpdateWindow', {"
                end
                file "UpdateForm.js" do
                  contains "Ext.define('#{app_name}.view.#{controller_name}.UpdateForm', {"
                end
                file "Grid.js" do
                  contains "Ext.define('#{app_name}.view.#{controller_name}.Grid', {"
                end
              end
            end
          end
          directory "stylesheets" do
            file "scaffold.css"
            file "#{controller_name.pluralize}.css"
          end
        end
        directory "controllers" do
          file "#{controller_name.pluralize}_controller.rb"
        end
        directory "models" do
          file "#{controller_name}.rb" do
            # default pagination is kaminari
            contains "page(page).per(size)"
          end
        end
        directory "views" do
          directory "#{controller_name.pluralize}" do
            file "index.html.haml" do
              contains "shared/ext_auth"
              contains "#{controller_name.pluralize}_list"
            end
          end
        end
      end
      directory "config" do
        file "routes.rb" do
          contains "resources :widgets do"
        end
      end
    }
  end
  
  it "generates model with will_paginate pagination" do
    controller_name = "widget"
    run_generator %w(widget name:string color:string --orm=active_record --pagination=will_paginate)
  
    destination_root.should have_structure {
      directory "app" do
        directory "models" do
          file "#{controller_name}.rb" do
            contains "paginate(:page => page, :per_page => size)"
          end
        end
      end
    }
  end
  
  it "generates scaffold with reference with default 'name' field lookup" do
    controller_name = "widget"
    run_generator %w(widget item:references name:string color:string --orm=active_record)
  
    destination_root.should have_structure {
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            directory "store" do
              file "WidgetItems.js"
            end
            directory "view" do
              directory "#{controller_name}" do
                file "EditForm.js" do
                  contains "{ id: 'item_name',"
                  contains "xtype: 'parentcombo'}"
                end
              end
            end
          end
        end
        directory "controllers" do
          file "#{controller_name.pluralize}_controller.rb" do
            contains "[:item_name]"
          end
        end
        directory "models" do
          file "#{controller_name}.rb" do
            contains "belongs_to :item"
            contains "def item_name"
            contains "when 'item_name'"
          end
        end
        directory "views" do
          directory "#{controller_name.pluralize}" do
            file "index.html.erb" do
              contains "shared/ext_auth"
              contains "#{controller_name.pluralize}_list"
            end
          end
        end
      end
    }
  end
  
  it "generates scaffold with reference with user defined field lookup" do
    controller_name = "widget"
    run_generator %w(widget item:references name:string color:string --orm=active_record --reference-fields item:sku)
  
    destination_root.should have_structure {
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            directory "controller" do
              file "#{controller_name.pluralize.capitalize}.js" do
                contains "var item_sku = action.result.data.item_sku;"
              end
            end
            directory "store" do
              file "WidgetItems.js" do
                contains "property: 'sku'"
              end
            end
            directory "view" do
              directory "#{controller_name}" do
                file "Grid.js" do
                  contains "{dataIndex: 'item_sku'"
                end
                file "EditForm.js" do
                  contains "{ id: 'item_sku',"
                  contains "xtype: 'parentcombo'}"
                end
              end
            end
          end
        end
        directory "controllers" do
          file "#{controller_name.pluralize}_controller.rb" do
            contains "[:item_sku]"
          end
        end
        directory "models" do
          file "#{controller_name}.rb" do
            contains "belongs_to :item"
            contains "def item_sku"
            contains "when 'item_sku'"
          end
        end
        directory "views" do
          directory "#{controller_name.pluralize}" do
            file "index.html.erb" do
              contains "shared/ext_auth"
              contains "#{controller_name.pluralize}_list"
            end
          end
        end
      end
    }
  end
  
  it "generates scaffold with rspec controller test" do
    controller_name = "widget"
    run_generator %w(complex_model_name item:references widget:references name:string color:string --orm=active_record --test-framework=rspec)
  
    destination_root.should have_structure {
      directory "spec" do
        directory "models" do
          file "complex_model_name_spec.rb"
        end
        directory "controllers" do
          file "complex_model_names_controller_spec.rb"
        end
      end
    }
  end
  
  it "generates scaffold with test_unit controller test" do
    controller_name = "widget"
    run_generator %w(complex_model_name item:references widget:references name:string color:string --orm=active_record --test-framework=test_unit)
  
    destination_root.should have_structure {
      directory "test" do
        directory "unit" do
          file "complex_model_name_test.rb"
        end
        directory "functional" do
          file "complex_model_names_controller_test.rb"
        end
      end
    }
  end
end