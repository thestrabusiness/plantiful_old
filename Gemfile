source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'active_model_serializers'
gem 'active_storage_base64'
gem 'aws-sdk-s3', require: false
gem 'betterlorem'
gem 'bitters'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bourbon'
gem 'clearance'
gem 'dotenv-rails'
gem 'foreman'
gem 'haml'
gem 'mini_magick'
gem 'neat'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 4.x'

group :development, :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'timecop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
