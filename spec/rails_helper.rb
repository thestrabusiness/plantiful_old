require 'spec_helper'
require File.expand_path('../config/environment', __dir__)

require 'database_cleaner'
require 'rspec/rails'
require 'clearance/rspec'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')]
  .sort
  .each { |file| require file }

abort('The Rails environment is not running in test mode!') if !Rails.env.test?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Capybara.javascript_driver = :selenium_headless

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  config.include ApiRequestHelpers
  config.include JsonHelpers
  config.include FrontEndRouteHelpers

  config.define_derived_metadata(file_path: Regexp.new('/spec/features')) do |metadata|
    metadata[:js] = true
    metadata[:allow_forgery_protection] = true
  end

  config.around(:each, allow_forgery_protection: true) do |example|
    original_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    begin
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = original_forgery_protection
    end
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    `bin/webpack`
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
