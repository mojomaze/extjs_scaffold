module ExtjsScaffold
  module Generators
    class InstallGenerator < Rails::Generators::Base

      desc <<DESC
Description:
    Installs Ext MVC structure and ux js files
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end
      
      def copy_asset_files
        directory 'app'
      end
      
      def create_application_file
        template 'App.js', File.join('app/assets/javascripts/', "AppExt.js")
      end
     
      protected
      
      def app_name
        Rails.root.to_s.split('/').last
      end
    end
  end
end