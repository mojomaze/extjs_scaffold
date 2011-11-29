require 'rails/generators/active_record/model/model_generator'
require 'rails/generators/active_record'

module Ext
  module Generators
    class ActiveRecordGenerator < ActiveRecord::Generators::ModelGenerator
      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end
    end
  end
end
