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
                file "Form.js" do
                  contains "Ext.define('#{app_name}.view.#{controller_name}.Form', {"
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
          file "#{controller_name}.rb"
        end
        directory "views" do
          directory "#{controller_name.pluralize}" do
            file "index.html.haml" do
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
end