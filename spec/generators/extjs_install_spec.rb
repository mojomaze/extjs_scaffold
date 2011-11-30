require "spec_helper"
require "generator_spec/test_case"
require File.expand_path('../../../lib/generators/extjs_scaffold/install/install_generator.rb', __FILE__)

describe ExtjsScaffold::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)
  
  before do
    prepare_destination
    run_generator
  end
  
  specify do
    destination_root.should have_structure {
      no_file "non_existant.rb"
      directory "app" do
        directory "assets" do
          directory "javascripts" do
            file "AppExt.js" do
              contains "name: 'dummy',"
            end
          end
        end
      end
    }
  end
end