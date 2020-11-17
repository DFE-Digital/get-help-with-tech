module Middleware
  class RedirectIncorrectStart
    def initialize(app)
      @app = app
    end

    def call(env)
      @req = Rack::Request.new(env)

      if @req.path =~ /^\/start\]$/
        [302, { 'Location' => '/start' }, []]
      else
        @app.call(env)
      end
    end
  end
end
