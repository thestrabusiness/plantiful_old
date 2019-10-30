Clearance.configure do |config|
  config.mailer_sender = "reply@example.com"
  config.rotate_csrf_on_sign_in = false
  config.routes = false
end

module Clearance
  class Session
    def remember_token
      pattern = /^Bearer /
      header = @env['HTTP_AUTHORIZATION']
      header.gsub(pattern, '') if header&.match(pattern)
    end
  end
end
