require 'generators/ext'
require 'rails/generators/resource_helpers'

module Ext
  module Generators
    class HamlGenerator < Base
      include Rails::Generators::ResourceHelpers
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      class_option :views, :type => :boolean, :default => true

      def create_root_folder
        return unless options[:views]
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        return unless options[:views]
        available_views.each do |view|
          filename = filename_with_extensions(view, :html)
          template filename, File.join("app/views", controller_file_path, filename)
        end
      end

      protected
        def available_views
          %w(index)
        end

        def filename_with_extensions(name, prefix)
          [name, prefix, :haml].compact.join(".")
        end
    end
  end
end
