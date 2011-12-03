require "rails/generators/rails/scaffold/scaffold_generator"

module ExtjsScaffold
  module Generators
    class ScaffoldGenerator < Rails::Generators::ScaffoldGenerator
      remove_hook_for :scaffold_controller

      hook_for :scaffold_controller, :required => true
      
      # override super - route added in scaffold_controller_generator
      def add_resource_route
        
      end

    end
  end
end