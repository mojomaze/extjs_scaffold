require 'generators/extjs_scaffold'
require 'rails/generators/resource_helpers'

module ExtjsScaffold
  module Generators
    class ScaffoldGenerator < Base
      include Rails::Generators::ResourceHelpers
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :views, :type => :boolean, :default => true
      class_option :routes, :type => :boolean, :default => true
      
      hook_for :orm
      
      hook_for :scaffold_controller
  
    end
  end
end
