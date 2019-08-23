require File.expand_path('../config/environment', __dir__)

ENV['RAILS_ENV'] ||= 'test'

require 'database_cleaner'
require 'rspec/rails'
require 'spec_helper'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')]
  .sort
  .each { |file| require file }

abort('The Rails environment is running in production mode!') if Rails.env.production?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  config.include ApiRequestHelpers
  config.include JsonHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
