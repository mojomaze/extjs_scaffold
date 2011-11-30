require "rails/generators/named_base"

module ExtjsScaffold
  module Generators
    class Base < Rails::Generators::NamedBase
      def self.source_root
        @_extjs_scaffold_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'extjs_scaffold', generator_name, 'templates'))
      end
    end
  end
end
