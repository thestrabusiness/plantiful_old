Rails.application.configure do
  Rails.application.routes.default_url_options[:host] = 'plantiful.herokuapp.com'
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.active_storage.service = :amazon
  config.log_level = :debug
  config.log_tags = [:request_id]
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    authentication: 'plain',
    enable_startttls_auto: true,
    user_name: ENV.fetch('MAILER_USERNAME'),
    password: ENV.fetch('MAILER_PASSWORD'),
    domain: 'smtp.gmail.com',
    openssl_verify_mode: 'none'
  }
end
