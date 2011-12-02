require "spec_helper"
require "generator_spec/test_case"
require File.expand_path('../../../lib/generators/extjs_scaffold/create/create_generator.rb', __FILE__)

describe ExtjsScaffold::Generators::CreateGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)
  
  before(:each) do
    prepare_destination
  end
  
  it "generates files" do
    run_generator
  
    destination_root.should have_structure {
      
      
    }
  end
end