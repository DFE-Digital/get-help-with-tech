module Middleware
  class PreventHostHeaderPoisoning
    def initialize(app)
      @app = app
    end

    def call(env)
      %w[HTTP_HOST HTTP_X_FORWARDED_HOST].each do |header|
        if env[header] && \
            !Settings.hostname_for_urls.include?(env[header])
          env.delete(header)
        end
      end

      @app.call(env)
    end
  end
end
