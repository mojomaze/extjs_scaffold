require "spec_helper"
require "generator_spec/test_case"
require File.expand_path('../../../lib/generators/extjs_scaffold/install/install_generator.rb', __FILE__)

describe ExtjsScaffold::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)
  
  before(:each) do
    prepare_destination
  end
  
  it "generates files with no options" do
    run_generator
  
    destination_root.should have_structure {
      app_name = Rails.root.to_s.split('/').last.titlecase.split.join
      
      no_file "non_existant.rb"
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            file "#{app_name}.js" do
              contains "name: '#{app_name}',"
            end
            directory "model" do
              file "ParentCombo.js" do
                contains "Ext.define('#{app_name}.model.ParentCombo', {"
              end
            end
            directory "util" do
              file "Format.js" do
                contains "Ext.ns('#{app_name}.util');"
              end
            end
            directory "ux" do
              directory "data" do
                file "Actionable.js" do
                  contains "Ext.define('#{app_name}.ux.data.Actionable', {"
                end
                file "Updateable.js" do
                  contains "Ext.define('#{app_name}.ux.data.Updateable', {"
                end
                directory "proxy" do
                  file "Rails.js" do
                    contains "Ext.define('#{app_name}.ux.data.proxy.Rails', {"
                  end
                end
              end
              directory "form" do
                file "Panel.js" do
                  contains "Ext.define('#{app_name}.ux.form.Panel', {"
                end
                directory "field" do
                  file "ParentCombo.js" do
                    contains "Ext.define('#{app_name}.ux.form.field.ParentCombo', {"
                  end
                  file "SearchField.js" do
                    contains "Ext.define('#{app_name}.ux.form.field.SearchField', {"
                  end
                end
              end
              directory "grid" do
                file "Panel.js" do
                  contains "Ext.define('#{app_name}.ux.grid.Panel', {"
                end
              end
              directory "toolbar" do
                file "Scrolling.js" do
                  contains "Ext.define('#{app_name}.ux.toolbar.Scrolling', {"
                end
              end
              directory "window" do
                file "EditWindow.js" do
                  contains "Ext.define('#{app_name}.ux.window.EditWindow', {"
                end
              end
            end
          end
        end
      end
    }
  end
  
  it "generates files with options" do
    run_generator %w(--file_name=Foo --app_name=Bar)
  
    destination_root.should have_structure {
      no_file "non_existant.rb"
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            file "Foo.js" do
              contains "name: 'Bar',"
            end
          end
        end
      end
    }
  end
  
  it "generates files with options aliases" do
    run_generator %w(-n=Foo -a=Bar)
  
    destination_root.should have_structure {
      no_file "non_existant.rb"
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            file "Foo.js" do
              contains "name: 'Bar',"
            end
          end
        end
      end
    }
  end
end