module Ext
  module Generators
    class InstallGenerator < Rails::Generators::Base

      desc <<DESC
Description:
    Add Ext JS Library 4.0.7, config initializer, and images
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end
      
      def copy_asset_files
        directory 'app'
      end

      def copy_public_files
        directory 'public'
      end
      
      def copy_config_files
        directory 'config'
      end
      
      def copy_layout_file
        copy_file 'layout.html.erb', 'app/views/layouts/ext_layout.html.erb'
      end
    end
  end
end