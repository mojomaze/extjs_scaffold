# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"

require "rails/generators"
require File.expand_path('../../lib/generators/extjs_scaffold.rb', __FILE__)

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # == Mock Framework
  config.mock_with :rspec
  
  # turn on transactions for factory use
  config.use_transactional_fixtures = true
  
end
