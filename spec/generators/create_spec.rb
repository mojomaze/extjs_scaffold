require "spec_helper"
require "generator_spec/test_case"
require File.expand_path('../../../lib/generators/extjs_scaffold/create/create_generator.rb', __FILE__)

describe ExtjsScaffold::Generators::CreateGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)
  route_path = File.expand_path("../../support", __FILE__)
  
  before(:each) do
    prepare_destination
    mkdir_p "#{destination_root}/config"
    copy "#{route_path}/rails_routes.rb",  "#{destination_root}/config/routes.rb"
  end
  
  it "generates migration, model and controller" do
    run_generator %w(widgets name:string color:string)
  
    destination_root.should have_structure {
      
      
    }
  end
end